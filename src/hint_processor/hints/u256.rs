use std::{
    collections::HashMap,
    ops::{Shl, Shr},
};

use cairo_type_derive::{CairoType, FieldOffsetGetters};
use cairo_vm::{
    hint_processor::builtin_hint_processor::{
        builtin_hint_processor_definition::HintProcessorData,
        hint_utils::{get_address_from_var_name, get_integer_from_var_name, insert_value_from_var_name},
    },
    math_utils::pow2_const,
    types::{exec_scope::ExecutionScopes, relocatable::Relocatable},
    vm::{
        errors::{hint_errors::HintError, memory_errors::MemoryError},
        vm_core::VirtualMachine,
    },
    Felt252,
};
use num_bigint::BigUint;

use super::vars;
use crate::hint_processor::hints::CairoType;

#[derive(FieldOffsetGetters, CairoType, Default, Debug)]
pub struct Uint256 {
    pub low: Felt252,
    pub high: Felt252,
}

impl From<&BigUint> for Uint256 {
    fn from(value: &BigUint) -> Self {
        debug_assert!(value.bits() <= 256);
        let mask = BigUint::from(1_u32).shl(128_u32) - BigUint::from(1_u32);
        let low = Felt252::from_bytes_be_slice(&(value.shr(0_u32) & &mask).to_bytes_be());
        let high = Felt252::from_bytes_be_slice(&(value.shr(128_u32) & &mask).to_bytes_be());
        Self { low, high }
    }
}

impl From<Uint256> for BigUint {
    fn from(val: Uint256) -> Self {
        let low: BigUint = val.low.to_biguint();
        let high: BigUint = val.high.to_biguint();
        low + high.shl(128_u32)
    }
}

pub const UINT256_ADD: &str = "sum_low = ids.a.low + ids.b.low + ids.c_in\nids.carry_low = 1 if sum_low >= ids.SHIFT else 0\nsum_high = ids.a.high + ids.b.high + ids.carry_low\nids.carry_high = 1 if sum_high >= ids.SHIFT else 0";

pub fn uint256_add(
    vm: &mut VirtualMachine,
    _exec_scopes: &mut ExecutionScopes,
    hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let shift = pow2_const(128);

    let a_ptr = get_address_from_var_name(vars::ids::A, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();
    let b_ptr = get_address_from_var_name(vars::ids::B, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();
    let c_in = get_integer_from_var_name(vars::ids::C_IN, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;

    let a = Uint256::from_memory(vm, a_ptr)?;
    let b = Uint256::from_memory(vm, b_ptr)?;

    let a_low = a.low.as_ref();
    let b_low = b.low.as_ref();
    let a_high = a.high.as_ref();
    let b_high = b.high.as_ref();

    let carry_low = Felt252::from((a_low + b_low + c_in >= shift) as u8);
    let carry_high = Felt252::from((a_high + b_high + carry_low >= shift) as u8);

    insert_value_from_var_name(vars::ids::CARRY_LOW, carry_low, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
    insert_value_from_var_name(vars::ids::CARRY_HIGH, carry_high, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
    Ok(())
}
