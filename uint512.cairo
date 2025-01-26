from uint256 import uint256_add
from starkware.cairo.common.uint256 import Uint256, uint256_mul

struct Uint512 {
    low: Uint256,
    high: Uint256,
}

func uint512_zero() -> (res: Uint512) {
    return (res=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0)));
}

func uint512_add{range_check_ptr}(a: Uint512, b: Uint512, c_in: felt) -> (c: Uint512, c_out: felt) {
    let (ll, c) = uint256_add(a.low, b.low, c_in);
    let (hh, c_out) = uint256_add(a.high, b.high, c);
    return (c=Uint512(low=ll, high=hh), c_out=c_out);
}

// TODO change to Karatsuba algorithm
func uint512_mul{range_check_ptr}(a: Uint512, b: Uint512) -> (c: Uint512, d: Uint512) {
    let (low_part_low, low_part_high) = uint256_mul(a.low, b.low);
    let (low_high_cross_low, low_high_cross_high) = uint256_mul(a.low, b.high);
    let (high_low_cross_low, high_low_cross_high) = uint256_mul(a.high, b.low);
    let (high_part_low, high_part_high) = uint256_mul(a.high, b.high);

    let (cross_low_sum, cross_carry) = uint256_add(low_high_cross_low, high_low_cross_low, 0);
    let (cross_high_sum, cross_carry_1) = uint256_add(low_high_cross_high, high_low_cross_high, cross_carry);

    let (low_part_high_updated, carry1) = uint256_add(low_part_high, cross_low_sum, 0);
    let (low_part_with_cross_high, carry2) = uint256_add(cross_high_sum, high_part_low, carry1);

    let (final_high_part, _) = uint256_add(low_part_with_cross_high, high_part_high, carry2 + cross_carry_1);

    return (
        c=Uint512(low=low_part_low, high=low_part_high_updated), 
        d=Uint512(low=high_low_cross_high, high=final_high_part)
    );
}
