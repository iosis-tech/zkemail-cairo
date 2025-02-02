use std::collections::HashMap;

use cairo_vm::{
    hint_processor::{
        builtin_hint_processor::{builtin_hint_processor_definition::HintProcessorData, hint_utils::get_ptr_from_var_name},
        hint_processor_utils::felt_to_u32,
    },
    types::{exec_scope::ExecutionScopes, relocatable::MaybeRelocatable},
    vm::{errors::hint_errors::HintError, vm_core::VirtualMachine},
    Felt252,
};
use generic_array::GenericArray;
use sha2::compress256;

use crate::hint_processor::hints::vars;

const SHA256_INPUT_CHUNK_SIZE_FELTS: usize = 16;
const SHA256_INPUT_CHUNK_SIZE_BYTES: usize = 64;
const BLOCK_SIZE: usize = 7;
const SHA256_STATE_SIZE_FELTS: usize = 8;

const IV: [u32; SHA256_STATE_SIZE_FELTS] = [
    0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A, 0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19,
];

pub const SHA256_INIT: &str = "from starkware.cairo.common.cairo_sha256.sha256_utils import IV\nmemory.write_arg(ids.init_state, IV)";

pub fn sha256_init(
    vm: &mut VirtualMachine,
    _exec_scopes: &mut ExecutionScopes,
    hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let address = get_ptr_from_var_name(vars::ids::INIT_STATE, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
    vm.load_data(address, &IV.map(|x| MaybeRelocatable::from(Felt252::from(x))))?;
    Ok(())
}

pub const SHA256_LOOP: &str = "from starkware.cairo.common.cairo_sha256.sha256_utils import (\n    IV, compute_message_schedule, sha2_compress_function)\nhash256 = sha2_compress_function(\n    memory.get_range(ids.state, ids.SHA256_STATE_SIZE_FELTS),\n    compute_message_schedule(memory.get_range(ids.chunk, ids.SHA256_INPUT_CHUNK_SIZE_FELTS))\n)\nsegments.write_arg(ids.hash256_ptr, hash256)";

pub fn sha256_loop(
    vm: &mut VirtualMachine,
    _exec_scopes: &mut ExecutionScopes,
    hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let state_ptr = get_ptr_from_var_name(vars::ids::STATE, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;

    let mut iv = vm
        .get_integer_range(state_ptr, SHA256_STATE_SIZE_FELTS)?
        .into_iter()
        .map(|x| felt_to_u32(x.as_ref()))
        .collect::<Result<Vec<u32>, _>>()?
        .try_into()
        .unwrap();

    sha256_main(vm, hint_data, &mut iv)
}

/// Inner implementation of [`sha256_main_constant_input_length`] and [`sha256_main_arbitrary_input_length`]
fn sha256_main(vm: &mut VirtualMachine, hint_data: &HintProcessorData, iv: &mut [u32; 8]) -> Result<(), HintError> {
    let input_ptr = get_ptr_from_var_name(vars::ids::CHUNK, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;

    let mut message: Vec<u8> = Vec::with_capacity(SHA256_INPUT_CHUNK_SIZE_BYTES);

    for i in 0..SHA256_INPUT_CHUNK_SIZE_FELTS {
        let input_element = vm.get_integer((input_ptr + i)?)?;
        let bytes = felt_to_u32(input_element.as_ref())?.to_be_bytes();
        message.extend(bytes);
    }

    let new_message = GenericArray::clone_from_slice(&message);
    compress256(iv, &[new_message]);

    let mut output: Vec<MaybeRelocatable> = Vec::with_capacity(iv.len());

    for new_state in iv {
        output.push(Felt252::from(*new_state).into());
    }

    let output_base = get_ptr_from_var_name(vars::ids::HASH256_PTR, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;

    vm.write_arg(output_base, &output)?;
    Ok(())
}

pub const SHA256_FINALIZE: &str = "# Add dummy pairs of input and output.\nfrom starkware.cairo.common.cairo_sha256.sha256_utils import (\n    IV,\n    compute_message_schedule,\n    sha2_compress_function,\n)\n\nnumber_of_missing_blocks = (-ids.n) % ids.BATCH_SIZE\nassert 0 <= number_of_missing_blocks < 20\n_sha256_input_chunk_size_felts = ids.SHA256_INPUT_CHUNK_SIZE_FELTS\nassert 0 <= _sha256_input_chunk_size_felts < 100\n\nmessage = [0] * _sha256_input_chunk_size_felts\nw = compute_message_schedule(message)\noutput = sha2_compress_function(IV, w)\npadding = (message + IV + output) * number_of_missing_blocks\nsegments.write_arg(ids.sha256_ptr_end, padding)";

pub fn sha256_finalize(
    vm: &mut VirtualMachine,
    _exec_scopes: &mut ExecutionScopes,
    hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let message: Vec<u8> = vec![0; 64];

    let mut iv = IV;

    let iv_static: Vec<MaybeRelocatable> = iv.iter().map(|n| Felt252::from(*n).into()).collect();

    let new_message = GenericArray::clone_from_slice(&message);
    compress256(&mut iv, &[new_message]);

    let mut output: Vec<MaybeRelocatable> = Vec::with_capacity(SHA256_STATE_SIZE_FELTS);

    for new_state in iv {
        output.push(Felt252::from(new_state).into());
    }

    let sha256_ptr_end = get_ptr_from_var_name(vars::ids::SHA256_PTR_END, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;

    let mut padding: Vec<MaybeRelocatable> = Vec::new();
    let zero_vector_message: Vec<MaybeRelocatable> = vec![Felt252::ZERO.into(); 16];

    for _ in 0..BLOCK_SIZE - 1 {
        padding.extend_from_slice(zero_vector_message.as_slice());
        padding.extend_from_slice(iv_static.as_slice());
        padding.extend_from_slice(output.as_slice());
    }

    vm.write_arg(sha256_ptr_end, &padding)?;
    Ok(())
}
