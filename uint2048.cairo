from uint1024 import Uint1024, uint1024_add, uint1024_mul, uint1024_zero

struct Uint2048 {
    low: Uint1024,
    high: Uint1024,
}

func uint2048_zero() -> (res: Uint2048) {
    let (res) = uint1024_zero();
    return (res=Uint2048(low=res, high=res));
}

func uint2048_add{range_check_ptr}(a: Uint2048, b: Uint2048, c_in: felt) -> (c: Uint2048, c_out: felt) {
    let (ll, c) = uint1024_add(a.low, b.low, c_in);
    let (hh, c_out) = uint1024_add(a.high, b.high, c);
    return (c=Uint2048(low=ll, high=hh), c_out=c_out);
}

// TODO change to Karatsuba algorithm
func uint2048_mul{range_check_ptr}(a: Uint2048, b: Uint2048) -> (c: Uint2048, d: Uint2048) {
    let (low_part_low, low_part_high) = uint1024_mul(a.low, b.low);
    let (low_high_cross_low, low_high_cross_high) = uint1024_mul(a.low, b.high);
    let (high_low_cross_low, high_low_cross_high) = uint1024_mul(a.high, b.low);
    let (high_part_low, high_part_high) = uint1024_mul(a.high, b.high);

    let (cross_low_sum, cross_carry) = uint1024_add(low_high_cross_low, high_low_cross_low, 0);
    let (cross_high_sum, cross_carry_1) = uint1024_add(low_high_cross_high, high_low_cross_high, cross_carry);

    let (low_part_high_updated, carry1) = uint1024_add(low_part_high, cross_low_sum, 0);
    let (low_part_with_cross_high, carry2) = uint1024_add(cross_high_sum, high_part_low, carry1);

    let (final_high_part, _) = uint1024_add(low_part_with_cross_high, high_part_high, carry2 + cross_carry_1);

    return (
        c=Uint2048(low=low_part_low, high=low_part_high_updated), 
        d=Uint2048(low=high_low_cross_high, high=final_high_part)
    );
}