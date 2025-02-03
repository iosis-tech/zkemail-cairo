use num_bigint::BigUint;
use serde::{Deserialize, Serialize};
use serde_with::{serde_as, DisplayFromStr};

pub mod error;

#[serde_as]
#[derive(Debug, Serialize, Deserialize)]
pub struct RunInput {
    pub body: Vec<u32>,
    pub headers: Vec<u32>,
    #[serde_as(as = "DisplayFromStr")]
    pub n: BigUint,
    #[serde_as(as = "DisplayFromStr")]
    pub signature: BigUint,
    pub body_advice: Advice,
    pub body_hash_advice: Advice,
    pub domain_advice: Advice,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Advice {
    pub a_quo: u32,
    pub a_rem: u32,
    pub b_quo: u32,
    pub b_rem: u32,
}
