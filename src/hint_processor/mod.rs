use std::{any::Any, collections::HashMap};

use cairo_vm::{
    hint_processor::{
        builtin_hint_processor::builtin_hint_processor_definition::{BuiltinHintProcessor, HintProcessorData},
        hint_processor_definition::{HintExtension, HintProcessorLogic},
    },
    types::exec_scope::ExecutionScopes,
    vm::{errors::hint_errors::HintError, runners::cairo_runner::ResourceTracker, vm_core::VirtualMachine},
    Felt252,
};

use crate::types::RunInput;

pub mod hints;
pub mod input;
pub mod output;

pub type HintImpl = fn(&mut VirtualMachine, &mut ExecutionScopes, &HintProcessorData, &HashMap<String, Felt252>) -> Result<(), HintError>;

pub struct CustomHintProcessor {
    private_inputs: RunInput,
    builtin_hint_proc: BuiltinHintProcessor,
    hints: HashMap<String, HintImpl>,
}

impl CustomHintProcessor {
    pub fn new(private_inputs: RunInput) -> Self {
        Self {
            private_inputs,
            builtin_hint_proc: BuiltinHintProcessor::new_empty(),
            hints: Self::hints(),
        }
    }

    #[rustfmt::skip]
    pub fn hints() -> HashMap<String, HintImpl> {
        let mut hints = HashMap::<String, HintImpl>::new();
        hints.insert(hints::advice::HINT_SET_ADVICE_A_QUO.into(), hints::advice::hint_set_advice_a_quo);
        hints.insert(hints::advice::HINT_SET_ADVICE_A_REM.into(), hints::advice::hint_set_advice_a_rem);
        hints.insert(hints::advice::HINT_SET_ADVICE_B_QUO.into(), hints::advice::hint_set_advice_b_quo);
        hints.insert(hints::advice::HINT_SET_ADVICE_B_REM.into(), hints::advice::hint_set_advice_b_rem);
        hints.insert(hints::sha256::SHA256_INIT.into(), hints::sha256::sha256_init);
        hints.insert(hints::sha256::SHA256_LOOP.into(), hints::sha256::sha256_loop);
        hints.insert(hints::sha256::SHA256_FINALIZE.into(), hints::sha256::sha256_finalize);
        hints.insert(hints::u256::UINT256_ADD.into(), hints::u256::uint256_add);
        hints.insert(hints::u2048::DIV_MOD.into(), hints::u2048::div_mod);
        hints
    }
}

impl HintProcessorLogic for CustomHintProcessor {
    fn execute_hint(
        &mut self,
        _vm: &mut VirtualMachine,
        _exec_scopes: &mut ExecutionScopes,
        _hint_data: &Box<dyn Any>,
        _constants: &HashMap<String, Felt252>,
    ) -> Result<(), HintError> {
        unreachable!();
    }

    fn execute_hint_extensive(
        &mut self,
        vm: &mut VirtualMachine,
        exec_scopes: &mut ExecutionScopes,
        hint_data: &Box<dyn Any>,
        constants: &HashMap<String, Felt252>,
    ) -> Result<HintExtension, HintError> {
        if let Some(hpd) = hint_data.downcast_ref::<HintProcessorData>() {
            let hint_code = hpd.code.as_str();

            let res = match hint_code {
                input::HINT_SET_SIGNATURE => self.hint_set_signature(vm, exec_scopes, hpd, constants),
                input::HINT_SET_N => self.hint_set_n(vm, exec_scopes, hpd, constants),
                input::HINT_SET_HEADERS => self.hint_set_headers(vm, exec_scopes, hpd, constants),
                input::HINT_SET_HEADERS_LEN => self.hint_set_headers_len(vm, exec_scopes, hpd, constants),
                input::HINT_SET_BODY => self.hint_set_body(vm, exec_scopes, hpd, constants),
                input::HINT_SET_BODY_LEN => self.hint_set_body_len(vm, exec_scopes, hpd, constants),
                input::HINT_SET_BODY_ADVICE => self.hint_set_body_advice(vm, exec_scopes, hpd, constants),
                input::HINT_SET_DARN_ADVICE => self.hint_set_darn_advice(vm, exec_scopes, hpd, constants),
                input::HINT_SET_DOMAIN_ADVICE => self.hint_set_domain_advice(vm, exec_scopes, hpd, constants),
                input::HINT_SET_BODY_HASH_ADVICE => self.hint_set_body_hash_advice(vm, exec_scopes, hpd, constants),
                output::PRINT_DOMAIN => self.print_domain(vm, exec_scopes, hpd, constants),
                output::PRINT_DARN => self.print_darn(vm, exec_scopes, hpd, constants),
                output::PRINT_BODY_STR => self.print_body_str(vm, exec_scopes, hpd, constants),
                _ => Err(HintError::UnknownHint(hint_code.to_string().into_boxed_str())),
            };

            if !matches!(res, Err(HintError::UnknownHint(_))) {
                return res.map(|_| HintExtension::default());
            }

            if let Some(hint_impl) = self.hints.get(hint_code) {
                return hint_impl(vm, exec_scopes, hpd, constants).map(|_| HintExtension::default());
            }

            return self
                .builtin_hint_proc
                .execute_hint(vm, exec_scopes, hint_data, constants)
                .map(|_| HintExtension::default());
        }

        Err(HintError::WrongHintData)
    }
}

impl ResourceTracker for CustomHintProcessor {}
