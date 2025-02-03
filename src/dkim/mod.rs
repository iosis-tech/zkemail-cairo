use std::borrow::Cow;

use base64::{prelude::BASE64_STANDARD, Engine};
use mail_auth::{
    common::{headers::Writable, verify::VerifySignature},
    dkim::verify::Verifier,
    AuthenticatedMessage, MessageAuthenticator,
};
use num_bigint::BigUint;
use regex::bytes::Regex;
use rsa::{pkcs8::DecodePublicKey, traits::PublicKeyParts, RsaPublicKey};

use crate::types::{error::Error, Advice, RunInput};

#[cfg(test)]
pub mod tests;

pub async fn parse_dkim(authenticator: &MessageAuthenticator, authenticated_message: &AuthenticatedMessage<'_>) -> Result<RunInput, Error> {
    // limit inputs to single dkim verification
    let (cb, _ha, l, _bh) = authenticated_message.body_hashes.first().unwrap();

    let mut body_bytes = Vec::with_capacity(1024);
    cb.canonical_body(authenticated_message.raw_body(), *l).write(&mut body_bytes);
    let body_len = body_bytes.len();
    pad_sha256(&mut body_bytes);

    let body_advice = Advice {
        a_quo: 0,
        a_rem: 0,
        b_quo: body_len as u32 / 4,
        b_rem: body_len as u32 % 4,
    };

    let header = authenticated_message.dkim_headers.first().unwrap();
    let signature = header.header.as_ref().unwrap();
    let txt_lookup = authenticator.0.txt_lookup(signature.domain_key()).await.unwrap();

    let records: Vec<_> = txt_lookup
        .as_lookup()
        .record_iter()
        .filter_map(|r| {
            let txt_data = r.data()?.as_txt()?.txt_data();
            match txt_data.len() {
                1 => Some(Cow::from(txt_data[0].as_ref())),
                0 => None,
                _ => {
                    let mut entry = Vec::with_capacity(255 * txt_data.len());
                    for data in txt_data {
                        entry.extend_from_slice(data);
                    }
                    Some(Cow::from(entry))
                }
            }
        })
        .collect();

    let re = Regex::new(r"p=([a-zA-Z0-9+/=]+)").unwrap();
    let caps = re.captures(&records[0]).unwrap();

    let start_index = caps.get(0).unwrap().start();
    let end_index = caps.get(0).unwrap().end();

    let rsa_public_key =
        RsaPublicKey::from_public_key_der(&BASE64_STANDARD.decode(&records[0][start_index + 2..end_index]).unwrap()).unwrap();

    let dkim_hdr_value = header.value.strip_signature();
    let headers = authenticated_message.signed_headers(&signature.h, header.name, &dkim_hdr_value);
    let mut header_bytes = Vec::with_capacity(1024);
    signature.ch.canonicalize_headers(headers, &mut header_bytes);

    pad_sha256(&mut header_bytes);

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

    Ok(RunInput {
        body: body_bytes
            .chunks(4)
            .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
            .collect::<Vec<u32>>(),
        body_advice,
        body_hash_advice,
        domain_advice,
        headers: header_bytes
            .chunks(4)
            .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
            .collect::<Vec<u32>>(),
        n: BigUint::from_bytes_be(&rsa_public_key.n().to_bytes_be()),
        signature: BigUint::from_bytes_be(signature.signature()),
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
