use std::{
    collections::HashMap,
    ops::{Shl, Shr},
};

use cairo_type_derive::FieldOffsetGetters;
use cairo_vm::{
    hint_processor::builtin_hint_processor::{builtin_hint_processor_definition::HintProcessorData, hint_utils::get_address_from_var_name},
    types::{exec_scope::ExecutionScopes, relocatable::Relocatable},
    vm::{
        errors::{hint_errors::HintError, memory_errors::MemoryError},
        vm_core::VirtualMachine,
    },
    Felt252,
};
use num_bigint::BigUint;
use num_integer::Integer;

use super::{u1024::Uint1024, vars};
use crate::hint_processor::hints::CairoType;

#[derive(FieldOffsetGetters, Default, Debug)]
pub struct Uint2048 {
    pub low: Uint1024,
    pub high: Uint1024,
}

impl From<&BigUint> for Uint2048 {
    fn from(value: &BigUint) -> Self {
        debug_assert!(value.bits() <= 2048);
        let mask = BigUint::from(1_u32).shl(1024_u32) - BigUint::from(1_u32);
        let low = Uint1024::from(&(value.shr(0_u32) & &mask));
        let high = Uint1024::from(&(value.shr(1024_u32) & &mask));
        Self { low, high }
    }
}

impl From<Uint2048> for BigUint {
    fn from(val: Uint2048) -> Self {
        let low: BigUint = val.low.into();
        let high: BigUint = val.high.into();
        low + high.shl(1024_u32)
    }
}

impl CairoType for Uint2048 {
    fn from_memory(vm: &VirtualMachine, address: Relocatable) -> Result<Self, MemoryError> {
        let low = Uint1024::from_memory(vm, (address + Uint2048::low_offset())?)?;
        let high = Uint1024::from_memory(vm, (address + Uint2048::high_offset())?)?;
        Ok(Self { low, high })
    }
    fn to_memory(&self, vm: &mut VirtualMachine, address: Relocatable) -> Result<(), MemoryError> {
        self.low.to_memory(vm, (address + Uint2048::low_offset())?)?;
        self.high.to_memory(vm, (address + Uint2048::high_offset())?)?;
        Ok(())
    }
    fn n_fields() -> usize {
        2
    }
}

pub const DIV_MOD: &str = "a = get_u2048(ids.a)\nb = get_u2048(ids.b)\ndiv = get_u2048(ids.div)\n\nquo, rem = divmod(a * b, div)\n\nset_u2048(ids.quo_low, (quo >> 2048*0) & ((1 << 2048) - 1))\nset_u2048(ids.quo_high, (quo >> 2048*1) & ((1 << 2048) - 1))\nset_u2048(ids.rem, rem)";

pub fn div_mod(
    vm: &mut VirtualMachine,
    _exec_scopes: &mut ExecutionScopes,
    hint_data: &HintProcessorData,
    _constants: &HashMap<String, Felt252>,
) -> Result<(), HintError> {
    let a_ptr = get_address_from_var_name(vars::ids::A, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();
    let b_ptr = get_address_from_var_name(vars::ids::B, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();
    let div_ptr = get_address_from_var_name(vars::ids::DIV, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();

    let quo_low_ptr = get_address_from_var_name(vars::ids::QUO_LOW, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();
    let quo_high_ptr = get_address_from_var_name(vars::ids::QUO_HIGH, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();
    let rem_ptr = get_address_from_var_name(vars::ids::REM, vm, &hint_data.ids_data, &hint_data.ap_tracking)?
        .get_relocatable()
        .unwrap();

    let a: BigUint = Uint2048::from_memory(vm, a_ptr)?.into();
    let b: BigUint = Uint2048::from_memory(vm, b_ptr)?.into();
    let div: BigUint = Uint2048::from_memory(vm, div_ptr)?.into();

    let (quo, rem) = (a.clone() * b.clone()).div_rem(&div);

    let mask = BigUint::from(1_u32).shl(2048_u32) - BigUint::from(1_u32);

    let quo_low = quo.clone().shr(0_u32) & &mask;
    let quo_high = quo.shr(2048_u32) & &mask;
    Uint2048::from(&quo_low).to_memory(vm, quo_low_ptr)?;
    Uint2048::from(&quo_high).to_memory(vm, quo_high_ptr)?;
    Uint2048::from(&rem).to_memory(vm, rem_ptr)?;

    Ok(())
}
