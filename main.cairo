%builtins output range_check bitwise

from base64 import base64_decode
from extract import extract_bytes, bytes_len
from pkcs1_v1_5 import pkcs_expected_hash
from sha256 import sha256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.uint256 import uint256_eq
from uint2048 import Uint2048, uint2048_eq, uint2048_pow_mod_recursive
from uint256 import uint256_from_u8_be, uint256_from_u32_be

func main{output_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;

    local signature: Uint2048;
    %{ set_u2048(ids.signature, dkim_input.signature) %}
    local n: Uint2048;
    %{ set_u2048(ids.n, dkim_input.n) %}

    let (local headers) = alloc();
    %{ segments.write_arg(ids.headers, dkim_input.headers) %}
    tempvar headers_len = nondet %{ len(dkim_input.headers) %};

    let (local body) = alloc();
    %{ segments.write_arg(ids.body, dkim_input.body) %}
    tempvar body_len = nondet %{ len(dkim_input.body) %};

    %{ advice = dkim_input.body_hash_advice %}
    let (local b64_body_hash) = alloc();
    extract_bytes(
        headers,
        b64_body_hash,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local b64_body_hash_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    let (local body_hash_bytes) = alloc();
    let body_hash_bytes_len = base64_decode(b64_body_hash, b64_body_hash_len, body_hash_bytes);
    let (header_body_hash) = uint256_from_u8_be(body_hash_bytes);

    let (local body_hash_ptr, local body_hash_len) = sha256(body, body_len);
    let (calculated_body_hash) = uint256_from_u32_be(body_hash_ptr);

    let (eq) = uint256_eq(header_body_hash, calculated_body_hash);
    assert eq = 1;

    let (local headers_hash_ptr, local headers_hash_len) = sha256(headers, headers_len);
    let (calculated_headers_hash) = uint256_from_u32_be(headers_hash_ptr);

    let expected_hash = pkcs_expected_hash(calculated_headers_hash);

    let (calculated_hash) = uint2048_pow_mod_recursive(signature, 65537, n);

    let eq = uint2048_eq(calculated_hash, expected_hash);
    assert eq = 1;

    %{ advice = dkim_input.domain_advice %}
    let (local domain) = alloc();
    extract_bytes(
        headers,
        domain,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local domain_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    %{ advice = dkim_input.body_advice %}
    let (local body_str) = alloc();
    extract_bytes(
        body,
        body_str,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local body_str_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    %{ print("domain: ", bytes(memory.get_range(ids.domain, ids.domain_len)).decode('utf-8')) %}
    %{ print("body: ", bytes(memory.get_range(ids.body_str, ids.body_str_len)).decode('utf-8')) %}

    // assert [output_ptr] = domain_len;
    // let output_ptr = output_ptr + 1;
    // memcpy(output_ptr, domain, domain_len);
    // let output_ptr = output_ptr + domain_len;

    // assert [output_ptr] = body_str_len;
    // let output_ptr = output_ptr + 1;
    // memcpy(output_ptr, body_str, body_str_len);
    // let output_ptr = output_ptr + body_str_len;

    return ();
}
