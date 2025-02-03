use std::collections::HashMap;

use cairo_vm::{
    hint_processor::builtin_hint_processor::{
        builtin_hint_processor_definition::HintProcessorData,
        hint_utils::{get_address_from_var_name, get_ptr_from_var_name, insert_value_into_ap},
    },
    types::{exec_scope::ExecutionScopes, relocatable::MaybeRelocatable},
    vm::{errors::hint_errors::HintError, vm_core::VirtualMachine},
    Felt252,
};

use super::{
    hints::{u2048::Uint2048, vars, CairoType},
    CustomHintProcessor,
};
use crate::types::Advice;

pub const HINT_SET_SIGNATURE: &str = "set_u2048(ids.signature, dkim_input.signature)";

impl CustomHintProcessor {
    pub fn hint_set_signature(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let address = get_address_from_var_name(vars::ids::SIGNATURE, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        Ok(Uint2048::from(&self.private_inputs.signature).to_memory(vm, address.get_relocatable().unwrap())?)
    }
}

pub const HINT_SET_N: &str = "set_u2048(ids.n, dkim_input.n)";

impl CustomHintProcessor {
    pub fn hint_set_n(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let address = get_address_from_var_name(vars::ids::N, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        Ok(Uint2048::from(&self.private_inputs.n).to_memory(vm, address.get_relocatable().unwrap())?)
    }
}

pub const HINT_SET_HEADERS: &str = "segments.write_arg(ids.headers, dkim_input.headers)";

impl CustomHintProcessor {
    pub fn hint_set_headers(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let address = get_ptr_from_var_name(vars::ids::HEADERS, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        vm.load_data(
            address,
            &self
                .private_inputs
                .headers
                .iter()
                .map(|x| MaybeRelocatable::from(Felt252::from(*x)))
                .collect::<Vec<MaybeRelocatable>>(),
        )?;
        Ok(())
    }
}

pub const HINT_SET_HEADERS_LEN: &str = "memory[ap] = to_felt_or_relocatable(len(dkim_input.headers))";

impl CustomHintProcessor {
    pub fn hint_set_headers_len(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        _hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        insert_value_into_ap(vm, self.private_inputs.headers.len())?;
        Ok(())
    }
}

pub const HINT_SET_BODY: &str = "segments.write_arg(ids.body, dkim_input.body)";

impl CustomHintProcessor {
    pub fn hint_set_body(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let address = get_ptr_from_var_name(vars::ids::BODY, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        vm.load_data(
            address,
            &self
                .private_inputs
                .body
                .iter()
                .map(|x| MaybeRelocatable::from(Felt252::from(*x)))
                .collect::<Vec<MaybeRelocatable>>(),
        )?;
        Ok(())
    }
}

pub const HINT_SET_BODY_LEN: &str = "memory[ap] = to_felt_or_relocatable(len(dkim_input.body))";

impl CustomHintProcessor {
    pub fn hint_set_body_len(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        _hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        insert_value_into_ap(vm, self.private_inputs.body.len())?;
        Ok(())
    }
}

pub const HINT_SET_BODY_HASH_ADVICE: &str = "advice = dkim_input.body_hash_advice";

impl CustomHintProcessor {
    pub fn hint_set_body_hash_advice(
        &mut self,
        _vm: &mut VirtualMachine,
        exec_scopes: &mut ExecutionScopes,
        _hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        exec_scopes.insert_value::<Advice>(vars::scopes::ADVICE, self.private_inputs.body_hash_advice.clone());
        Ok(())
    }
}

pub const HINT_SET_DOMAIN_ADVICE: &str = "advice = dkim_input.domain_advice";

impl CustomHintProcessor {
    pub fn hint_set_domain_advice(
        &mut self,
        _vm: &mut VirtualMachine,
        exec_scopes: &mut ExecutionScopes,
        _hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        exec_scopes.insert_value::<Advice>(vars::scopes::ADVICE, self.private_inputs.domain_advice.clone());
        Ok(())
    }
}

pub const HINT_SET_BODY_ADVICE: &str = "advice = dkim_input.body_advice";

impl CustomHintProcessor {
    pub fn hint_set_body_advice(
        &mut self,
        _vm: &mut VirtualMachine,
        exec_scopes: &mut ExecutionScopes,
        _hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        exec_scopes.insert_value::<Advice>(vars::scopes::ADVICE, self.private_inputs.body_advice.clone());
        Ok(())
    }
}
