use cairo_vm::{
    types::relocatable::Relocatable,
    vm::{errors::memory_errors::MemoryError, vm_core::VirtualMachine},
};

pub mod advice;
pub mod sha256;
pub mod u1024;
pub mod u2048;
pub mod u256;
pub mod u512;
pub mod vars;

pub trait CairoType: Sized {
    fn from_memory(vm: &VirtualMachine, address: Relocatable) -> Result<Self, MemoryError>;
    fn to_memory(&self, vm: &mut VirtualMachine, address: Relocatable) -> Result<(), MemoryError>;
    fn n_fields() -> usize;
}
