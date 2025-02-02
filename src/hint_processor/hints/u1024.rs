use std::ops::{Shl, Shr};

use cairo_type_derive::FieldOffsetGetters;
use cairo_vm::{
    types::relocatable::Relocatable,
    vm::{errors::memory_errors::MemoryError, vm_core::VirtualMachine},
};
use num_bigint::BigUint;

use super::u512::Uint512;
use crate::hint_processor::hints::CairoType;

#[derive(FieldOffsetGetters, Default, Debug)]
pub struct Uint1024 {
    pub low: Uint512,
    pub high: Uint512,
}

impl From<&BigUint> for Uint1024 {
    fn from(value: &BigUint) -> Self {
        debug_assert!(value.bits() <= 1024);
        let mask = BigUint::from(1_u32).shl(512_u32) - BigUint::from(1_u32);
        let low = Uint512::from(&(value.shr(0_u32) & &mask));
        let high = Uint512::from(&(value.shr(512_u32) & &mask));
        Self { low, high }
    }
}

impl From<Uint1024> for BigUint {
    fn from(val: Uint1024) -> Self {
        let low: BigUint = val.low.into();
        let high: BigUint = val.high.into();
        low + high.shl(512_u32)
    }
}

impl CairoType for Uint1024 {
    fn from_memory(vm: &VirtualMachine, address: Relocatable) -> Result<Self, MemoryError> {
        let low = Uint512::from_memory(vm, (address + Uint1024::low_offset())?)?;
        let high = Uint512::from_memory(vm, (address + Uint1024::high_offset())?)?;
        Ok(Self { low, high })
    }
    fn to_memory(&self, vm: &mut VirtualMachine, address: Relocatable) -> Result<(), MemoryError> {
        self.low.to_memory(vm, (address + Uint1024::low_offset())?)?;
        self.high.to_memory(vm, (address + Uint1024::high_offset())?)?;
        Ok(())
    }
    fn n_fields() -> usize {
        2
    }
}
