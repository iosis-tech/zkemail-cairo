use base64::{engine::general_purpose, Engine};
use cfdkim::{header::DKIMHeader, parser, DKIMError, DkimPublicKey};
use num_bigint::BigUint;
use regex::bytes::Regex;
use rsa::traits::PublicKeyParts;

pub mod body;
pub mod headers;

use crate::types::{error::Error, Advice, RunInput};

pub fn parse_dkim(dkim: DKIMHeader, email: mailparse::ParsedMail<'_>, dkim_public_key: DkimPublicKey) -> Result<RunInput, Error> {
    let (header_canonicalization_type, body_canonicalization_type) = parser::parse_canonicalization(dkim.get_tag("c")).unwrap();

    let mut body_bytes = body::compute_body_bytes(body_canonicalization_type.clone(), dkim.get_tag("l"), &email).unwrap();

    let body_advice = Advice {
        a_quo: 0,
        a_rem: 0,
        b_quo: body_bytes.len() as u32 / 4,
        b_rem: body_bytes.len() as u32 % 4,
    };

    pad_sha256(&mut body_bytes);

    let mut header_bytes =
        headers::compute_headers_bytes(header_canonicalization_type.clone(), &dkim.get_required_tag("h"), &dkim, &email).unwrap();
    pad_sha256(&mut header_bytes);

    let re = Regex::new(r"d=([a-zA-Z0-9.-]+);").unwrap();
    let caps = re.captures(&header_bytes).unwrap();

    let start_index = caps.get(0).unwrap().start() + 2;
    let end_index = caps.get(0).unwrap().end() - 1;

    let domain_advice = Advice {
        a_quo: start_index as u32 / 4,
        a_rem: start_index as u32 % 4,
        b_quo: end_index as u32 / 4,
        b_rem: end_index as u32 % 4,
    };

    let re = Regex::new(r"bh=([A-Za-z0-9+/=]+);").unwrap();
    let caps = re.captures(&header_bytes).unwrap();

    let start_index = caps.get(0).unwrap().start() + 3;
    let end_index = caps.get(0).unwrap().end() - 1;

    let body_hash_advice = Advice {
        a_quo: start_index as u32 / 4,
        a_rem: start_index as u32 % 4,
        b_quo: end_index as u32 / 4,
        b_rem: end_index as u32 % 4,
    };

    let n = match dkim_public_key {
        cfdkim::DkimPublicKey::Rsa(rsa) => rsa.n().to_owned(),
        _ => panic!(""),
    };

    let signature = general_purpose::STANDARD
        .decode(dkim.get_required_tag("b"))
        .map_err(|err| DKIMError::SignatureSyntaxError(format!("failed to decode signature: {}", err)))
        .unwrap();

    Ok(RunInput {
        body: body_bytes
            .chunks(4)
            .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
            .collect::<Vec<u32>>(),
        body_hash_advice,
        domain_advice,
        body_advice,
        headers: header_bytes
            .chunks(4)
            .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
            .collect::<Vec<u32>>(),
        n: BigUint::from_bytes_be(&n.to_bytes_be()),
        signature: BigUint::from_bytes_be(&signature),
    })
}

// pad sha256 preimage
fn pad_sha256(message: &mut Vec<u8>) {
    let length = (message.len() * 8) as u64;
    message.push(0x80);

    while ((message.len() * 8) + 64) % 512 != 0 {
        message.push(0x00);
    }

    message.extend_from_slice(&length.to_be_bytes());

    assert!((message.len() * 8) % 512 == 0, "Padding did not complete properly!");
}
