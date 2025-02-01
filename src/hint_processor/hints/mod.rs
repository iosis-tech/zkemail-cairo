use std::collections::HashMap;

use cairo_vm::{
    hint_processor::builtin_hint_processor::builtin_hint_processor_definition::HintProcessorData,
    types::exec_scope::ExecutionScopes,
    vm::{errors::hint_errors::HintError, vm_core::VirtualMachine},
    Felt252,
};

pub mod advice;
pub mod u1024;
pub mod u2048;
pub mod u256;
pub mod u512;
pub mod vars;

pub type HintImpl = fn(&mut VirtualMachine, &mut ExecutionScopes, &HintProcessorData, &HashMap<String, Felt252>) -> Result<(), HintError>;

#[rustfmt::skip]
pub fn hints() -> HashMap<String, HintImpl> {
    let mut hints = HashMap::<String, HintImpl>::new();
    hints.insert(u1024::SET_U1024.into(), u1024::set_u1024);
    hints.insert(u2048::HINT_U2048.into(), u2048::hint_u2048);
    hints.insert(u2048::SET_U2048.into(), u2048::set_u2048);
    hints.insert(u256::HINT_U256.into(), u256::hint_u256);
    hints.insert(u256::SET_U256.into(), u256::set_u256);
    hints.insert(u512::SET_U512.into(), u512::set_u512);
    hints
}
