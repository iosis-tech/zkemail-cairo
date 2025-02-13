#![allow(async_fn_in_trait)]
#![warn(unused_extern_crates)]
#![warn(unused_crate_dependencies)]
#![forbid(unsafe_code)]

pub mod dkim;
pub mod hint_processor;
pub mod types;

#[cfg(test)]
pub mod tests;

use std::{env, fs, path::PathBuf, sync::Arc};

use cairo_vm::{
    cairo_run::{self, cairo_run_program},
    types::{layout_name::LayoutName, program::Program, relocatable::Relocatable},
    Felt252,
};
use cfdkim::{dns, header::HEADER, public_key, validate_header, DKIMError};
use clap::Parser;
use dkim::parse_dkim;
use hint_processor::CustomHintProcessor;
use mailparse::MailHeaderMap;
use tracing::{debug, info};
use trust_dns_resolver::TokioAsyncResolver;
use types::error::Error;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    #[clap(long = "trace_file", value_parser)]
    trace_file: Option<PathBuf>,
    #[structopt(long = "print_output")]
    print_output: bool,
    #[structopt(long = "memory_file")]
    memory_file: Option<PathBuf>,
    /// When using dynamic layout, it's parameters must be specified through a layout params file.
    #[clap(long = "layout", default_value = "all_cairo", value_enum)]
    layout: LayoutName,
    /// Required when using with dynamic layout.
    /// Ignored otherwise.
    #[clap(long = "cairo_layout_params_file", required_if_eq("layout", "dynamic"))]
    cairo_layout_params_file: Option<PathBuf>,
    #[structopt(long = "proof_mode")]
    proof_mode: bool,
    #[structopt(long = "raw_mail_file")]
    raw_mail_file: PathBuf,
    #[structopt(long = "secure_run")]
    secure_run: Option<bool>,
    #[clap(long = "air_public_input", requires = "proof_mode")]
    air_public_input: Option<PathBuf>,
    #[clap(
        long = "air_private_input",
        requires_all = ["proof_mode", "trace_file", "memory_file"]
    )]
    air_private_input: Option<PathBuf>,
    #[clap(
        long = "cairo_pie_output",
        // We need to add these air_private_input & air_public_input or else
        // passing cairo_pie_output + either of these without proof_mode will not fail
        conflicts_with_all = ["proof_mode", "air_private_input", "air_public_input"]
    )]
    cairo_pie_output: Option<PathBuf>,
    #[structopt(long = "allow_missing_builtins")]
    allow_missing_builtins: Option<bool>,
}

#[tokio::main(flavor = "multi_thread", worker_threads = 1)]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt::init();

    let args = Args::try_parse_from(std::env::args()).map_err(Error::Cli)?;

    // Init CairoRunConfig
    let cairo_run_config = cairo_run::CairoRunConfig {
        trace_enabled: args.trace_file.is_some() || args.air_public_input.is_some(),
        relocate_mem: args.memory_file.is_some() || args.air_public_input.is_some(),
        layout: args.layout,
        proof_mode: args.proof_mode,
        secure_run: args.secure_run,
        allow_missing_builtins: args.allow_missing_builtins,
        ..Default::default()
    };

    // Locate the compiled program file in the `OUT_DIR` folder.
    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR is not set"));
    let program_file_path = out_dir.join("cairo").join("compiled.json");

    let raw_mail = std::fs::read(args.raw_mail_file).map_err(Error::IO)?;

    // Load the Program
    let program = Program::from_bytes(&fs::read(program_file_path).map_err(Error::IO)?, Some(cairo_run_config.entrypoint))?;
    let email = mailparse::parse_mail(&raw_mail).unwrap();

    let dkim_headers = email.headers.get_all_headers(HEADER);
    let dkim_header = dkim_headers.first().unwrap();
    let dkim = validate_header(&String::from_utf8_lossy(dkim_header.get_value_raw())).unwrap();

    let resolver = TokioAsyncResolver::tokio_from_system_conf()
        .map_err(|err| DKIMError::UnknownInternalError(format!("failed to create DNS resolver: {}", err)))
        .unwrap();
    let resolver = dns::from_tokio_resolver(resolver);

    let logger = slog::Logger::root(slog::Discard, slog::o!());
    let dkim_public_key = public_key::retrieve_public_key(
        &logger,
        Arc::clone(&resolver),
        dkim.get_required_tag("d"),
        dkim.get_required_tag("s"),
    )
    .await
    .unwrap();

    let input = parse_dkim(dkim, email, dkim_public_key)?;

    let mut hint_processor = CustomHintProcessor::new(input);
    let mut cairo_runner = cairo_run_program(&program, &cairo_run_config, &mut hint_processor)?;

    debug!("{:?}", cairo_runner.get_execution_resources());

    if args.print_output {
        let mut outputs = Vec::new();

        let segment_index = cairo_runner.vm.get_output_builtin_mut()?.base();
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

        info!("{:#?}", outputs);
    }

    if let Some(ref file_name) = args.cairo_pie_output {
        cairo_runner
            .get_cairo_pie()
            .map_err(|e| Error::CairoPie(e.to_string()))?
            .write_zip_file(file_name)?
    }

    Ok(())
}
