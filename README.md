# DKIM RSA-SHA256 Verification Algorithm in Cairo ZKVM

This project implements the DKIM (DomainKeys Identified Mail) RSA-SHA256 verification algorithm using the Cairo zkVM (Zero-Knowledge Virtual Machine). The project is designed to parse raw email data, generate a trace of Cairo CPU operations, and produce a PIE output for prover stage.

## Overview

DKIM is an email authentication method designed to detect email spoofing. It allows the receiver to check that an email was indeed sent and authorized by the owner of the domain. This project focuses on the RSA-SHA256 signature verification process, which is a common method used in DKIM.

The project is implemented in Cairo, a language designed for creating provable programs, the implementation includes parsing logic for raw email data, handling of cryptographic operations, and generation of a trace that can be used for proving.

## Getting Started

### Setup

1. **Clone the Repository**:
   ```bash
   https://github.com/iosis-tech/zkemail-cairo.git
   cd zkemail-cairo
   ```

2. **Set Up Cairo0 compiler**:
   ```bash
   make
   ```

3. **Run the example verifications**:
   ```bash
   cargo test -r
   ```

### Running the DKIM Verification

To perform the verification on a raw email file:

```bash
cargo run -r -- --cairo_pie_output pie.zip --secure_run true --raw_mail_file raw_email.eml --print_output
```

- **Parameters:**
  - `raw_email.eml`: The raw email content to verify.
  - `pie.zip`: Output file containing the generated Cairo PIE file.

### Generating a Proof with STWO

After generating the PIE file, you can create a proof:

- **Using the Web Prover:**
  - Visit [stwo-web-stark](http://demo.stwo.iosis.tech/) - WASM web interface client side prover.
  - Additional details are available in the [stwo-web-stark repository](https://github.com/Okm165/stwo-web-stark).

- **Locally:**
  Run the following command to generate the proof with [STWO](https://github.com/starkware-libs/stwo-cairo) cli:
  ```bash
  run_and_prove --run_from_cairo_pie pie.zip --proof_path proof.json
  ```
  The proof will be saved to `proof.json`.

## Contributing

Contributions and guidance are very welcome!
