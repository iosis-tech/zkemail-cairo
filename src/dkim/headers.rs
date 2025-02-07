use cfdkim::{
    canonicalization::{self, canonicalize_header_relaxed, canonicalize_header_simple},
    hash::select_headers,
    header::{DKIMHeader, HEADER},
    DKIMError,
};

pub(crate) fn compute_headers_bytes<'a, 'b>(
    canonicalization_type: canonicalization::Type,
    headers: &'b str,
    dkim_header: &'b DKIMHeader,
    email: &'a mailparse::ParsedMail<'a>,
) -> Result<Vec<u8>, DKIMError> {
    let mut input = Vec::new();

    // Add the headers defined in `h=` in the hash
    for (key, value) in select_headers(headers, email)? {
        let canonicalized_value = if canonicalization_type == canonicalization::Type::Simple {
            canonicalize_header_simple(&key, value)
        } else {
            canonicalize_header_relaxed(&key, value)
        };
        input.extend_from_slice(&canonicalized_value);
    }

    // Add the DKIM-Signature header in the hash. Remove the value of the
    // signature (b) first.
    {
        let sign = dkim_header.get_raw_tag("b").unwrap();
        let value = dkim_header.raw_bytes.replace(&sign, "");
        let mut canonicalized_value = if canonicalization_type == canonicalization::Type::Simple {
            canonicalize_header_simple(HEADER, value.as_bytes())
        } else {
            canonicalize_header_relaxed(HEADER, value.as_bytes())
        };

        // remove trailing "\r\n"
        canonicalized_value.truncate(canonicalized_value.len() - 2);

        input.extend_from_slice(&canonicalized_value);
    }

    Ok(input)
}
