from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from uint1024 import (
    Uint1024,
    uint1024_add,
    uint1024_mul,
    uint1024_zero,
    uint1024_check,
    uint1024_eq,
    uint1024_one,
)

struct Uint2048 {
    low: Uint1024,
    high: Uint1024,
}

func uint2048_check{range_check_ptr}(a: Uint2048) {
    uint1024_check(a.low);
    uint1024_check(a.high);
    return ();
}

func uint2048_zero() -> (res: Uint2048) {
    let (res) = uint1024_zero();
    return (res=Uint2048(low=res, high=res));
}

func uint2048_one() -> (one: Uint2048) {
    let (one) = uint1024_one();
    let (res) = uint1024_zero();
    return (one=Uint2048(low=one, high=res));
}

func uint2048_eq{range_check_ptr}(a: Uint2048, b: Uint2048) -> felt {
    let eq = uint1024_eq(a.high, b.high);
    if (eq != 1) {
        return 0;
    }
    let eq = uint1024_eq(a.low, b.low);
    if (eq != 1) {
        return 0;
    }
    return 1;
}

func uint2048_add{range_check_ptr}(a: Uint2048, b: Uint2048, c_in: felt) -> (
    c: Uint2048, c_out: felt
) {
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
    let (cross_high_sum, cross_carry_1) = uint1024_add(
        low_high_cross_high, high_low_cross_high, cross_carry
    );

    let (low_part_high_updated, carry1) = uint1024_add(low_part_high, cross_low_sum, 0);
    let (low_part_with_cross_high, carry2) = uint1024_add(cross_high_sum, high_part_low, carry1);

    let (res) = uint1024_zero();
    let (final_high_part, _) = uint1024_add(res, high_part_high, carry2 + cross_carry_1);

    return (
        c=Uint2048(low=low_part_low, high=low_part_high_updated),
        d=Uint2048(low=low_part_with_cross_high, high=final_high_part),
    );
}

func uint2048_unsigned_div_rem{range_check_ptr}(a: Uint2048, div: Uint2048) -> (
    quotient: Uint2048, remainder: Uint2048
) {
    alloc_locals;

    // Guess the quotient and remainder of a / d.
    local quotient: Uint2048;
    local remainder: Uint2048;
    %{
        a = get_u2048(ids.a)
        div = get_u2048(ids.div)

        quotient, remainder = divmod(a, div)

        set_u2048(ids.quotient, quotient)
        set_u2048(ids.remainder, remainder)
    %}

    uint2048_check(quotient);
    uint2048_check(remainder);
    let (res_mul, carry) = uint2048_mul(quotient, div);
    let zero = uint2048_zero();
    assert carry = zero;

    let (check_val, add_carry) = uint2048_add(res_mul, remainder);
    assert check_val = a;
    assert add_carry = 0;

    return (quotient=quotient, remainder=remainder);
}

func uint2048_add_div_mod{range_check_ptr}(a: Uint2048, b: Uint2048, div: Uint2048) -> (
    quotient: Uint2048, remainder: Uint2048
) {
    alloc_locals;

    // Compute a + b (2048 bits).
    let (local ab, c) = uint2048_add(a, b, 0);

    // Guess the quotient and remainder of (a + b) / d.
    local quotient: Uint2048;
    local remainder: Uint2048;
    %{
        a = get_u2048(ids.a)
        b = get_u2048(ids.b)
        div = get_u2048(ids.div)

        v = a + b
        quotient = v // div
        remainder = v % div

        set_u2048(ids.quotient, (quotient >> 2048*0) & ((1 << 2048) - 1))
        set_u2048(ids.remainder, remainder)
    %}

    uint2048_check(quotient);
    uint2048_check(remainder);
    let (res_mul, carry) = uint2048_mul(quotient, div);
    let (res) = uint2048_zero();
    assert carry = res;

    let (check_val, add_carry) = uint2048_add(res_mul, remainder, 0);
    assert check_val = ab;
    assert add_carry = c;

    return (quotient=quotient, remainder=remainder);
}

func uint2048_mul_div_mod{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    a: Uint2048, b: Uint2048, div: Uint2048
) -> (quotient_low: Uint2048, quotient_high: Uint2048, remainder: Uint2048) {
    alloc_locals;

    // Compute a * b (2048 bits).
    let (local ab_low, local ab_high) = uint2048_mul(a, b);

    // Guess the quotient and remainder of (a * b) / d.
    local quotient_low: Uint2048;
    local quotient_high: Uint2048;
    local remainder: Uint2048;
    %{
        a = get_u2048(ids.a)
        b = get_u2048(ids.b)
        div = get_u2048(ids.div)

        quotient, remainder = divmod(a * b, div)

        set_u2048(ids.quotient_low, (quotient >> 2048*0) & ((1 << 2048) - 1))
        set_u2048(ids.quotient_high, (quotient >> 2048*1) & ((1 << 2048) - 1))
        set_u2048(ids.remainder, remainder)
    %}

    // Compute x = quotient * div + remainder.
    uint2048_check(quotient_high);
    let (quotient_mod10, quotient_mod11) = uint2048_mul(quotient_high, div);
    uint2048_check(quotient_low);
    let (quotient_mod00, quotient_mod01) = uint2048_mul(quotient_low, div);
    // Since x should equal a * b, the high 256 bits must be zero.
    let (res) = uint2048_zero();
    assert quotient_mod11 = res;

    // The low 256 bits of x must be ab_low.
    uint2048_check(remainder);
    let (x0, carry0) = uint2048_add(quotient_mod00, remainder, 0);
    assert x0 = ab_low;

    let (x1, carry1) = uint2048_add(quotient_mod01, quotient_mod10, 0);
    assert carry1 = 0;
    let (x1, carry2) = uint2048_add(x1, res, carry0);
    assert carry2 = 0;

    assert x1 = ab_high;

    return (quotient_low=quotient_low, quotient_high=quotient_high, remainder=remainder);
}

func uint2048_pow_mod_recursive{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    base: Uint2048, exp: felt, mod: Uint2048
) -> (res: Uint2048) {
    if (exp == 0) {
        let (res) = uint2048_one();
        return (res=res);
    }

    let (x_and_y) = bitwise_and(exp, 1);
    if (x_and_y == 0) {
        let (h) = uint2048_pow_mod_recursive(base, exp / 2, mod);
        let (_, _, res) = uint2048_mul_div_mod(h, h, mod);
        return (res=res);
    } else {
        let (b) = uint2048_pow_mod_recursive(base, exp - 1, mod);
        let (_, _, res) = uint2048_mul_div_mod(base, b, mod);
        return (res=res);
    }
}
