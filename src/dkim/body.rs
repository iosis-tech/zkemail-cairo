use cfdkim::{
    canonicalization::{self, canonicalize_body_relaxed, canonicalize_body_simple},
    DKIMError,
};

pub(crate) fn compute_body_bytes<'a>(
    canonicalization_type: canonicalization::Type,
    length: Option<String>,
    email: &'a mailparse::ParsedMail<'a>,
) -> Result<Vec<u8>, DKIMError> {
    let body = email.get_body_raw().unwrap();

    let mut canonicalized_body = if canonicalization_type == canonicalization::Type::Simple {
        canonicalize_body_simple(&body)
    } else {
        canonicalize_body_relaxed(&body)
    };
    if let Some(length) = length {
        let length = length
            .parse::<usize>()
            .map_err(|err| DKIMError::SignatureSyntaxError(format!("invalid length: {}", err)))?;
        canonicalized_body.truncate(length);
    };

    Ok(canonicalized_body)
}
