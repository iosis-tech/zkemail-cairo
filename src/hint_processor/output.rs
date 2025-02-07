use std::collections::HashMap;

use cairo_vm::{
    hint_processor::builtin_hint_processor::{
        builtin_hint_processor_definition::HintProcessorData,
        hint_utils::{get_integer_from_var_name, get_ptr_from_var_name},
    },
    types::exec_scope::ExecutionScopes,
    vm::{errors::hint_errors::HintError, vm_core::VirtualMachine},
    Felt252,
};

use super::{hints::vars, CustomHintProcessor};

pub const PRINT_DOMAIN: &str = "print(\"domain: \", bytes(memory.get_range(ids.domain, ids.domain_len)).decode('utf-8'))";

impl CustomHintProcessor {
    pub fn print_domain(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let data = get_ptr_from_var_name(vars::ids::DOMAIN, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        let data_len = get_integer_from_var_name(vars::ids::DOMAIN_LEN, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        let bytes: Vec<u8> = vm
            .get_integer_range(data, data_len.try_into().unwrap())?
            .into_iter()
            .map(|x| *x.to_bytes_be().last().unwrap())
            .collect();
        println!("domain: {}", String::from_utf8_lossy(&bytes));
        Ok(())
    }
}

pub const PRINT_DARN: &str = "print(\"darn: \", bytes(memory.get_range(ids.darn, ids.darn_len)).decode('utf-8'))";

impl CustomHintProcessor {
    pub fn print_darn(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let data = get_ptr_from_var_name(vars::ids::DARN, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        let data_len = get_integer_from_var_name(vars::ids::DARN_LEN, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        let bytes: Vec<u8> = vm
            .get_integer_range(data, data_len.try_into().unwrap())?
            .into_iter()
            .map(|x| *x.to_bytes_be().last().unwrap())
            .collect();
        println!("darn: {}", String::from_utf8_lossy(&bytes));
        Ok(())
    }
}

pub const PRINT_BODY: &str = "print(\"body: \", bytes(memory.get_range(ids.body_str, ids.body_str_len)).decode('utf-8'))";

impl CustomHintProcessor {
    pub fn print_body(
        &mut self,
        vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        hint_data: &HintProcessorData,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        let data = get_ptr_from_var_name(vars::ids::BODY_STR, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        let data_len = get_integer_from_var_name(vars::ids::BODY_STR_LEN, vm, &hint_data.ids_data, &hint_data.ap_tracking)?;
        let bytes: Vec<u8> = vm
            .get_integer_range(data, data_len.try_into().unwrap())?
            .into_iter()
            .map(|x| *x.to_bytes_be().last().unwrap())
            .collect();
        println!("body: {}", String::from_utf8_lossy(&bytes));
        Ok(())
    }
}
