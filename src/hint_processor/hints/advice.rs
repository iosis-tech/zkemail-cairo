use std::collections::HashMap;

use cairo_vm::{
    hint_processor::builtin_hint_processor::{builtin_hint_processor_definition::HintProcessorData, hint_utils::insert_value_into_ap},
    types::exec_scope::ExecutionScopes,
    vm::{errors::hint_errors::HintError, vm_core::VirtualMachine},
    Felt252,
};

use super::vars;
use crate::types::Advice;

pub const HINT_SET_ADVICE_A_QUO: &str = "memory[ap] = to_felt_or_relocatable(advice.a_quo)";

pub fn hint_set_advice_a_quo(
    vm: &mut VirtualMachine,
    exec_scopes: &mut ExecutionScopes,
    _hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let advice = exec_scopes.get::<Advice>(vars::scopes::ADVICE)?;
    insert_value_into_ap(vm, Felt252::from(advice.a_quo))?;
    Ok(())
}

pub const HINT_SET_ADVICE_A_REM: &str = "memory[ap] = to_felt_or_relocatable(advice.a_rem)";

pub fn hint_set_advice_a_rem(
    vm: &mut VirtualMachine,
    exec_scopes: &mut ExecutionScopes,
    _hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let advice = exec_scopes.get::<Advice>(vars::scopes::ADVICE)?;
    insert_value_into_ap(vm, Felt252::from(advice.a_rem))?;
    Ok(())
}

pub const HINT_SET_ADVICE_B_QUO: &str = "memory[ap] = to_felt_or_relocatable(advice.b_quo)";

pub fn hint_set_advice_b_quo(
    vm: &mut VirtualMachine,
    exec_scopes: &mut ExecutionScopes,
    _hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let advice = exec_scopes.get::<Advice>(vars::scopes::ADVICE)?;
    insert_value_into_ap(vm, Felt252::from(advice.b_quo))?;
    Ok(())
}

pub const HINT_SET_ADVICE_B_REM: &str = "memory[ap] = to_felt_or_relocatable(advice.b_rem)";

pub fn hint_set_advice_b_rem(
    vm: &mut VirtualMachine,
    exec_scopes: &mut ExecutionScopes,
    _hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let advice = exec_scopes.get::<Advice>(vars::scopes::ADVICE)?;
    insert_value_into_ap(vm, Felt252::from(advice.b_rem))?;
    Ok(())
}
