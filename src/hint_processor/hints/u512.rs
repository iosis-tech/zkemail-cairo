use std::ops::{Shl, Shr};

use cairo_type_derive::FieldOffsetGetters;
use cairo_vm::vm::vm_core::VirtualMachine;
use num_bigint::BigUint;

use super::u256::Uint256;
use crate::hint_processor::hints::{CairoType, MemoryError, Relocatable};

#[derive(FieldOffsetGetters, Default, Debug)]
pub struct Uint512 {
    pub low: Uint256,
    pub high: Uint256,
}

impl From<&BigUint> for Uint512 {
    fn from(value: &BigUint) -> Self {
        debug_assert!(value.bits() <= 512);
        let mask = BigUint::from(1_u32).shl(256_u32) - BigUint::from(1_u32);
        let low = Uint256::from(&(value.shr(0_u32) & &mask));
        let high = Uint256::from(&(value.shr(256_u32) & &mask));
        Self { low, high }
    }
}

impl From<Uint512> for BigUint {
    fn from(val: Uint512) -> Self {
        let low: BigUint = val.low.into();
        let high: BigUint = val.high.into();
        low + high.shl(256_u32)
    }
}

impl CairoType for Uint512 {
    fn from_memory(vm: &VirtualMachine, address: Relocatable) -> Result<Self, MemoryError> {
        let low = Uint256::from_memory(vm, (address + Uint512::low_offset())?)?;
        let high = Uint256::from_memory(vm, (address + Uint512::high_offset())?)?;
        Ok(Self { low, high })
    }
    fn to_memory(&self, vm: &mut VirtualMachine, address: Relocatable) -> Result<(), MemoryError> {
        self.low.to_memory(vm, (address + Uint512::low_offset())?)?;
        self.high.to_memory(vm, (address + Uint512::high_offset())?)?;
        Ok(())
    }
    fn n_fields() -> usize {
        2
    }
}
