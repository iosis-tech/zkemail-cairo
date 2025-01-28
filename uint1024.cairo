from uint512 import (
    Uint512,
    uint512_add,
    uint512_mul,
    uint512_zero,
    uint512_check,
    uint512_eq,
    uint512_one,
)
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.bitwise import bitwise_and

struct Uint1024 {
    low: Uint512,
    high: Uint512,
}

func uint1024_check{range_check_ptr}(a: Uint1024) {
    uint512_check(a.low);
    uint512_check(a.high);
    return ();
}

func uint1024_zero() -> (res: Uint1024) {
    let (res) = uint512_zero();
    return (res=Uint1024(low=res, high=res));
}

func uint1024_one() -> (one: Uint1024) {
    let (one) = uint512_one();
    let (res) = uint512_zero();
    return (one=Uint1024(low=one, high=res));
}

func uint1024_eq{range_check_ptr}(a: Uint1024, b: Uint1024) -> felt {
    let eq = uint512_eq(a.high, b.high);
    if (eq != 1) {
        return 0;
    }
    let eq = uint512_eq(a.low, b.low);
    if (eq != 1) {
        return 0;
    }
    return 1;
}

func uint1024_add{range_check_ptr}(a: Uint1024, b: Uint1024, c_in: felt) -> (
    c: Uint1024, c_out: felt
) {
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
    let (cross_high_sum, cross_carry_1) = uint512_add(
        low_high_cross_high, high_low_cross_high, cross_carry
    );

    let (low_part_high_updated, carry1) = uint512_add(low_part_high, cross_low_sum, 0);
    let (low_part_with_cross_high, carry2) = uint512_add(cross_high_sum, high_part_low, carry1);

    let (res) = uint512_zero();
    let (final_high_part, _) = uint512_add(res, high_part_high, carry2 + cross_carry_1);

    return (
        c=Uint1024(low=low_part_low, high=low_part_high_updated),
        d=Uint1024(low=low_part_with_cross_high, high=final_high_part),
    );
}

func uint1024_mul_div_mod{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    a: Uint1024, b: Uint1024, div: Uint1024
) -> (quotient_low: Uint1024, quotient_high: Uint1024, remainder: Uint1024) {
    alloc_locals;

    // Compute a * b (1024 bits).
    let (local ab_low, local ab_high) = uint1024_mul(a, b);

    // Guess the quotient and remainder of (a * b) / d.
    local quotient_low: Uint1024;
    local quotient_high: Uint1024;
    local remainder: Uint1024;
    %{
        a = get_u1024(ids.a)
        b = get_u1024(ids.b)
        div = get_u1024(ids.div)

        quotient, remainder = divmod(a * b, div)

        set_u1024(ids.quotient_low, (quotient >> 1024*0) & ((1 << 1024) - 1))
        set_u1024(ids.quotient_high, (quotient >> 1024*1) & ((1 << 1024) - 1))
        set_u1024(ids.remainder, remainder)
    %}

    // Compute x = quotient * div + remainder.
    uint1024_check(quotient_high);
    let (quotient_mod10, quotient_mod11) = uint1024_mul(quotient_high, div);
    uint1024_check(quotient_low);
    let (quotient_mod00, quotient_mod01) = uint1024_mul(quotient_low, div);
    // Since x should equal a * b, the high 256 bits must be zero.
    let (res) = uint1024_zero();
    assert quotient_mod11 = res;

    // The low 256 bits of x must be ab_low.
    uint1024_check(remainder);
    let (x0, carry0) = uint1024_add(quotient_mod00, remainder, 0);
    assert x0 = ab_low;

    let (x1, carry1) = uint1024_add(quotient_mod01, quotient_mod10, 0);
    assert carry1 = 0;
    let (x1, carry2) = uint1024_add(x1, res, carry0);
    assert carry2 = 0;

    assert x1 = ab_high;

    return (quotient_low=quotient_low, quotient_high=quotient_high, remainder=remainder);
}

func uint1024_pow_mod_recursive{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    base: Uint1024, exp: felt, mod: Uint1024
) -> (res: Uint1024) {
    if (exp == 0) {
        let (res) = uint1024_one();
        return (res=res);
    }

    let (x_and_y) = bitwise_and(exp, 1);
    if (x_and_y == 0) {
        let (h) = uint1024_pow_mod_recursive(base, exp / 2, mod);
        let (_, _, res) = uint1024_mul_div_mod(h, h, mod);
        return (res=res);
    } else {
        let (b) = uint1024_pow_mod_recursive(base, exp - 1, mod);
        let (_, _, res) = uint1024_mul_div_mod(base, b, mod);
        return (res=res);
    }
}
