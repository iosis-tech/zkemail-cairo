from uint512 import Uint512, uint512_add, uint512_mul, uint512_zero

struct Uint1024 {
    low: Uint512,
    high: Uint512,
}

func uint1024_zero() -> (res: Uint1024) {
    let (res) = uint512_zero();
    return (res=Uint1024(low=res, high=res));
}

func uint1024_add{range_check_ptr}(a: Uint1024, b: Uint1024, c_in: felt) -> (c: Uint1024, c_out: felt) {
    let (ll, c) = uint512_add(a.low, b.low, c_in);
    let (hh, c_out) = uint512_add(a.high, b.high, c);
    return (c=Uint1024(low=ll, high=hh), c_out=c_out);
}

// TODO change to Karatsuba algorithm
func uint1024_mul{range_check_ptr}(a: Uint1024, b: Uint1024) -> (c: Uint1024, d: Uint1024) {
    let (low_part_low, low_part_high) = uint512_mul(a.low, b.low);
    let (low_high_cross_low, low_high_cross_high) = uint512_mul(a.low, b.high);
    let (high_low_cross_low, high_low_cross_high) = uint512_mul(a.high, b.low);
    let (high_part_low, high_part_high) = uint512_mul(a.high, b.high);

    let (cross_low_sum, cross_carry) = uint512_add(low_high_cross_low, high_low_cross_low, 0);
    let (cross_high_sum, cross_carry_1) = uint512_add(low_high_cross_high, high_low_cross_high, cross_carry);

    let (low_part_high_updated, carry1) = uint512_add(low_part_high, cross_low_sum, 0);
    let (low_part_with_cross_high, carry2) = uint512_add(cross_high_sum, high_part_low, carry1);

    let (final_high_part, _) = uint512_add(low_part_with_cross_high, high_part_high, carry2 + cross_carry_1);

    return (
        c=Uint1024(low=low_part_low, high=low_part_high_updated), 
        d=Uint1024(low=high_low_cross_high, high=final_high_part)
    );
}
