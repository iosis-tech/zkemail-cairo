use std::{env, fs, path::PathBuf};

use cairo_vm::{
    cairo_run::{self, cairo_run_program},
    types::{program::Program, relocatable::Relocatable},
    Felt252,
};
use cfdkim::{header::HEADER, validate_header, DkimPrivateKey, DkimPublicKey, SignerBuilder};
use mailparse::{parse_header, MailHeaderMap};
use rand_chacha::{rand_core::SeedableRng, ChaCha8Rng};
use rsa::RsaPrivateKey;

use crate::{dkim::parse_dkim, hint_processor::CustomHintProcessor};

fn test_logger() -> slog::Logger {
    slog::Logger::root(slog::Discard, slog::o!())
}

const TEST_DOMAIN: &str = "test.domain";
const TEST_SELECTOR: &str = "test.selector";

#[tokio::test(flavor = "multi_thread", worker_threads = 1)]
async fn test_email_cairo0_verification() {
    let logger = test_logger();
    let mut rng = ChaCha8Rng::from_seed([42; 32]);

    let private_key = RsaPrivateKey::new(&mut rng, 2048).unwrap();
    let public_key = private_key.to_public_key();

    let mut email = mailparse::parse_mail(
        concat!(
            "Subject: This is a test email\n",
            "From: Sven Sauleau <sven@cloudflare.com>\n",
            "MIME-Version: 1.0\n",
            "Date: Mon, 3 Feb 2025 21:39:34 +0100\n",
            "To: Dorian Finch <dorian@cloudflare.com>\n",
            "\n",
            "Hello Dorian",
        )
        .as_bytes(),
    )
    .unwrap();

    let signer = SignerBuilder::new()
        .with_signed_headers(&["From", "Subject", "MIME-Version", "Date", "To"])
        .unwrap()
        .with_private_key(DkimPrivateKey::Rsa(private_key))
        .with_selector(TEST_SELECTOR)
        .with_logger(&logger)
        .with_signing_domain(TEST_DOMAIN)
        .build()
        .unwrap();
    let header_string = signer.sign(&email).unwrap();
    let (header, _) = parse_header(header_string.as_bytes()).unwrap();
    println!("{:?}", header);
    email.headers.push(header);

    let body = String::from_utf8_lossy(&email.get_body_raw().unwrap()).to_string();

    let dkim_headers = email.headers.get_all_headers(HEADER);
    let dkim_header = dkim_headers.first().unwrap();
    let dkim = validate_header(&String::from_utf8_lossy(dkim_header.get_value_raw())).unwrap();

    let input = parse_dkim(dkim, email, DkimPublicKey::Rsa(public_key)).unwrap();

    // Init CairoRunConfig
    let cairo_run_config = cairo_run::CairoRunConfig {
        layout: cairo_vm::types::layout_name::LayoutName::recursive,
        ..Default::default()
    };

    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR is not set"));
    let program_file_path = out_dir.join("cairo").join("compiled.json");
    let program = Program::from_bytes(&fs::read(program_file_path).unwrap(), Some(cairo_run_config.entrypoint)).unwrap();

    let mut hint_processor = CustomHintProcessor::new(input);
    let mut cairo_runner = cairo_run_program(&program, &cairo_run_config, &mut hint_processor).unwrap();

    let mut outputs = Vec::new();

    let segment_index = cairo_runner.vm.get_output_builtin_mut().unwrap().base();
    let segment_size = cairo_runner.vm.segments.compute_effective_sizes()[segment_index];

    let mut iter = cairo_runner
        .vm
        .get_range(Relocatable::from((segment_index as isize, 0)), segment_size)
        .into_iter()
        .map(|v| v.clone().unwrap().get_int().unwrap());

    while let Some(v) = iter.next().map(|v| <Felt252 as TryInto<usize>>::try_into(v).unwrap()) {
        let alloc = (0..v)
            .map(|_| iter.next().map(|v| v.to_bytes_be()[31]).unwrap())
            .collect::<Vec<_>>();
        outputs.push(String::from_utf8_lossy(&alloc).to_string());
    }

    assert_eq!(outputs[0], TEST_DOMAIN);
    assert_eq!(outputs[1], body);
}
