Dkim rsa-sha256 verification algorithm implementation in Cairo zkvm with rust cairo-vm support 

Project is equipped with parsing logic for raw email data and generates a trace of cairocpu ready for proving

```sh
cargo run -r compiled.json --program_input program_input.json --layout recursive --cairo_pie_output pie.zip --secure_run true
```