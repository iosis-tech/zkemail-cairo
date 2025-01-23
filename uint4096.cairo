// This library is adapted from Cairo's common library Uint256 and it follows it as closely as possible.
// The library implements basic operations between 4096-bit integers.
// Most operations use unsigned integers. Only a few operations are implemented for signed integers

// Represents an integer in the range [0, 2^4096).
struct Uint4096 {
    d00: felt,
    d01: felt,
    d02: felt,
    d03: felt,
    d04: felt,
    d05: felt,
    d06: felt,
    d07: felt,
    d08: felt,
    d09: felt,
    d10: felt,
    d11: felt,
    d12: felt,
    d13: felt,
    d14: felt,
    d15: felt,
    d16: felt,
    d17: felt,
    d18: felt,
    d19: felt,
    d20: felt,
    d21: felt,
    d22: felt,
    d23: felt,
    d24: felt,
    d25: felt,
    d26: felt,
    d27: felt,
    d28: felt,
    d29: felt,
    d30: felt,
    d31: felt,
}

const SHIFT = 2 ** 128;
const ALL_ONES = 2 ** 128 - 1;
const HALF_SHIFT = 2 ** 64;

namespace uint4096_lib {
    // Verifies that the given integer is valid.
    func check{range_check_ptr}(a: Uint4096) {
        [range_check_ptr + 00] = a.d00;
        [range_check_ptr + 01] = a.d01;
        [range_check_ptr + 02] = a.d02;
        [range_check_ptr + 03] = a.d03;
        [range_check_ptr + 04] = a.d04;
        [range_check_ptr + 05] = a.d05;
        [range_check_ptr + 06] = a.d06;
        [range_check_ptr + 07] = a.d07;
        [range_check_ptr + 08] = a.d08;
        [range_check_ptr + 09] = a.d09;
        [range_check_ptr + 10] = a.d10;
        [range_check_ptr + 11] = a.d11;
        [range_check_ptr + 12] = a.d12;
        [range_check_ptr + 13] = a.d13;
        [range_check_ptr + 14] = a.d14;
        [range_check_ptr + 15] = a.d15;
        [range_check_ptr + 16] = a.d16;
        [range_check_ptr + 17] = a.d17;
        [range_check_ptr + 18] = a.d18;
        [range_check_ptr + 19] = a.d19;
        [range_check_ptr + 20] = a.d20;
        [range_check_ptr + 21] = a.d21;
        [range_check_ptr + 22] = a.d22;
        [range_check_ptr + 23] = a.d23;
        [range_check_ptr + 24] = a.d24;
        [range_check_ptr + 25] = a.d25;
        [range_check_ptr + 26] = a.d26;
        [range_check_ptr + 27] = a.d27;
        [range_check_ptr + 28] = a.d28;
        [range_check_ptr + 29] = a.d29;
        [range_check_ptr + 30] = a.d30;
        [range_check_ptr + 31] = a.d31;
        let range_check_ptr = range_check_ptr + 32;
        return ();
    }

    // Arithmetics.

    // Adds two integers. Returns the result as a 4096-bit integer and the (1-bit) carry.
    func add{range_check_ptr}(a: Uint4096, b: Uint4096) -> (res: Uint4096, carry: felt) {
        alloc_locals;
        local res: Uint4096;

        local carry_d00: felt;
        local carry_d01: felt;
        local carry_d02: felt;
        local carry_d03: felt;
        local carry_d04: felt;
        local carry_d05: felt;
        local carry_d06: felt;
        local carry_d07: felt;
        local carry_d08: felt;
        local carry_d09: felt;
        local carry_d10: felt;
        local carry_d11: felt;
        local carry_d12: felt;
        local carry_d13: felt;
        local carry_d14: felt;
        local carry_d15: felt;
        local carry_d16: felt;
        local carry_d17: felt;
        local carry_d18: felt;
        local carry_d19: felt;
        local carry_d20: felt;
        local carry_d21: felt;
        local carry_d22: felt;
        local carry_d23: felt;
        local carry_d24: felt;
        local carry_d25: felt;
        local carry_d26: felt;
        local carry_d27: felt;
        local carry_d28: felt;
        local carry_d29: felt;
        local carry_d30: felt;
        local carry_d31: felt;

        %{
            sum_d00 = ids.a.d00 + ids.b.d00
            ids.carry_d00 = 1 if sum_d00 >= ids.SHIFT else 0
            sum_d01 = ids.a.d01 + ids.b.d01 + ids.carry_d00
            ids.carry_d01 = 1 if sum_d01 >= ids.SHIFT else 0
            sum_d02 = ids.a.d02 + ids.b.d02 + ids.carry_d01
            ids.carry_d02 = 1 if sum_d02 >= ids.SHIFT else 0
            sum_d03 = ids.a.d03 + ids.b.d03 + ids.carry_d02
            ids.carry_d03 = 1 if sum_d03 >= ids.SHIFT else 0
            sum_d04 = ids.a.d04 + ids.b.d04 + ids.carry_d03
            ids.carry_d04 = 1 if sum_d04 >= ids.SHIFT else 0
            sum_d05 = ids.a.d05 + ids.b.d05 + ids.carry_d04
            ids.carry_d05 = 1 if sum_d05 >= ids.SHIFT else 0
            sum_d06 = ids.a.d06 + ids.b.d06 + ids.carry_d05
            ids.carry_d06 = 1 if sum_d06 >= ids.SHIFT else 0
            sum_d07 = ids.a.d07 + ids.b.d07 + ids.carry_d06
            ids.carry_d07 = 1 if sum_d07 >= ids.SHIFT else 0
            sum_d08 = ids.a.d08 + ids.b.d08 + ids.carry_d07
            ids.carry_d08 = 1 if sum_d08 >= ids.SHIFT else 0
            sum_d09 = ids.a.d09 + ids.b.d09 + ids.carry_d08
            ids.carry_d09 = 1 if sum_d09 >= ids.SHIFT else 0
            sum_d10 = ids.a.d10 + ids.b.d10 + ids.carry_d09
            ids.carry_d10 = 1 if sum_d10 >= ids.SHIFT else 0
            sum_d11 = ids.a.d11 + ids.b.d11 + ids.carry_d10
            ids.carry_d11 = 1 if sum_d11 >= ids.SHIFT else 0
            sum_d12 = ids.a.d12 + ids.b.d12 + ids.carry_d11
            ids.carry_d12 = 1 if sum_d12 >= ids.SHIFT else 0
            sum_d13 = ids.a.d13 + ids.b.d13 + ids.carry_d12
            ids.carry_d13 = 1 if sum_d13 >= ids.SHIFT else 0
            sum_d14 = ids.a.d14 + ids.b.d14 + ids.carry_d13
            ids.carry_d14 = 1 if sum_d14 >= ids.SHIFT else 0
            sum_d15 = ids.a.d15 + ids.b.d15 + ids.carry_d14
            ids.carry_d15 = 1 if sum_d15 >= ids.SHIFT else 0
            sum_d16 = ids.a.d16 + ids.b.d16 + ids.carry_d15
            ids.carry_d16 = 1 if sum_d16 >= ids.SHIFT else 0
            sum_d17 = ids.a.d17 + ids.b.d17 + ids.carry_d16
            ids.carry_d17 = 1 if sum_d17 >= ids.SHIFT else 0
            sum_d18 = ids.a.d18 + ids.b.d18 + ids.carry_d17
            ids.carry_d18 = 1 if sum_d18 >= ids.SHIFT else 0
            sum_d19 = ids.a.d19 + ids.b.d19 + ids.carry_d18
            ids.carry_d19 = 1 if sum_d19 >= ids.SHIFT else 0
            sum_d20 = ids.a.d20 + ids.b.d20 + ids.carry_d19
            ids.carry_d20 = 1 if sum_d20 >= ids.SHIFT else 0
            sum_d21 = ids.a.d21 + ids.b.d21 + ids.carry_d20
            ids.carry_d21 = 1 if sum_d21 >= ids.SHIFT else 0
            sum_d22 = ids.a.d22 + ids.b.d22 + ids.carry_d21
            ids.carry_d22 = 1 if sum_d22 >= ids.SHIFT else 0
            sum_d23 = ids.a.d23 + ids.b.d23 + ids.carry_d22
            ids.carry_d23 = 1 if sum_d23 >= ids.SHIFT else 0
            sum_d24 = ids.a.d24 + ids.b.d24 + ids.carry_d23
            ids.carry_d24 = 1 if sum_d24 >= ids.SHIFT else 0
            sum_d25 = ids.a.d25 + ids.b.d25 + ids.carry_d24
            ids.carry_d25 = 1 if sum_d25 >= ids.SHIFT else 0
            sum_d26 = ids.a.d26 + ids.b.d26 + ids.carry_d25
            ids.carry_d26 = 1 if sum_d26 >= ids.SHIFT else 0
            sum_d27 = ids.a.d27 + ids.b.d27 + ids.carry_d26
            ids.carry_d27 = 1 if sum_d27 >= ids.SHIFT else 0
            sum_d28 = ids.a.d28 + ids.b.d28 + ids.carry_d27
            ids.carry_d28 = 1 if sum_d28 >= ids.SHIFT else 0
            sum_d29 = ids.a.d29 + ids.b.d29 + ids.carry_d28
            ids.carry_d29 = 1 if sum_d29 >= ids.SHIFT else 0
            sum_d30 = ids.a.d30 + ids.b.d30 + ids.carry_d29
            ids.carry_d30 = 1 if sum_d30 >= ids.SHIFT else 0
            sum_d31 = ids.a.d31 + ids.b.d31 + ids.carry_d30
            ids.carry_d31 = 1 if sum_d31 >= ids.SHIFT else 0
        %}

        // Either 0 or 1
        assert carry_d00 * carry_d00 = carry_d00;
        assert carry_d01 * carry_d01 = carry_d01;
        assert carry_d02 * carry_d02 = carry_d02;
        assert carry_d03 * carry_d03 = carry_d03;
        assert carry_d04 * carry_d04 = carry_d04;
        assert carry_d05 * carry_d05 = carry_d05;
        assert carry_d06 * carry_d06 = carry_d06;
        assert carry_d07 * carry_d07 = carry_d07;
        assert carry_d08 * carry_d08 = carry_d08;
        assert carry_d09 * carry_d09 = carry_d09;
        assert carry_d10 * carry_d10 = carry_d10;
        assert carry_d11 * carry_d11 = carry_d11;
        assert carry_d12 * carry_d12 = carry_d12;
        assert carry_d13 * carry_d13 = carry_d13;
        assert carry_d14 * carry_d14 = carry_d14;
        assert carry_d15 * carry_d15 = carry_d15;
        assert carry_d16 * carry_d16 = carry_d16;
        assert carry_d17 * carry_d17 = carry_d17;
        assert carry_d18 * carry_d18 = carry_d18;
        assert carry_d19 * carry_d19 = carry_d19;
        assert carry_d20 * carry_d20 = carry_d20;
        assert carry_d21 * carry_d21 = carry_d21;
        assert carry_d22 * carry_d22 = carry_d22;
        assert carry_d23 * carry_d23 = carry_d23;
        assert carry_d24 * carry_d24 = carry_d24;
        assert carry_d25 * carry_d25 = carry_d25;
        assert carry_d26 * carry_d26 = carry_d26;
        assert carry_d27 * carry_d27 = carry_d27;
        assert carry_d28 * carry_d28 = carry_d28;
        assert carry_d29 * carry_d29 = carry_d29;
        assert carry_d30 * carry_d30 = carry_d30;
        assert carry_d31 * carry_d31 = carry_d31;

        assert res.d00 = a.d00 + b.d00 - carry_d00 * SHIFT;
        assert res.d01 = a.d01 + b.d01 + carry_d00 - carry_d01 * SHIFT;
        assert res.d02 = a.d02 + b.d02 + carry_d01 - carry_d02 * SHIFT;
        assert res.d03 = a.d03 + b.d03 + carry_d02 - carry_d03 * SHIFT;
        assert res.d04 = a.d04 + b.d04 + carry_d03 - carry_d04 * SHIFT;
        assert res.d05 = a.d05 + b.d05 + carry_d04 - carry_d05 * SHIFT;
        assert res.d06 = a.d06 + b.d06 + carry_d05 - carry_d06 * SHIFT;
        assert res.d07 = a.d07 + b.d07 + carry_d06 - carry_d07 * SHIFT;
        assert res.d08 = a.d08 + b.d08 + carry_d07 - carry_d08 * SHIFT;
        assert res.d09 = a.d09 + b.d09 + carry_d08 - carry_d09 * SHIFT;
        assert res.d10 = a.d10 + b.d10 + carry_d09 - carry_d10 * SHIFT;
        assert res.d11 = a.d11 + b.d11 + carry_d10 - carry_d11 * SHIFT;
        assert res.d12 = a.d12 + b.d12 + carry_d11 - carry_d12 * SHIFT;
        assert res.d13 = a.d13 + b.d13 + carry_d12 - carry_d13 * SHIFT;
        assert res.d14 = a.d14 + b.d14 + carry_d13 - carry_d14 * SHIFT;
        assert res.d15 = a.d15 + b.d15 + carry_d14 - carry_d15 * SHIFT;
        assert res.d16 = a.d16 + b.d16 + carry_d15 - carry_d16 * SHIFT;
        assert res.d17 = a.d17 + b.d17 + carry_d16 - carry_d17 * SHIFT;
        assert res.d18 = a.d18 + b.d18 + carry_d17 - carry_d18 * SHIFT;
        assert res.d19 = a.d19 + b.d19 + carry_d18 - carry_d19 * SHIFT;
        assert res.d20 = a.d20 + b.d20 + carry_d19 - carry_d20 * SHIFT;
        assert res.d21 = a.d21 + b.d21 + carry_d20 - carry_d21 * SHIFT;
        assert res.d22 = a.d22 + b.d22 + carry_d21 - carry_d22 * SHIFT;
        assert res.d23 = a.d23 + b.d23 + carry_d22 - carry_d23 * SHIFT;
        assert res.d24 = a.d24 + b.d24 + carry_d23 - carry_d24 * SHIFT;
        assert res.d25 = a.d25 + b.d25 + carry_d24 - carry_d25 * SHIFT;
        assert res.d26 = a.d26 + b.d26 + carry_d25 - carry_d26 * SHIFT;
        assert res.d27 = a.d27 + b.d27 + carry_d26 - carry_d27 * SHIFT;
        assert res.d28 = a.d28 + b.d28 + carry_d27 - carry_d28 * SHIFT;
        assert res.d29 = a.d29 + b.d29 + carry_d28 - carry_d29 * SHIFT;
        assert res.d30 = a.d30 + b.d30 + carry_d29 - carry_d30 * SHIFT;
        assert res.d31 = a.d31 + b.d31 + carry_d30 - carry_d31 * SHIFT;

        check(res);

        return (res, carry_d31);
    }

    // Splits a field element in the range [0, 2^192) to its low 64-bit and high 128-bit parts.
    func split_64{range_check_ptr}(a: felt) -> (low: felt, high: felt) {
        alloc_locals;
        local low: felt;
        local high: felt;

        %{
            ids.low = ids.a & ((1<<64) - 1)
            ids.high = ids.a >> 64
        %}
        assert a = low + high * HALF_SHIFT;
        assert [range_check_ptr + 0] = low;
        assert [range_check_ptr + 1] = HALF_SHIFT - 1 - low;
        assert [range_check_ptr + 2] = high;
        let range_check_ptr = range_check_ptr + 3;
        return (low, high);
    }

    // Multiplies two integers. Returns the result as two 4096-bit integers: the result has 2*4096 bits,
    // the returned integers represent the lower 4096-bits and the higher 4096-bits, respectively.
    func mul{range_check_ptr}(a: Uint4096, b: Uint4096) -> (low: Uint4096, high: Uint4096) {
        // Splitting Uint4096 fields for `a`
        let (a00, a01) = split_64(a.d00);
        let (a02, a03) = split_64(a.d01);
        let (a04, a05) = split_64(a.d02);
        let (a06, a07) = split_64(a.d03);
        let (a08, a09) = split_64(a.d04);
        let (a10, a11) = split_64(a.d05);
        let (a12, a13) = split_64(a.d06);
        let (a14, a15) = split_64(a.d07);
        let (a16, a17) = split_64(a.d08);
        let (a18, a19) = split_64(a.d09);
        let (a20, a21) = split_64(a.d10);
        let (a22, a23) = split_64(a.d11);
        let (a24, a25) = split_64(a.d12);
        let (a26, a27) = split_64(a.d13);
        let (a28, a29) = split_64(a.d14);
        let (a30, a31) = split_64(a.d15);
        let (a32, a33) = split_64(a.d16);
        let (a34, a35) = split_64(a.d17);
        let (a36, a37) = split_64(a.d18);
        let (a38, a39) = split_64(a.d19);
        let (a40, a41) = split_64(a.d20);
        let (a42, a43) = split_64(a.d21);
        let (a44, a45) = split_64(a.d22);
        let (a46, a47) = split_64(a.d23);
        let (a48, a49) = split_64(a.d24);
        let (a50, a51) = split_64(a.d25);
        let (a52, a53) = split_64(a.d26);
        let (a54, a55) = split_64(a.d27);
        let (a56, a57) = split_64(a.d28);
        let (a58, a59) = split_64(a.d29);
        let (a60, a61) = split_64(a.d30);
        let (a62, a63) = split_64(a.d31);

        // Splitting Uint4096 fields for `b`
        let (b00, b01) = split_64(b.d00);
        let (b02, b03) = split_64(b.d01);
        let (b04, b05) = split_64(b.d02);
        let (b06, b07) = split_64(b.d03);
        let (b08, b09) = split_64(b.d04);
        let (b10, b11) = split_64(b.d05);
        let (b12, b13) = split_64(b.d06);
        let (b14, b15) = split_64(b.d07);
        let (b16, b17) = split_64(b.d08);
        let (b18, b19) = split_64(b.d09);
        let (b20, b21) = split_64(b.d10);
        let (b22, b23) = split_64(b.d11);
        let (b24, b25) = split_64(b.d12);
        let (b26, b27) = split_64(b.d13);
        let (b28, b29) = split_64(b.d14);
        let (b30, b31) = split_64(b.d15);
        let (b32, b33) = split_64(b.d16);
        let (b34, b35) = split_64(b.d17);
        let (b36, b37) = split_64(b.d18);
        let (b38, b39) = split_64(b.d19);
        let (b40, b41) = split_64(b.d20);
        let (b42, b43) = split_64(b.d21);
        let (b44, b45) = split_64(b.d22);
        let (b46, b47) = split_64(b.d23);
        let (b48, b49) = split_64(b.d24);
        let (b50, b51) = split_64(b.d25);
        let (b52, b53) = split_64(b.d26);
        let (b54, b55) = split_64(b.d27);
        let (b56, b57) = split_64(b.d28);
        let (b58, b59) = split_64(b.d29);
        let (b60, b61) = split_64(b.d30);
        let (b62, b63) = split_64(b.d31);

        let (res00, carry) = split_64(a00 * b00);
        let (res01, carry) = split_64(a00 * b01 + a01 * b00 + carry);
        let (res02, carry) = split_64(a00 * b02 + a01 * b01 + a02 * b00 + carry);
        let (res03, carry) = split_64(a00 * b03 + a01 * b02 + a02 * b01 + a03 * b00 + carry);
        let (res04, carry) = split_64(a00 * b04 + a01 * b03 + a02 * b02 + a03 * b01 + a04 * b00 + carry);
        let (res05, carry) = split_64(a00 * b05 + a01 * b04 + a02 * b03 + a03 * b02 + a04 * b01 + a05 * b00 + carry);
        let (res06, carry) = split_64(a00 * b06 + a01 * b05 + a02 * b04 + a03 * b03 + a04 * b02 + a05 * b01 + a06 * b00 + carry);
        let (res07, carry) = split_64(a00 * b07 + a01 * b06 + a02 * b05 + a03 * b04 + a04 * b03 + a05 * b02 + a06 * b01 + a07 * b00 + carry);
        let (res08, carry) = split_64(a00 * b08 + a01 * b07 + a02 * b06 + a03 * b05 + a04 * b04 + a05 * b03 + a06 * b02 + a07 * b01 + a08 * b00 + carry);
        let (res09, carry) = split_64(a00 * b09 + a01 * b08 + a02 * b07 + a03 * b06 + a04 * b05 + a05 * b04 + a06 * b03 + a07 * b02 + a08 * b01 + a09 * b00 + carry);
        let (res10, carry) = split_64(a00 * b10 + a01 * b09 + a02 * b08 + a03 * b07 + a04 * b06 + a05 * b05 + a06 * b04 + a07 * b03 + a08 * b02 + a09 * b01 + a10 * b00 + carry);
        let (res11, carry) = split_64(a00 * b11 + a01 * b10 + a02 * b09 + a03 * b08 + a04 * b07 + a05 * b06 + a06 * b05 + a07 * b04 + a08 * b03 + a09 * b02 + a10 * b01 + a11 * b00 + carry);
        let (res12, carry) = split_64(a00 * b12 + a01 * b11 + a02 * b10 + a03 * b09 + a04 * b08 + a05 * b07 + a06 * b06 + a07 * b05 + a08 * b04 + a09 * b03 + a10 * b02 + a11 * b01 + a12 * b00 + carry);
        let (res13, carry) = split_64(a00 * b13 + a01 * b12 + a02 * b11 + a03 * b10 + a04 * b09 + a05 * b08 + a06 * b07 + a07 * b06 + a08 * b05 + a09 * b04 + a10 * b03 + a11 * b02 + a12 * b01 + a13 * b00 + carry);
        let (res14, carry) = split_64(a00 * b14 + a01 * b13 + a02 * b12 + a03 * b11 + a04 * b10 + a05 * b09 + a06 * b08 + a07 * b07 + a08 * b06 + a09 * b05 + a10 * b04 + a11 * b03 + a12 * b02 + a13 * b01 + a14 * b00 + carry);
        let (res15, carry) = split_64(a00 * b15 + a01 * b14 + a02 * b13 + a03 * b12 + a04 * b11 + a05 * b10 + a06 * b09 + a07 * b08 + a08 * b07 + a09 * b06 + a10 * b05 + a11 * b04 + a12 * b03 + a13 * b02 + a14 * b01 + a15 * b00 + carry);
        let (res16, carry) = split_64(a00 * b16 + a01 * b15 + a02 * b14 + a03 * b13 + a04 * b12 + a05 * b11 + a06 * b10 + a07 * b09 + a08 * b08 + a09 * b07 + a10 * b06 + a11 * b05 + a12 * b04 + a13 * b03 + a14 * b02 + a15 * b01 + a16 * b00 + carry);
        let (res17, carry) = split_64(a00 * b17 + a01 * b16 + a02 * b15 + a03 * b14 + a04 * b13 + a05 * b12 + a06 * b11 + a07 * b10 + a08 * b09 + a09 * b08 + a10 * b07 + a11 * b06 + a12 * b05 + a13 * b04 + a14 * b03 + a15 * b02 + a16 * b01 + a17 * b00 + carry);
        let (res18, carry) = split_64(a00 * b18 + a01 * b17 + a02 * b16 + a03 * b15 + a04 * b14 + a05 * b13 + a06 * b12 + a07 * b11 + a08 * b10 + a09 * b09 + a10 * b08 + a11 * b07 + a12 * b06 + a13 * b05 + a14 * b04 + a15 * b03 + a16 * b02 + a17 * b01 + a18 * b00 + carry);
        let (res19, carry) = split_64(a00 * b19 + a01 * b18 + a02 * b17 + a03 * b16 + a04 * b15 + a05 * b14 + a06 * b13 + a07 * b12 + a08 * b11 + a09 * b10 + a10 * b09 + a11 * b08 + a12 * b07 + a13 * b06 + a14 * b05 + a15 * b04 + a16 * b03 + a17 * b02 + a18 * b01 + a19 * b00 + carry);
        let (res20, carry) = split_64(a00 * b20 + a01 * b19 + a02 * b18 + a03 * b17 + a04 * b16 + a05 * b15 + a06 * b14 + a07 * b13 + a08 * b12 + a09 * b11 + a10 * b10 + a11 * b09 + a12 * b08 + a13 * b07 + a14 * b06 + a15 * b05 + a16 * b04 + a17 * b03 + a18 * b02 + a19 * b01 + a20 * b00 + carry);
        let (res21, carry) = split_64(a00 * b21 + a01 * b20 + a02 * b19 + a03 * b18 + a04 * b17 + a05 * b16 + a06 * b15 + a07 * b14 + a08 * b13 + a09 * b12 + a10 * b11 + a11 * b10 + a12 * b09 + a13 * b08 + a14 * b07 + a15 * b06 + a16 * b05 + a17 * b04 + a18 * b03 + a19 * b02 + a20 * b01 + a21 * b00 + carry);
        let (res22, carry) = split_64(a00 * b22 + a01 * b21 + a02 * b20 + a03 * b19 + a04 * b18 + a05 * b17 + a06 * b16 + a07 * b15 + a08 * b14 + a09 * b13 + a10 * b12 + a11 * b11 + a12 * b10 + a13 * b09 + a14 * b08 + a15 * b07 + a16 * b06 + a17 * b05 + a18 * b04 + a19 * b03 + a20 * b02 + a21 * b01 + a22 * b00 + carry);
        let (res23, carry) = split_64(a00 * b23 + a01 * b22 + a02 * b21 + a03 * b20 + a04 * b19 + a05 * b18 + a06 * b17 + a07 * b16 + a08 * b15 + a09 * b14 + a10 * b13 + a11 * b12 + a12 * b11 + a13 * b10 + a14 * b09 + a15 * b08 + a16 * b07 + a17 * b06 + a18 * b05 + a19 * b04 + a20 * b03 + a21 * b02 + a22 * b01 + a23 * b00 + carry);
        let (res24, carry) = split_64(a00 * b24 + a01 * b23 + a02 * b22 + a03 * b21 + a04 * b20 + a05 * b19 + a06 * b18 + a07 * b17 + a08 * b16 + a09 * b15 + a10 * b14 + a11 * b13 + a12 * b12 + a13 * b11 + a14 * b10 + a15 * b09 + a16 * b08 + a17 * b07 + a18 * b06 + a19 * b05 + a20 * b04 + a21 * b03 + a22 * b02 + a23 * b01 + a24 * b00 + carry);
        let (res25, carry) = split_64(a00 * b25 + a01 * b24 + a02 * b23 + a03 * b22 + a04 * b21 + a05 * b20 + a06 * b19 + a07 * b18 + a08 * b17 + a09 * b16 + a10 * b15 + a11 * b14 + a12 * b13 + a13 * b12 + a14 * b11 + a15 * b10 + a16 * b09 + a17 * b08 + a18 * b07 + a19 * b06 + a20 * b05 + a21 * b04 + a22 * b03 + a23 * b02 + a24 * b01 + a25 * b00 + carry);
        let (res26, carry) = split_64(a00 * b26 + a01 * b25 + a02 * b24 + a03 * b23 + a04 * b22 + a05 * b21 + a06 * b20 + a07 * b19 + a08 * b18 + a09 * b17 + a10 * b16 + a11 * b15 + a12 * b14 + a13 * b13 + a14 * b12 + a15 * b11 + a16 * b10 + a17 * b09 + a18 * b08 + a19 * b07 + a20 * b06 + a21 * b05 + a22 * b04 + a23 * b03 + a24 * b02 + a25 * b01 + a26 * b00 + carry);
        let (res27, carry) = split_64(a00 * b27 + a01 * b26 + a02 * b25 + a03 * b24 + a04 * b23 + a05 * b22 + a06 * b21 + a07 * b20 + a08 * b19 + a09 * b18 + a10 * b17 + a11 * b16 + a12 * b15 + a13 * b14 + a14 * b13 + a15 * b12 + a16 * b11 + a17 * b10 + a18 * b09 + a19 * b08 + a20 * b07 + a21 * b06 + a22 * b05 + a23 * b04 + a24 * b03 + a25 * b02 + a26 * b01 + a27 * b00 + carry);
        let (res28, carry) = split_64(a00 * b28 + a01 * b27 + a02 * b26 + a03 * b25 + a04 * b24 + a05 * b23 + a06 * b22 + a07 * b21 + a08 * b20 + a09 * b19 + a10 * b18 + a11 * b17 + a12 * b16 + a13 * b15 + a14 * b14 + a15 * b13 + a16 * b12 + a17 * b11 + a18 * b10 + a19 * b09 + a20 * b08 + a21 * b07 + a22 * b06 + a23 * b05 + a24 * b04 + a25 * b03 + a26 * b02 + a27 * b01 + a28 * b00 + carry);
        let (res29, carry) = split_64(a00 * b29 + a01 * b28 + a02 * b27 + a03 * b26 + a04 * b25 + a05 * b24 + a06 * b23 + a07 * b22 + a08 * b21 + a09 * b20 + a10 * b19 + a11 * b18 + a12 * b17 + a13 * b16 + a14 * b15 + a15 * b14 + a16 * b13 + a17 * b12 + a18 * b11 + a19 * b10 + a20 * b09 + a21 * b08 + a22 * b07 + a23 * b06 + a24 * b05 + a25 * b04 + a26 * b03 + a27 * b02 + a28 * b01 + a29 * b00 + carry);
        let (res30, carry) = split_64(a00 * b30 + a01 * b29 + a02 * b28 + a03 * b27 + a04 * b26 + a05 * b25 + a06 * b24 + a07 * b23 + a08 * b22 + a09 * b21 + a10 * b20 + a11 * b19 + a12 * b18 + a13 * b17 + a14 * b16 + a15 * b15 + a16 * b14 + a17 * b13 + a18 * b12 + a19 * b11 + a20 * b10 + a21 * b09 + a22 * b08 + a23 * b07 + a24 * b06 + a25 * b05 + a26 * b04 + a27 * b03 + a28 * b02 + a29 * b01 + a30 * b00 + carry);
        let (res31, carry) = split_64(a00 * b31 + a01 * b30 + a02 * b29 + a03 * b28 + a04 * b27 + a05 * b26 + a06 * b25 + a07 * b24 + a08 * b23 + a09 * b22 + a10 * b21 + a11 * b20 + a12 * b19 + a13 * b18 + a14 * b17 + a15 * b16 + a16 * b15 + a17 * b14 + a18 * b13 + a19 * b12 + a20 * b11 + a21 * b10 + a22 * b09 + a23 * b08 + a24 * b07 + a25 * b06 + a26 * b05 + a27 * b04 + a28 * b03 + a29 * b02 + a30 * b01 + a31 * b00 + carry);
        let (res32, carry) = split_64(a00 * b32 + a01 * b31 + a02 * b30 + a03 * b29 + a04 * b28 + a05 * b27 + a06 * b26 + a07 * b25 + a08 * b24 + a09 * b23 + a10 * b22 + a11 * b21 + a12 * b20 + a13 * b19 + a14 * b18 + a15 * b17 + a16 * b16 + a17 * b15 + a18 * b14 + a19 * b13 + a20 * b12 + a21 * b11 + a22 * b10 + a23 * b09 + a24 * b08 + a25 * b07 + a26 * b06 + a27 * b05 + a28 * b04 + a29 * b03 + a30 * b02 + a31 * b01 + a32 * b00 + carry);
        let (res33, carry) = split_64(a00 * b33 + a01 * b32 + a02 * b31 + a03 * b30 + a04 * b29 + a05 * b28 + a06 * b27 + a07 * b26 + a08 * b25 + a09 * b24 + a10 * b23 + a11 * b22 + a12 * b21 + a13 * b20 + a14 * b19 + a15 * b18 + a16 * b17 + a17 * b16 + a18 * b15 + a19 * b14 + a20 * b13 + a21 * b12 + a22 * b11 + a23 * b10 + a24 * b09 + a25 * b08 + a26 * b07 + a27 * b06 + a28 * b05 + a29 * b04 + a30 * b03 + a31 * b02 + a32 * b01 + a33 * b00 + carry);
        let (res34, carry) = split_64(a00 * b34 + a01 * b33 + a02 * b32 + a03 * b31 + a04 * b30 + a05 * b29 + a06 * b28 + a07 * b27 + a08 * b26 + a09 * b25 + a10 * b24 + a11 * b23 + a12 * b22 + a13 * b21 + a14 * b20 + a15 * b19 + a16 * b18 + a17 * b17 + a18 * b16 + a19 * b15 + a20 * b14 + a21 * b13 + a22 * b12 + a23 * b11 + a24 * b10 + a25 * b09 + a26 * b08 + a27 * b07 + a28 * b06 + a29 * b05 + a30 * b04 + a31 * b03 + a32 * b02 + a33 * b01 + a34 * b00 + carry);
        let (res35, carry) = split_64(a00 * b35 + a01 * b34 + a02 * b33 + a03 * b32 + a04 * b31 + a05 * b30 + a06 * b29 + a07 * b28 + a08 * b27 + a09 * b26 + a10 * b25 + a11 * b24 + a12 * b23 + a13 * b22 + a14 * b21 + a15 * b20 + a16 * b19 + a17 * b18 + a18 * b17 + a19 * b16 + a20 * b15 + a21 * b14 + a22 * b13 + a23 * b12 + a24 * b11 + a25 * b10 + a26 * b09 + a27 * b08 + a28 * b07 + a29 * b06 + a30 * b05 + a31 * b04 + a32 * b03 + a33 * b02 + a34 * b01 + a35 * b00 + carry);
        let (res36, carry) = split_64(a00 * b36 + a01 * b35 + a02 * b34 + a03 * b33 + a04 * b32 + a05 * b31 + a06 * b30 + a07 * b29 + a08 * b28 + a09 * b27 + a10 * b26 + a11 * b25 + a12 * b24 + a13 * b23 + a14 * b22 + a15 * b21 + a16 * b20 + a17 * b19 + a18 * b18 + a19 * b17 + a20 * b16 + a21 * b15 + a22 * b14 + a23 * b13 + a24 * b12 + a25 * b11 + a26 * b10 + a27 * b09 + a28 * b08 + a29 * b07 + a30 * b06 + a31 * b05 + a32 * b04 + a33 * b03 + a34 * b02 + a35 * b01 + a36 * b00 + carry);
        let (res37, carry) = split_64(a00 * b37 + a01 * b36 + a02 * b35 + a03 * b34 + a04 * b33 + a05 * b32 + a06 * b31 + a07 * b30 + a08 * b29 + a09 * b28 + a10 * b27 + a11 * b26 + a12 * b25 + a13 * b24 + a14 * b23 + a15 * b22 + a16 * b21 + a17 * b20 + a18 * b19 + a19 * b18 + a20 * b17 + a21 * b16 + a22 * b15 + a23 * b14 + a24 * b13 + a25 * b12 + a26 * b11 + a27 * b10 + a28 * b09 + a29 * b08 + a30 * b07 + a31 * b06 + a32 * b05 + a33 * b04 + a34 * b03 + a35 * b02 + a36 * b01 + a37 * b00 + carry);
        let (res38, carry) = split_64(a00 * b38 + a01 * b37 + a02 * b36 + a03 * b35 + a04 * b34 + a05 * b33 + a06 * b32 + a07 * b31 + a08 * b30 + a09 * b29 + a10 * b28 + a11 * b27 + a12 * b26 + a13 * b25 + a14 * b24 + a15 * b23 + a16 * b22 + a17 * b21 + a18 * b20 + a19 * b19 + a20 * b18 + a21 * b17 + a22 * b16 + a23 * b15 + a24 * b14 + a25 * b13 + a26 * b12 + a27 * b11 + a28 * b10 + a29 * b09 + a30 * b08 + a31 * b07 + a32 * b06 + a33 * b05 + a34 * b04 + a35 * b03 + a36 * b02 + a37 * b01 + a38 * b00 + carry);
        let (res39, carry) = split_64(a00 * b39 + a01 * b38 + a02 * b37 + a03 * b36 + a04 * b35 + a05 * b34 + a06 * b33 + a07 * b32 + a08 * b31 + a09 * b30 + a10 * b29 + a11 * b28 + a12 * b27 + a13 * b26 + a14 * b25 + a15 * b24 + a16 * b23 + a17 * b22 + a18 * b21 + a19 * b20 + a20 * b19 + a21 * b18 + a22 * b17 + a23 * b16 + a24 * b15 + a25 * b14 + a26 * b13 + a27 * b12 + a28 * b11 + a29 * b10 + a30 * b09 + a31 * b08 + a32 * b07 + a33 * b06 + a34 * b05 + a35 * b04 + a36 * b03 + a37 * b02 + a38 * b01 + a39 * b00 + carry);
        let (res40, carry) = split_64(a00 * b40 + a01 * b39 + a02 * b38 + a03 * b37 + a04 * b36 + a05 * b35 + a06 * b34 + a07 * b33 + a08 * b32 + a09 * b31 + a10 * b30 + a11 * b29 + a12 * b28 + a13 * b27 + a14 * b26 + a15 * b25 + a16 * b24 + a17 * b23 + a18 * b22 + a19 * b21 + a20 * b20 + a21 * b19 + a22 * b18 + a23 * b17 + a24 * b16 + a25 * b15 + a26 * b14 + a27 * b13 + a28 * b12 + a29 * b11 + a30 * b10 + a31 * b09 + a32 * b08 + a33 * b07 + a34 * b06 + a35 * b05 + a36 * b04 + a37 * b03 + a38 * b02 + a39 * b01 + a40 * b00 + carry);
        let (res41, carry) = split_64(a00 * b41 + a01 * b40 + a02 * b39 + a03 * b38 + a04 * b37 + a05 * b36 + a06 * b35 + a07 * b34 + a08 * b33 + a09 * b32 + a10 * b31 + a11 * b30 + a12 * b29 + a13 * b28 + a14 * b27 + a15 * b26 + a16 * b25 + a17 * b24 + a18 * b23 + a19 * b22 + a20 * b21 + a21 * b20 + a22 * b19 + a23 * b18 + a24 * b17 + a25 * b16 + a26 * b15 + a27 * b14 + a28 * b13 + a29 * b12 + a30 * b11 + a31 * b10 + a32 * b09 + a33 * b08 + a34 * b07 + a35 * b06 + a36 * b05 + a37 * b04 + a38 * b03 + a39 * b02 + a40 * b01 + a41 * b00 + carry);
        let (res42, carry) = split_64(a00 * b42 + a01 * b41 + a02 * b40 + a03 * b39 + a04 * b38 + a05 * b37 + a06 * b36 + a07 * b35 + a08 * b34 + a09 * b33 + a10 * b32 + a11 * b31 + a12 * b30 + a13 * b29 + a14 * b28 + a15 * b27 + a16 * b26 + a17 * b25 + a18 * b24 + a19 * b23 + a20 * b22 + a21 * b21 + a22 * b20 + a23 * b19 + a24 * b18 + a25 * b17 + a26 * b16 + a27 * b15 + a28 * b14 + a29 * b13 + a30 * b12 + a31 * b11 + a32 * b10 + a33 * b09 + a34 * b08 + a35 * b07 + a36 * b06 + a37 * b05 + a38 * b04 + a39 * b03 + a40 * b02 + a41 * b01 + a42 * b00 + carry);
        let (res43, carry) = split_64(a00 * b43 + a01 * b42 + a02 * b41 + a03 * b40 + a04 * b39 + a05 * b38 + a06 * b37 + a07 * b36 + a08 * b35 + a09 * b34 + a10 * b33 + a11 * b32 + a12 * b31 + a13 * b30 + a14 * b29 + a15 * b28 + a16 * b27 + a17 * b26 + a18 * b25 + a19 * b24 + a20 * b23 + a21 * b22 + a22 * b21 + a23 * b20 + a24 * b19 + a25 * b18 + a26 * b17 + a27 * b16 + a28 * b15 + a29 * b14 + a30 * b13 + a31 * b12 + a32 * b11 + a33 * b10 + a34 * b09 + a35 * b08 + a36 * b07 + a37 * b06 + a38 * b05 + a39 * b04 + a40 * b03 + a41 * b02 + a42 * b01 + a43 * b00 + carry);
        let (res44, carry) = split_64(a00 * b44 + a01 * b43 + a02 * b42 + a03 * b41 + a04 * b40 + a05 * b39 + a06 * b38 + a07 * b37 + a08 * b36 + a09 * b35 + a10 * b34 + a11 * b33 + a12 * b32 + a13 * b31 + a14 * b30 + a15 * b29 + a16 * b28 + a17 * b27 + a18 * b26 + a19 * b25 + a20 * b24 + a21 * b23 + a22 * b22 + a23 * b21 + a24 * b20 + a25 * b19 + a26 * b18 + a27 * b17 + a28 * b16 + a29 * b15 + a30 * b14 + a31 * b13 + a32 * b12 + a33 * b11 + a34 * b10 + a35 * b09 + a36 * b08 + a37 * b07 + a38 * b06 + a39 * b05 + a40 * b04 + a41 * b03 + a42 * b02 + a43 * b01 + a44 * b00 + carry);
        let (res45, carry) = split_64(a00 * b45 + a01 * b44 + a02 * b43 + a03 * b42 + a04 * b41 + a05 * b40 + a06 * b39 + a07 * b38 + a08 * b37 + a09 * b36 + a10 * b35 + a11 * b34 + a12 * b33 + a13 * b32 + a14 * b31 + a15 * b30 + a16 * b29 + a17 * b28 + a18 * b27 + a19 * b26 + a20 * b25 + a21 * b24 + a22 * b23 + a23 * b22 + a24 * b21 + a25 * b20 + a26 * b19 + a27 * b18 + a28 * b17 + a29 * b16 + a30 * b15 + a31 * b14 + a32 * b13 + a33 * b12 + a34 * b11 + a35 * b10 + a36 * b09 + a37 * b08 + a38 * b07 + a39 * b06 + a40 * b05 + a41 * b04 + a42 * b03 + a43 * b02 + a44 * b01 + a45 * b00 + carry);
        let (res46, carry) = split_64(a00 * b46 + a01 * b45 + a02 * b44 + a03 * b43 + a04 * b42 + a05 * b41 + a06 * b40 + a07 * b39 + a08 * b38 + a09 * b37 + a10 * b36 + a11 * b35 + a12 * b34 + a13 * b33 + a14 * b32 + a15 * b31 + a16 * b30 + a17 * b29 + a18 * b28 + a19 * b27 + a20 * b26 + a21 * b25 + a22 * b24 + a23 * b23 + a24 * b22 + a25 * b21 + a26 * b20 + a27 * b19 + a28 * b18 + a29 * b17 + a30 * b16 + a31 * b15 + a32 * b14 + a33 * b13 + a34 * b12 + a35 * b11 + a36 * b10 + a37 * b09 + a38 * b08 + a39 * b07 + a40 * b06 + a41 * b05 + a42 * b04 + a43 * b03 + a44 * b02 + a45 * b01 + a46 * b00 + carry);
        let (res47, carry) = split_64(a00 * b47 + a01 * b46 + a02 * b45 + a03 * b44 + a04 * b43 + a05 * b42 + a06 * b41 + a07 * b40 + a08 * b39 + a09 * b38 + a10 * b37 + a11 * b36 + a12 * b35 + a13 * b34 + a14 * b33 + a15 * b32 + a16 * b31 + a17 * b30 + a18 * b29 + a19 * b28 + a20 * b27 + a21 * b26 + a22 * b25 + a23 * b24 + a24 * b23 + a25 * b22 + a26 * b21 + a27 * b20 + a28 * b19 + a29 * b18 + a30 * b17 + a31 * b16 + a32 * b15 + a33 * b14 + a34 * b13 + a35 * b12 + a36 * b11 + a37 * b10 + a38 * b09 + a39 * b08 + a40 * b07 + a41 * b06 + a42 * b05 + a43 * b04 + a44 * b03 + a45 * b02 + a46 * b01 + a47 * b00 + carry);
        let (res48, carry) = split_64(a00 * b48 + a01 * b47 + a02 * b46 + a03 * b45 + a04 * b44 + a05 * b43 + a06 * b42 + a07 * b41 + a08 * b40 + a09 * b39 + a10 * b38 + a11 * b37 + a12 * b36 + a13 * b35 + a14 * b34 + a15 * b33 + a16 * b32 + a17 * b31 + a18 * b30 + a19 * b29 + a20 * b28 + a21 * b27 + a22 * b26 + a23 * b25 + a24 * b24 + a25 * b23 + a26 * b22 + a27 * b21 + a28 * b20 + a29 * b19 + a30 * b18 + a31 * b17 + a32 * b16 + a33 * b15 + a34 * b14 + a35 * b13 + a36 * b12 + a37 * b11 + a38 * b10 + a39 * b09 + a40 * b08 + a41 * b07 + a42 * b06 + a43 * b05 + a44 * b04 + a45 * b03 + a46 * b02 + a47 * b01 + a48 * b00 + carry);
        let (res49, carry) = split_64(a00 * b49 + a01 * b48 + a02 * b47 + a03 * b46 + a04 * b45 + a05 * b44 + a06 * b43 + a07 * b42 + a08 * b41 + a09 * b40 + a10 * b39 + a11 * b38 + a12 * b37 + a13 * b36 + a14 * b35 + a15 * b34 + a16 * b33 + a17 * b32 + a18 * b31 + a19 * b30 + a20 * b29 + a21 * b28 + a22 * b27 + a23 * b26 + a24 * b25 + a25 * b24 + a26 * b23 + a27 * b22 + a28 * b21 + a29 * b20 + a30 * b19 + a31 * b18 + a32 * b17 + a33 * b16 + a34 * b15 + a35 * b14 + a36 * b13 + a37 * b12 + a38 * b11 + a39 * b10 + a40 * b09 + a41 * b08 + a42 * b07 + a43 * b06 + a44 * b05 + a45 * b04 + a46 * b03 + a47 * b02 + a48 * b01 + a49 * b00 + carry);
        let (res50, carry) = split_64(a00 * b50 + a01 * b49 + a02 * b48 + a03 * b47 + a04 * b46 + a05 * b45 + a06 * b44 + a07 * b43 + a08 * b42 + a09 * b41 + a10 * b40 + a11 * b39 + a12 * b38 + a13 * b37 + a14 * b36 + a15 * b35 + a16 * b34 + a17 * b33 + a18 * b32 + a19 * b31 + a20 * b30 + a21 * b29 + a22 * b28 + a23 * b27 + a24 * b26 + a25 * b25 + a26 * b24 + a27 * b23 + a28 * b22 + a29 * b21 + a30 * b20 + a31 * b19 + a32 * b18 + a33 * b17 + a34 * b16 + a35 * b15 + a36 * b14 + a37 * b13 + a38 * b12 + a39 * b11 + a40 * b10 + a41 * b09 + a42 * b08 + a43 * b07 + a44 * b06 + a45 * b05 + a46 * b04 + a47 * b03 + a48 * b02 + a49 * b01 + a50 * b00 + carry);
        let (res51, carry) = split_64(a00 * b51 + a01 * b50 + a02 * b49 + a03 * b48 + a04 * b47 + a05 * b46 + a06 * b45 + a07 * b44 + a08 * b43 + a09 * b42 + a10 * b41 + a11 * b40 + a12 * b39 + a13 * b38 + a14 * b37 + a15 * b36 + a16 * b35 + a17 * b34 + a18 * b33 + a19 * b32 + a20 * b31 + a21 * b30 + a22 * b29 + a23 * b28 + a24 * b27 + a25 * b26 + a26 * b25 + a27 * b24 + a28 * b23 + a29 * b22 + a30 * b21 + a31 * b20 + a32 * b19 + a33 * b18 + a34 * b17 + a35 * b16 + a36 * b15 + a37 * b14 + a38 * b13 + a39 * b12 + a40 * b11 + a41 * b10 + a42 * b09 + a43 * b08 + a44 * b07 + a45 * b06 + a46 * b05 + a47 * b04 + a48 * b03 + a49 * b02 + a50 * b01 + a51 * b00 + carry);
        let (res52, carry) = split_64(a00 * b52 + a01 * b51 + a02 * b50 + a03 * b49 + a04 * b48 + a05 * b47 + a06 * b46 + a07 * b45 + a08 * b44 + a09 * b43 + a10 * b42 + a11 * b41 + a12 * b40 + a13 * b39 + a14 * b38 + a15 * b37 + a16 * b36 + a17 * b35 + a18 * b34 + a19 * b33 + a20 * b32 + a21 * b31 + a22 * b30 + a23 * b29 + a24 * b28 + a25 * b27 + a26 * b26 + a27 * b25 + a28 * b24 + a29 * b23 + a30 * b22 + a31 * b21 + a32 * b20 + a33 * b19 + a34 * b18 + a35 * b17 + a36 * b16 + a37 * b15 + a38 * b14 + a39 * b13 + a40 * b12 + a41 * b11 + a42 * b10 + a43 * b09 + a44 * b08 + a45 * b07 + a46 * b06 + a47 * b05 + a48 * b04 + a49 * b03 + a50 * b02 + a51 * b01 + a52 * b00 + carry);
        let (res53, carry) = split_64(a00 * b53 + a01 * b52 + a02 * b51 + a03 * b50 + a04 * b49 + a05 * b48 + a06 * b47 + a07 * b46 + a08 * b45 + a09 * b44 + a10 * b43 + a11 * b42 + a12 * b41 + a13 * b40 + a14 * b39 + a15 * b38 + a16 * b37 + a17 * b36 + a18 * b35 + a19 * b34 + a20 * b33 + a21 * b32 + a22 * b31 + a23 * b30 + a24 * b29 + a25 * b28 + a26 * b27 + a27 * b26 + a28 * b25 + a29 * b24 + a30 * b23 + a31 * b22 + a32 * b21 + a33 * b20 + a34 * b19 + a35 * b18 + a36 * b17 + a37 * b16 + a38 * b15 + a39 * b14 + a40 * b13 + a41 * b12 + a42 * b11 + a43 * b10 + a44 * b09 + a45 * b08 + a46 * b07 + a47 * b06 + a48 * b05 + a49 * b04 + a50 * b03 + a51 * b02 + a52 * b01 + a53 * b00 + carry);
        let (res54, carry) = split_64(a00 * b54 + a01 * b53 + a02 * b52 + a03 * b51 + a04 * b50 + a05 * b49 + a06 * b48 + a07 * b47 + a08 * b46 + a09 * b45 + a10 * b44 + a11 * b43 + a12 * b42 + a13 * b41 + a14 * b40 + a15 * b39 + a16 * b38 + a17 * b37 + a18 * b36 + a19 * b35 + a20 * b34 + a21 * b33 + a22 * b32 + a23 * b31 + a24 * b30 + a25 * b29 + a26 * b28 + a27 * b27 + a28 * b26 + a29 * b25 + a30 * b24 + a31 * b23 + a32 * b22 + a33 * b21 + a34 * b20 + a35 * b19 + a36 * b18 + a37 * b17 + a38 * b16 + a39 * b15 + a40 * b14 + a41 * b13 + a42 * b12 + a43 * b11 + a44 * b10 + a45 * b09 + a46 * b08 + a47 * b07 + a48 * b06 + a49 * b05 + a50 * b04 + a51 * b03 + a52 * b02 + a53 * b01 + a54 * b00 + carry);
        let (res55, carry) = split_64(a00 * b55 + a01 * b54 + a02 * b53 + a03 * b52 + a04 * b51 + a05 * b50 + a06 * b49 + a07 * b48 + a08 * b47 + a09 * b46 + a10 * b45 + a11 * b44 + a12 * b43 + a13 * b42 + a14 * b41 + a15 * b40 + a16 * b39 + a17 * b38 + a18 * b37 + a19 * b36 + a20 * b35 + a21 * b34 + a22 * b33 + a23 * b32 + a24 * b31 + a25 * b30 + a26 * b29 + a27 * b28 + a28 * b27 + a29 * b26 + a30 * b25 + a31 * b24 + a32 * b23 + a33 * b22 + a34 * b21 + a35 * b20 + a36 * b19 + a37 * b18 + a38 * b17 + a39 * b16 + a40 * b15 + a41 * b14 + a42 * b13 + a43 * b12 + a44 * b11 + a45 * b10 + a46 * b09 + a47 * b08 + a48 * b07 + a49 * b06 + a50 * b05 + a51 * b04 + a52 * b03 + a53 * b02 + a54 * b01 + a55 * b00 + carry);
        let (res56, carry) = split_64(a00 * b56 + a01 * b55 + a02 * b54 + a03 * b53 + a04 * b52 + a05 * b51 + a06 * b50 + a07 * b49 + a08 * b48 + a09 * b47 + a10 * b46 + a11 * b45 + a12 * b44 + a13 * b43 + a14 * b42 + a15 * b41 + a16 * b40 + a17 * b39 + a18 * b38 + a19 * b37 + a20 * b36 + a21 * b35 + a22 * b34 + a23 * b33 + a24 * b32 + a25 * b31 + a26 * b30 + a27 * b29 + a28 * b28 + a29 * b27 + a30 * b26 + a31 * b25 + a32 * b24 + a33 * b23 + a34 * b22 + a35 * b21 + a36 * b20 + a37 * b19 + a38 * b18 + a39 * b17 + a40 * b16 + a41 * b15 + a42 * b14 + a43 * b13 + a44 * b12 + a45 * b11 + a46 * b10 + a47 * b09 + a48 * b08 + a49 * b07 + a50 * b06 + a51 * b05 + a52 * b04 + a53 * b03 + a54 * b02 + a55 * b01 + a56 * b00 + carry);
        let (res57, carry) = split_64(a00 * b57 + a01 * b56 + a02 * b55 + a03 * b54 + a04 * b53 + a05 * b52 + a06 * b51 + a07 * b50 + a08 * b49 + a09 * b48 + a10 * b47 + a11 * b46 + a12 * b45 + a13 * b44 + a14 * b43 + a15 * b42 + a16 * b41 + a17 * b40 + a18 * b39 + a19 * b38 + a20 * b37 + a21 * b36 + a22 * b35 + a23 * b34 + a24 * b33 + a25 * b32 + a26 * b31 + a27 * b30 + a28 * b29 + a29 * b28 + a30 * b27 + a31 * b26 + a32 * b25 + a33 * b24 + a34 * b23 + a35 * b22 + a36 * b21 + a37 * b20 + a38 * b19 + a39 * b18 + a40 * b17 + a41 * b16 + a42 * b15 + a43 * b14 + a44 * b13 + a45 * b12 + a46 * b11 + a47 * b10 + a48 * b09 + a49 * b08 + a50 * b07 + a51 * b06 + a52 * b05 + a53 * b04 + a54 * b03 + a55 * b02 + a56 * b01 + a57 * b00 + carry);
        let (res58, carry) = split_64(a00 * b58 + a01 * b57 + a02 * b56 + a03 * b55 + a04 * b54 + a05 * b53 + a06 * b52 + a07 * b51 + a08 * b50 + a09 * b49 + a10 * b48 + a11 * b47 + a12 * b46 + a13 * b45 + a14 * b44 + a15 * b43 + a16 * b42 + a17 * b41 + a18 * b40 + a19 * b39 + a20 * b38 + a21 * b37 + a22 * b36 + a23 * b35 + a24 * b34 + a25 * b33 + a26 * b32 + a27 * b31 + a28 * b30 + a29 * b29 + a30 * b28 + a31 * b27 + a32 * b26 + a33 * b25 + a34 * b24 + a35 * b23 + a36 * b22 + a37 * b21 + a38 * b20 + a39 * b19 + a40 * b18 + a41 * b17 + a42 * b16 + a43 * b15 + a44 * b14 + a45 * b13 + a46 * b12 + a47 * b11 + a48 * b10 + a49 * b09 + a50 * b08 + a51 * b07 + a52 * b06 + a53 * b05 + a54 * b04 + a55 * b03 + a56 * b02 + a57 * b01 + a58 * b00 + carry);
        let (res59, carry) = split_64(a00 * b59 + a01 * b58 + a02 * b57 + a03 * b56 + a04 * b55 + a05 * b54 + a06 * b53 + a07 * b52 + a08 * b51 + a09 * b50 + a10 * b49 + a11 * b48 + a12 * b47 + a13 * b46 + a14 * b45 + a15 * b44 + a16 * b43 + a17 * b42 + a18 * b41 + a19 * b40 + a20 * b39 + a21 * b38 + a22 * b37 + a23 * b36 + a24 * b35 + a25 * b34 + a26 * b33 + a27 * b32 + a28 * b31 + a29 * b30 + a30 * b29 + a31 * b28 + a32 * b27 + a33 * b26 + a34 * b25 + a35 * b24 + a36 * b23 + a37 * b22 + a38 * b21 + a39 * b20 + a40 * b19 + a41 * b18 + a42 * b17 + a43 * b16 + a44 * b15 + a45 * b14 + a46 * b13 + a47 * b12 + a48 * b11 + a49 * b10 + a50 * b09 + a51 * b08 + a52 * b07 + a53 * b06 + a54 * b05 + a55 * b04 + a56 * b03 + a57 * b02 + a58 * b01 + a59 * b00 + carry);
        let (res60, carry) = split_64(a00 * b60 + a01 * b59 + a02 * b58 + a03 * b57 + a04 * b56 + a05 * b55 + a06 * b54 + a07 * b53 + a08 * b52 + a09 * b51 + a10 * b50 + a11 * b49 + a12 * b48 + a13 * b47 + a14 * b46 + a15 * b45 + a16 * b44 + a17 * b43 + a18 * b42 + a19 * b41 + a20 * b40 + a21 * b39 + a22 * b38 + a23 * b37 + a24 * b36 + a25 * b35 + a26 * b34 + a27 * b33 + a28 * b32 + a29 * b31 + a30 * b30 + a31 * b29 + a32 * b28 + a33 * b27 + a34 * b26 + a35 * b25 + a36 * b24 + a37 * b23 + a38 * b22 + a39 * b21 + a40 * b20 + a41 * b19 + a42 * b18 + a43 * b17 + a44 * b16 + a45 * b15 + a46 * b14 + a47 * b13 + a48 * b12 + a49 * b11 + a50 * b10 + a51 * b09 + a52 * b08 + a53 * b07 + a54 * b06 + a55 * b05 + a56 * b04 + a57 * b03 + a58 * b02 + a59 * b01 + a60 * b00 + carry);
        let (res61, carry) = split_64(a00 * b61 + a01 * b60 + a02 * b59 + a03 * b58 + a04 * b57 + a05 * b56 + a06 * b55 + a07 * b54 + a08 * b53 + a09 * b52 + a10 * b51 + a11 * b50 + a12 * b49 + a13 * b48 + a14 * b47 + a15 * b46 + a16 * b45 + a17 * b44 + a18 * b43 + a19 * b42 + a20 * b41 + a21 * b40 + a22 * b39 + a23 * b38 + a24 * b37 + a25 * b36 + a26 * b35 + a27 * b34 + a28 * b33 + a29 * b32 + a30 * b31 + a31 * b30 + a32 * b29 + a33 * b28 + a34 * b27 + a35 * b26 + a36 * b25 + a37 * b24 + a38 * b23 + a39 * b22 + a40 * b21 + a41 * b20 + a42 * b19 + a43 * b18 + a44 * b17 + a45 * b16 + a46 * b15 + a47 * b14 + a48 * b13 + a49 * b12 + a50 * b11 + a51 * b10 + a52 * b09 + a53 * b08 + a54 * b07 + a55 * b06 + a56 * b05 + a57 * b04 + a58 * b03 + a59 * b02 + a60 * b01 + a61 * b00 + carry);
        let (res62, carry) = split_64(a00 * b62 + a01 * b61 + a02 * b60 + a03 * b59 + a04 * b58 + a05 * b57 + a06 * b56 + a07 * b55 + a08 * b54 + a09 * b53 + a10 * b52 + a11 * b51 + a12 * b50 + a13 * b49 + a14 * b48 + a15 * b47 + a16 * b46 + a17 * b45 + a18 * b44 + a19 * b43 + a20 * b42 + a21 * b41 + a22 * b40 + a23 * b39 + a24 * b38 + a25 * b37 + a26 * b36 + a27 * b35 + a28 * b34 + a29 * b33 + a30 * b32 + a31 * b31 + a32 * b30 + a33 * b29 + a34 * b28 + a35 * b27 + a36 * b26 + a37 * b25 + a38 * b24 + a39 * b23 + a40 * b22 + a41 * b21 + a42 * b20 + a43 * b19 + a44 * b18 + a45 * b17 + a46 * b16 + a47 * b15 + a48 * b14 + a49 * b13 + a50 * b12 + a51 * b11 + a52 * b10 + a53 * b09 + a54 * b08 + a55 * b07 + a56 * b06 + a57 * b05 + a58 * b04 + a59 * b03 + a60 * b02 + a61 * b01 + a62 * b00 + carry);
        let (res63, carry) = split_64(a00 * b63 + a01 * b62 + a02 * b61 + a03 * b60 + a04 * b59 + a05 * b58 + a06 * b57 + a07 * b56 + a08 * b55 + a09 * b54 + a10 * b53 + a11 * b52 + a12 * b51 + a13 * b50 + a14 * b49 + a15 * b48 + a16 * b47 + a17 * b46 + a18 * b45 + a19 * b44 + a20 * b43 + a21 * b42 + a22 * b41 + a23 * b40 + a24 * b39 + a25 * b38 + a26 * b37 + a27 * b36 + a28 * b35 + a29 * b34 + a30 * b33 + a31 * b32 + a32 * b31 + a33 * b30 + a34 * b29 + a35 * b28 + a36 * b27 + a37 * b26 + a38 * b25 + a39 * b24 + a40 * b23 + a41 * b22 + a42 * b21 + a43 * b20 + a44 * b19 + a45 * b18 + a46 * b17 + a47 * b16 + a48 * b15 + a49 * b14 + a50 * b13 + a51 * b12 + a52 * b11 + a53 * b10 + a54 * b09 + a55 * b08 + a56 * b07 + a57 * b06 + a58 * b05 + a59 * b04 + a60 * b03 + a61 * b02 + a62 * b01 + a63 * b00 + carry);
        let (res64, carry) = split_64(a01 * b63 + a02 * b62 + a03 * b61 + a04 * b60 + a05 * b59 + a06 * b58 + a07 * b57 + a08 * b56 + a09 * b55 + a10 * b54 + a11 * b53 + a12 * b52 + a13 * b51 + a14 * b50 + a15 * b49 + a16 * b48 + a17 * b47 + a18 * b46 + a19 * b45 + a20 * b44 + a21 * b43 + a22 * b42 + a23 * b41 + a24 * b40 + a25 * b39 + a26 * b38 + a27 * b37 + a28 * b36 + a29 * b35 + a30 * b34 + a31 * b33 + a32 * b32 + a33 * b31 + a34 * b30 + a35 * b29 + a36 * b28 + a37 * b27 + a38 * b26 + a39 * b25 + a40 * b24 + a41 * b23 + a42 * b22 + a43 * b21 + a44 * b20 + a45 * b19 + a46 * b18 + a47 * b17 + a48 * b16 + a49 * b15 + a50 * b14 + a51 * b13 + a52 * b12 + a53 * b11 + a54 * b10 + a55 * b09 + a56 * b08 + a57 * b07 + a58 * b06 + a59 * b05 + a60 * b04 + a61 * b03 + a62 * b02 + a63 * b01 + carry);
        let (res65, carry) = split_64(a02 * b63 + a03 * b62 + a04 * b61 + a05 * b60 + a06 * b59 + a07 * b58 + a08 * b57 + a09 * b56 + a10 * b55 + a11 * b54 + a12 * b53 + a13 * b52 + a14 * b51 + a15 * b50 + a16 * b49 + a17 * b48 + a18 * b47 + a19 * b46 + a20 * b45 + a21 * b44 + a22 * b43 + a23 * b42 + a24 * b41 + a25 * b40 + a26 * b39 + a27 * b38 + a28 * b37 + a29 * b36 + a30 * b35 + a31 * b34 + a32 * b33 + a33 * b32 + a34 * b31 + a35 * b30 + a36 * b29 + a37 * b28 + a38 * b27 + a39 * b26 + a40 * b25 + a41 * b24 + a42 * b23 + a43 * b22 + a44 * b21 + a45 * b20 + a46 * b19 + a47 * b18 + a48 * b17 + a49 * b16 + a50 * b15 + a51 * b14 + a52 * b13 + a53 * b12 + a54 * b11 + a55 * b10 + a56 * b09 + a57 * b08 + a58 * b07 + a59 * b06 + a60 * b05 + a61 * b04 + a62 * b03 + a63 * b02 + carry);
        let (res66, carry) = split_64(a03 * b63 + a04 * b62 + a05 * b61 + a06 * b60 + a07 * b59 + a08 * b58 + a09 * b57 + a10 * b56 + a11 * b55 + a12 * b54 + a13 * b53 + a14 * b52 + a15 * b51 + a16 * b50 + a17 * b49 + a18 * b48 + a19 * b47 + a20 * b46 + a21 * b45 + a22 * b44 + a23 * b43 + a24 * b42 + a25 * b41 + a26 * b40 + a27 * b39 + a28 * b38 + a29 * b37 + a30 * b36 + a31 * b35 + a32 * b34 + a33 * b33 + a34 * b32 + a35 * b31 + a36 * b30 + a37 * b29 + a38 * b28 + a39 * b27 + a40 * b26 + a41 * b25 + a42 * b24 + a43 * b23 + a44 * b22 + a45 * b21 + a46 * b20 + a47 * b19 + a48 * b18 + a49 * b17 + a50 * b16 + a51 * b15 + a52 * b14 + a53 * b13 + a54 * b12 + a55 * b11 + a56 * b10 + a57 * b09 + a58 * b08 + a59 * b07 + a60 * b06 + a61 * b05 + a62 * b04 + a63 * b03 + carry);
        let (res67, carry) = split_64(a04 * b63 + a05 * b62 + a06 * b61 + a07 * b60 + a08 * b59 + a09 * b58 + a10 * b57 + a11 * b56 + a12 * b55 + a13 * b54 + a14 * b53 + a15 * b52 + a16 * b51 + a17 * b50 + a18 * b49 + a19 * b48 + a20 * b47 + a21 * b46 + a22 * b45 + a23 * b44 + a24 * b43 + a25 * b42 + a26 * b41 + a27 * b40 + a28 * b39 + a29 * b38 + a30 * b37 + a31 * b36 + a32 * b35 + a33 * b34 + a34 * b33 + a35 * b32 + a36 * b31 + a37 * b30 + a38 * b29 + a39 * b28 + a40 * b27 + a41 * b26 + a42 * b25 + a43 * b24 + a44 * b23 + a45 * b22 + a46 * b21 + a47 * b20 + a48 * b19 + a49 * b18 + a50 * b17 + a51 * b16 + a52 * b15 + a53 * b14 + a54 * b13 + a55 * b12 + a56 * b11 + a57 * b10 + a58 * b09 + a59 * b08 + a60 * b07 + a61 * b06 + a62 * b05 + a63 * b04 + carry);
        let (res68, carry) = split_64(a05 * b63 + a06 * b62 + a07 * b61 + a08 * b60 + a09 * b59 + a10 * b58 + a11 * b57 + a12 * b56 + a13 * b55 + a14 * b54 + a15 * b53 + a16 * b52 + a17 * b51 + a18 * b50 + a19 * b49 + a20 * b48 + a21 * b47 + a22 * b46 + a23 * b45 + a24 * b44 + a25 * b43 + a26 * b42 + a27 * b41 + a28 * b40 + a29 * b39 + a30 * b38 + a31 * b37 + a32 * b36 + a33 * b35 + a34 * b34 + a35 * b33 + a36 * b32 + a37 * b31 + a38 * b30 + a39 * b29 + a40 * b28 + a41 * b27 + a42 * b26 + a43 * b25 + a44 * b24 + a45 * b23 + a46 * b22 + a47 * b21 + a48 * b20 + a49 * b19 + a50 * b18 + a51 * b17 + a52 * b16 + a53 * b15 + a54 * b14 + a55 * b13 + a56 * b12 + a57 * b11 + a58 * b10 + a59 * b09 + a60 * b08 + a61 * b07 + a62 * b06 + a63 * b05 + carry);
        let (res69, carry) = split_64(a06 * b63 + a07 * b62 + a08 * b61 + a09 * b60 + a10 * b59 + a11 * b58 + a12 * b57 + a13 * b56 + a14 * b55 + a15 * b54 + a16 * b53 + a17 * b52 + a18 * b51 + a19 * b50 + a20 * b49 + a21 * b48 + a22 * b47 + a23 * b46 + a24 * b45 + a25 * b44 + a26 * b43 + a27 * b42 + a28 * b41 + a29 * b40 + a30 * b39 + a31 * b38 + a32 * b37 + a33 * b36 + a34 * b35 + a35 * b34 + a36 * b33 + a37 * b32 + a38 * b31 + a39 * b30 + a40 * b29 + a41 * b28 + a42 * b27 + a43 * b26 + a44 * b25 + a45 * b24 + a46 * b23 + a47 * b22 + a48 * b21 + a49 * b20 + a50 * b19 + a51 * b18 + a52 * b17 + a53 * b16 + a54 * b15 + a55 * b14 + a56 * b13 + a57 * b12 + a58 * b11 + a59 * b10 + a60 * b09 + a61 * b08 + a62 * b07 + a63 * b06 + carry);
        let (res70, carry) = split_64(a07 * b63 + a08 * b62 + a09 * b61 + a10 * b60 + a11 * b59 + a12 * b58 + a13 * b57 + a14 * b56 + a15 * b55 + a16 * b54 + a17 * b53 + a18 * b52 + a19 * b51 + a20 * b50 + a21 * b49 + a22 * b48 + a23 * b47 + a24 * b46 + a25 * b45 + a26 * b44 + a27 * b43 + a28 * b42 + a29 * b41 + a30 * b40 + a31 * b39 + a32 * b38 + a33 * b37 + a34 * b36 + a35 * b35 + a36 * b34 + a37 * b33 + a38 * b32 + a39 * b31 + a40 * b30 + a41 * b29 + a42 * b28 + a43 * b27 + a44 * b26 + a45 * b25 + a46 * b24 + a47 * b23 + a48 * b22 + a49 * b21 + a50 * b20 + a51 * b19 + a52 * b18 + a53 * b17 + a54 * b16 + a55 * b15 + a56 * b14 + a57 * b13 + a58 * b12 + a59 * b11 + a60 * b10 + a61 * b09 + a62 * b08 + a63 * b07 + carry);
        let (res71, carry) = split_64(a08 * b63 + a09 * b62 + a10 * b61 + a11 * b60 + a12 * b59 + a13 * b58 + a14 * b57 + a15 * b56 + a16 * b55 + a17 * b54 + a18 * b53 + a19 * b52 + a20 * b51 + a21 * b50 + a22 * b49 + a23 * b48 + a24 * b47 + a25 * b46 + a26 * b45 + a27 * b44 + a28 * b43 + a29 * b42 + a30 * b41 + a31 * b40 + a32 * b39 + a33 * b38 + a34 * b37 + a35 * b36 + a36 * b35 + a37 * b34 + a38 * b33 + a39 * b32 + a40 * b31 + a41 * b30 + a42 * b29 + a43 * b28 + a44 * b27 + a45 * b26 + a46 * b25 + a47 * b24 + a48 * b23 + a49 * b22 + a50 * b21 + a51 * b20 + a52 * b19 + a53 * b18 + a54 * b17 + a55 * b16 + a56 * b15 + a57 * b14 + a58 * b13 + a59 * b12 + a60 * b11 + a61 * b10 + a62 * b09 + a63 * b08 + carry);
        let (res72, carry) = split_64(a09 * b63 + a10 * b62 + a11 * b61 + a12 * b60 + a13 * b59 + a14 * b58 + a15 * b57 + a16 * b56 + a17 * b55 + a18 * b54 + a19 * b53 + a20 * b52 + a21 * b51 + a22 * b50 + a23 * b49 + a24 * b48 + a25 * b47 + a26 * b46 + a27 * b45 + a28 * b44 + a29 * b43 + a30 * b42 + a31 * b41 + a32 * b40 + a33 * b39 + a34 * b38 + a35 * b37 + a36 * b36 + a37 * b35 + a38 * b34 + a39 * b33 + a40 * b32 + a41 * b31 + a42 * b30 + a43 * b29 + a44 * b28 + a45 * b27 + a46 * b26 + a47 * b25 + a48 * b24 + a49 * b23 + a50 * b22 + a51 * b21 + a52 * b20 + a53 * b19 + a54 * b18 + a55 * b17 + a56 * b16 + a57 * b15 + a58 * b14 + a59 * b13 + a60 * b12 + a61 * b11 + a62 * b10 + a63 * b09 + carry);
        let (res73, carry) = split_64(a10 * b63 + a11 * b62 + a12 * b61 + a13 * b60 + a14 * b59 + a15 * b58 + a16 * b57 + a17 * b56 + a18 * b55 + a19 * b54 + a20 * b53 + a21 * b52 + a22 * b51 + a23 * b50 + a24 * b49 + a25 * b48 + a26 * b47 + a27 * b46 + a28 * b45 + a29 * b44 + a30 * b43 + a31 * b42 + a32 * b41 + a33 * b40 + a34 * b39 + a35 * b38 + a36 * b37 + a37 * b36 + a38 * b35 + a39 * b34 + a40 * b33 + a41 * b32 + a42 * b31 + a43 * b30 + a44 * b29 + a45 * b28 + a46 * b27 + a47 * b26 + a48 * b25 + a49 * b24 + a50 * b23 + a51 * b22 + a52 * b21 + a53 * b20 + a54 * b19 + a55 * b18 + a56 * b17 + a57 * b16 + a58 * b15 + a59 * b14 + a60 * b13 + a61 * b12 + a62 * b11 + a63 * b10 + carry);
        let (res74, carry) = split_64(a11 * b63 + a12 * b62 + a13 * b61 + a14 * b60 + a15 * b59 + a16 * b58 + a17 * b57 + a18 * b56 + a19 * b55 + a20 * b54 + a21 * b53 + a22 * b52 + a23 * b51 + a24 * b50 + a25 * b49 + a26 * b48 + a27 * b47 + a28 * b46 + a29 * b45 + a30 * b44 + a31 * b43 + a32 * b42 + a33 * b41 + a34 * b40 + a35 * b39 + a36 * b38 + a37 * b37 + a38 * b36 + a39 * b35 + a40 * b34 + a41 * b33 + a42 * b32 + a43 * b31 + a44 * b30 + a45 * b29 + a46 * b28 + a47 * b27 + a48 * b26 + a49 * b25 + a50 * b24 + a51 * b23 + a52 * b22 + a53 * b21 + a54 * b20 + a55 * b19 + a56 * b18 + a57 * b17 + a58 * b16 + a59 * b15 + a60 * b14 + a61 * b13 + a62 * b12 + a63 * b11 + carry);
        let (res75, carry) = split_64(a12 * b63 + a13 * b62 + a14 * b61 + a15 * b60 + a16 * b59 + a17 * b58 + a18 * b57 + a19 * b56 + a20 * b55 + a21 * b54 + a22 * b53 + a23 * b52 + a24 * b51 + a25 * b50 + a26 * b49 + a27 * b48 + a28 * b47 + a29 * b46 + a30 * b45 + a31 * b44 + a32 * b43 + a33 * b42 + a34 * b41 + a35 * b40 + a36 * b39 + a37 * b38 + a38 * b37 + a39 * b36 + a40 * b35 + a41 * b34 + a42 * b33 + a43 * b32 + a44 * b31 + a45 * b30 + a46 * b29 + a47 * b28 + a48 * b27 + a49 * b26 + a50 * b25 + a51 * b24 + a52 * b23 + a53 * b22 + a54 * b21 + a55 * b20 + a56 * b19 + a57 * b18 + a58 * b17 + a59 * b16 + a60 * b15 + a61 * b14 + a62 * b13 + a63 * b12 + carry);
        let (res76, carry) = split_64(a13 * b63 + a14 * b62 + a15 * b61 + a16 * b60 + a17 * b59 + a18 * b58 + a19 * b57 + a20 * b56 + a21 * b55 + a22 * b54 + a23 * b53 + a24 * b52 + a25 * b51 + a26 * b50 + a27 * b49 + a28 * b48 + a29 * b47 + a30 * b46 + a31 * b45 + a32 * b44 + a33 * b43 + a34 * b42 + a35 * b41 + a36 * b40 + a37 * b39 + a38 * b38 + a39 * b37 + a40 * b36 + a41 * b35 + a42 * b34 + a43 * b33 + a44 * b32 + a45 * b31 + a46 * b30 + a47 * b29 + a48 * b28 + a49 * b27 + a50 * b26 + a51 * b25 + a52 * b24 + a53 * b23 + a54 * b22 + a55 * b21 + a56 * b20 + a57 * b19 + a58 * b18 + a59 * b17 + a60 * b16 + a61 * b15 + a62 * b14 + a63 * b13 + carry);
        let (res77, carry) = split_64(a14 * b63 + a15 * b62 + a16 * b61 + a17 * b60 + a18 * b59 + a19 * b58 + a20 * b57 + a21 * b56 + a22 * b55 + a23 * b54 + a24 * b53 + a25 * b52 + a26 * b51 + a27 * b50 + a28 * b49 + a29 * b48 + a30 * b47 + a31 * b46 + a32 * b45 + a33 * b44 + a34 * b43 + a35 * b42 + a36 * b41 + a37 * b40 + a38 * b39 + a39 * b38 + a40 * b37 + a41 * b36 + a42 * b35 + a43 * b34 + a44 * b33 + a45 * b32 + a46 * b31 + a47 * b30 + a48 * b29 + a49 * b28 + a50 * b27 + a51 * b26 + a52 * b25 + a53 * b24 + a54 * b23 + a55 * b22 + a56 * b21 + a57 * b20 + a58 * b19 + a59 * b18 + a60 * b17 + a61 * b16 + a62 * b15 + a63 * b14 + carry);
        let (res78, carry) = split_64(a15 * b63 + a16 * b62 + a17 * b61 + a18 * b60 + a19 * b59 + a20 * b58 + a21 * b57 + a22 * b56 + a23 * b55 + a24 * b54 + a25 * b53 + a26 * b52 + a27 * b51 + a28 * b50 + a29 * b49 + a30 * b48 + a31 * b47 + a32 * b46 + a33 * b45 + a34 * b44 + a35 * b43 + a36 * b42 + a37 * b41 + a38 * b40 + a39 * b39 + a40 * b38 + a41 * b37 + a42 * b36 + a43 * b35 + a44 * b34 + a45 * b33 + a46 * b32 + a47 * b31 + a48 * b30 + a49 * b29 + a50 * b28 + a51 * b27 + a52 * b26 + a53 * b25 + a54 * b24 + a55 * b23 + a56 * b22 + a57 * b21 + a58 * b20 + a59 * b19 + a60 * b18 + a61 * b17 + a62 * b16 + a63 * b15 + carry);
        let (res79, carry) = split_64(a16 * b63 + a17 * b62 + a18 * b61 + a19 * b60 + a20 * b59 + a21 * b58 + a22 * b57 + a23 * b56 + a24 * b55 + a25 * b54 + a26 * b53 + a27 * b52 + a28 * b51 + a29 * b50 + a30 * b49 + a31 * b48 + a32 * b47 + a33 * b46 + a34 * b45 + a35 * b44 + a36 * b43 + a37 * b42 + a38 * b41 + a39 * b40 + a40 * b39 + a41 * b38 + a42 * b37 + a43 * b36 + a44 * b35 + a45 * b34 + a46 * b33 + a47 * b32 + a48 * b31 + a49 * b30 + a50 * b29 + a51 * b28 + a52 * b27 + a53 * b26 + a54 * b25 + a55 * b24 + a56 * b23 + a57 * b22 + a58 * b21 + a59 * b20 + a60 * b19 + a61 * b18 + a62 * b17 + a63 * b16 + carry);
        let (res80, carry) = split_64(a17 * b63 + a18 * b62 + a19 * b61 + a20 * b60 + a21 * b59 + a22 * b58 + a23 * b57 + a24 * b56 + a25 * b55 + a26 * b54 + a27 * b53 + a28 * b52 + a29 * b51 + a30 * b50 + a31 * b49 + a32 * b48 + a33 * b47 + a34 * b46 + a35 * b45 + a36 * b44 + a37 * b43 + a38 * b42 + a39 * b41 + a40 * b40 + a41 * b39 + a42 * b38 + a43 * b37 + a44 * b36 + a45 * b35 + a46 * b34 + a47 * b33 + a48 * b32 + a49 * b31 + a50 * b30 + a51 * b29 + a52 * b28 + a53 * b27 + a54 * b26 + a55 * b25 + a56 * b24 + a57 * b23 + a58 * b22 + a59 * b21 + a60 * b20 + a61 * b19 + a62 * b18 + a63 * b17 + carry);
        let (res81, carry) = split_64(a18 * b63 + a19 * b62 + a20 * b61 + a21 * b60 + a22 * b59 + a23 * b58 + a24 * b57 + a25 * b56 + a26 * b55 + a27 * b54 + a28 * b53 + a29 * b52 + a30 * b51 + a31 * b50 + a32 * b49 + a33 * b48 + a34 * b47 + a35 * b46 + a36 * b45 + a37 * b44 + a38 * b43 + a39 * b42 + a40 * b41 + a41 * b40 + a42 * b39 + a43 * b38 + a44 * b37 + a45 * b36 + a46 * b35 + a47 * b34 + a48 * b33 + a49 * b32 + a50 * b31 + a51 * b30 + a52 * b29 + a53 * b28 + a54 * b27 + a55 * b26 + a56 * b25 + a57 * b24 + a58 * b23 + a59 * b22 + a60 * b21 + a61 * b20 + a62 * b19 + a63 * b18 + carry);
        let (res82, carry) = split_64(a19 * b63 + a20 * b62 + a21 * b61 + a22 * b60 + a23 * b59 + a24 * b58 + a25 * b57 + a26 * b56 + a27 * b55 + a28 * b54 + a29 * b53 + a30 * b52 + a31 * b51 + a32 * b50 + a33 * b49 + a34 * b48 + a35 * b47 + a36 * b46 + a37 * b45 + a38 * b44 + a39 * b43 + a40 * b42 + a41 * b41 + a42 * b40 + a43 * b39 + a44 * b38 + a45 * b37 + a46 * b36 + a47 * b35 + a48 * b34 + a49 * b33 + a50 * b32 + a51 * b31 + a52 * b30 + a53 * b29 + a54 * b28 + a55 * b27 + a56 * b26 + a57 * b25 + a58 * b24 + a59 * b23 + a60 * b22 + a61 * b21 + a62 * b20 + a63 * b19 + carry);
        let (res83, carry) = split_64(a20 * b63 + a21 * b62 + a22 * b61 + a23 * b60 + a24 * b59 + a25 * b58 + a26 * b57 + a27 * b56 + a28 * b55 + a29 * b54 + a30 * b53 + a31 * b52 + a32 * b51 + a33 * b50 + a34 * b49 + a35 * b48 + a36 * b47 + a37 * b46 + a38 * b45 + a39 * b44 + a40 * b43 + a41 * b42 + a42 * b41 + a43 * b40 + a44 * b39 + a45 * b38 + a46 * b37 + a47 * b36 + a48 * b35 + a49 * b34 + a50 * b33 + a51 * b32 + a52 * b31 + a53 * b30 + a54 * b29 + a55 * b28 + a56 * b27 + a57 * b26 + a58 * b25 + a59 * b24 + a60 * b23 + a61 * b22 + a62 * b21 + a63 * b20 + carry);
        let (res84, carry) = split_64(a21 * b63 + a22 * b62 + a23 * b61 + a24 * b60 + a25 * b59 + a26 * b58 + a27 * b57 + a28 * b56 + a29 * b55 + a30 * b54 + a31 * b53 + a32 * b52 + a33 * b51 + a34 * b50 + a35 * b49 + a36 * b48 + a37 * b47 + a38 * b46 + a39 * b45 + a40 * b44 + a41 * b43 + a42 * b42 + a43 * b41 + a44 * b40 + a45 * b39 + a46 * b38 + a47 * b37 + a48 * b36 + a49 * b35 + a50 * b34 + a51 * b33 + a52 * b32 + a53 * b31 + a54 * b30 + a55 * b29 + a56 * b28 + a57 * b27 + a58 * b26 + a59 * b25 + a60 * b24 + a61 * b23 + a62 * b22 + a63 * b21 + carry);
        let (res85, carry) = split_64(a22 * b63 + a23 * b62 + a24 * b61 + a25 * b60 + a26 * b59 + a27 * b58 + a28 * b57 + a29 * b56 + a30 * b55 + a31 * b54 + a32 * b53 + a33 * b52 + a34 * b51 + a35 * b50 + a36 * b49 + a37 * b48 + a38 * b47 + a39 * b46 + a40 * b45 + a41 * b44 + a42 * b43 + a43 * b42 + a44 * b41 + a45 * b40 + a46 * b39 + a47 * b38 + a48 * b37 + a49 * b36 + a50 * b35 + a51 * b34 + a52 * b33 + a53 * b32 + a54 * b31 + a55 * b30 + a56 * b29 + a57 * b28 + a58 * b27 + a59 * b26 + a60 * b25 + a61 * b24 + a62 * b23 + a63 * b22 + carry);
        let (res86, carry) = split_64(a23 * b63 + a24 * b62 + a25 * b61 + a26 * b60 + a27 * b59 + a28 * b58 + a29 * b57 + a30 * b56 + a31 * b55 + a32 * b54 + a33 * b53 + a34 * b52 + a35 * b51 + a36 * b50 + a37 * b49 + a38 * b48 + a39 * b47 + a40 * b46 + a41 * b45 + a42 * b44 + a43 * b43 + a44 * b42 + a45 * b41 + a46 * b40 + a47 * b39 + a48 * b38 + a49 * b37 + a50 * b36 + a51 * b35 + a52 * b34 + a53 * b33 + a54 * b32 + a55 * b31 + a56 * b30 + a57 * b29 + a58 * b28 + a59 * b27 + a60 * b26 + a61 * b25 + a62 * b24 + a63 * b23 + carry);
        let (res87, carry) = split_64(a24 * b63 + a25 * b62 + a26 * b61 + a27 * b60 + a28 * b59 + a29 * b58 + a30 * b57 + a31 * b56 + a32 * b55 + a33 * b54 + a34 * b53 + a35 * b52 + a36 * b51 + a37 * b50 + a38 * b49 + a39 * b48 + a40 * b47 + a41 * b46 + a42 * b45 + a43 * b44 + a44 * b43 + a45 * b42 + a46 * b41 + a47 * b40 + a48 * b39 + a49 * b38 + a50 * b37 + a51 * b36 + a52 * b35 + a53 * b34 + a54 * b33 + a55 * b32 + a56 * b31 + a57 * b30 + a58 * b29 + a59 * b28 + a60 * b27 + a61 * b26 + a62 * b25 + a63 * b24 + carry);
        let (res88, carry) = split_64(a25 * b63 + a26 * b62 + a27 * b61 + a28 * b60 + a29 * b59 + a30 * b58 + a31 * b57 + a32 * b56 + a33 * b55 + a34 * b54 + a35 * b53 + a36 * b52 + a37 * b51 + a38 * b50 + a39 * b49 + a40 * b48 + a41 * b47 + a42 * b46 + a43 * b45 + a44 * b44 + a45 * b43 + a46 * b42 + a47 * b41 + a48 * b40 + a49 * b39 + a50 * b38 + a51 * b37 + a52 * b36 + a53 * b35 + a54 * b34 + a55 * b33 + a56 * b32 + a57 * b31 + a58 * b30 + a59 * b29 + a60 * b28 + a61 * b27 + a62 * b26 + a63 * b25 + carry);
        let (res89, carry) = split_64(a26 * b63 + a27 * b62 + a28 * b61 + a29 * b60 + a30 * b59 + a31 * b58 + a32 * b57 + a33 * b56 + a34 * b55 + a35 * b54 + a36 * b53 + a37 * b52 + a38 * b51 + a39 * b50 + a40 * b49 + a41 * b48 + a42 * b47 + a43 * b46 + a44 * b45 + a45 * b44 + a46 * b43 + a47 * b42 + a48 * b41 + a49 * b40 + a50 * b39 + a51 * b38 + a52 * b37 + a53 * b36 + a54 * b35 + a55 * b34 + a56 * b33 + a57 * b32 + a58 * b31 + a59 * b30 + a60 * b29 + a61 * b28 + a62 * b27 + a63 * b26 + carry);
        let (res90, carry) = split_64(a27 * b63 + a28 * b62 + a29 * b61 + a30 * b60 + a31 * b59 + a32 * b58 + a33 * b57 + a34 * b56 + a35 * b55 + a36 * b54 + a37 * b53 + a38 * b52 + a39 * b51 + a40 * b50 + a41 * b49 + a42 * b48 + a43 * b47 + a44 * b46 + a45 * b45 + a46 * b44 + a47 * b43 + a48 * b42 + a49 * b41 + a50 * b40 + a51 * b39 + a52 * b38 + a53 * b37 + a54 * b36 + a55 * b35 + a56 * b34 + a57 * b33 + a58 * b32 + a59 * b31 + a60 * b30 + a61 * b29 + a62 * b28 + a63 * b27 + carry);
        let (res91, carry) = split_64(a28 * b63 + a29 * b62 + a30 * b61 + a31 * b60 + a32 * b59 + a33 * b58 + a34 * b57 + a35 * b56 + a36 * b55 + a37 * b54 + a38 * b53 + a39 * b52 + a40 * b51 + a41 * b50 + a42 * b49 + a43 * b48 + a44 * b47 + a45 * b46 + a46 * b45 + a47 * b44 + a48 * b43 + a49 * b42 + a50 * b41 + a51 * b40 + a52 * b39 + a53 * b38 + a54 * b37 + a55 * b36 + a56 * b35 + a57 * b34 + a58 * b33 + a59 * b32 + a60 * b31 + a61 * b30 + a62 * b29 + a63 * b28 + carry);
        let (res92, carry) = split_64(a29 * b63 + a30 * b62 + a31 * b61 + a32 * b60 + a33 * b59 + a34 * b58 + a35 * b57 + a36 * b56 + a37 * b55 + a38 * b54 + a39 * b53 + a40 * b52 + a41 * b51 + a42 * b50 + a43 * b49 + a44 * b48 + a45 * b47 + a46 * b46 + a47 * b45 + a48 * b44 + a49 * b43 + a50 * b42 + a51 * b41 + a52 * b40 + a53 * b39 + a54 * b38 + a55 * b37 + a56 * b36 + a57 * b35 + a58 * b34 + a59 * b33 + a60 * b32 + a61 * b31 + a62 * b30 + a63 * b29 + carry);
        let (res93, carry) = split_64(a30 * b63 + a31 * b62 + a32 * b61 + a33 * b60 + a34 * b59 + a35 * b58 + a36 * b57 + a37 * b56 + a38 * b55 + a39 * b54 + a40 * b53 + a41 * b52 + a42 * b51 + a43 * b50 + a44 * b49 + a45 * b48 + a46 * b47 + a47 * b46 + a48 * b45 + a49 * b44 + a50 * b43 + a51 * b42 + a52 * b41 + a53 * b40 + a54 * b39 + a55 * b38 + a56 * b37 + a57 * b36 + a58 * b35 + a59 * b34 + a60 * b33 + a61 * b32 + a62 * b31 + a63 * b30 + carry);
        let (res94, carry) = split_64(a31 * b63 + a32 * b62 + a33 * b61 + a34 * b60 + a35 * b59 + a36 * b58 + a37 * b57 + a38 * b56 + a39 * b55 + a40 * b54 + a41 * b53 + a42 * b52 + a43 * b51 + a44 * b50 + a45 * b49 + a46 * b48 + a47 * b47 + a48 * b46 + a49 * b45 + a50 * b44 + a51 * b43 + a52 * b42 + a53 * b41 + a54 * b40 + a55 * b39 + a56 * b38 + a57 * b37 + a58 * b36 + a59 * b35 + a60 * b34 + a61 * b33 + a62 * b32 + a63 * b31 + carry);
        let (res95, carry) = split_64(a32 * b63 + a33 * b62 + a34 * b61 + a35 * b60 + a36 * b59 + a37 * b58 + a38 * b57 + a39 * b56 + a40 * b55 + a41 * b54 + a42 * b53 + a43 * b52 + a44 * b51 + a45 * b50 + a46 * b49 + a47 * b48 + a48 * b47 + a49 * b46 + a50 * b45 + a51 * b44 + a52 * b43 + a53 * b42 + a54 * b41 + a55 * b40 + a56 * b39 + a57 * b38 + a58 * b37 + a59 * b36 + a60 * b35 + a61 * b34 + a62 * b33 + a63 * b32 + carry);
        let (res96, carry) = split_64(a33 * b63 + a34 * b62 + a35 * b61 + a36 * b60 + a37 * b59 + a38 * b58 + a39 * b57 + a40 * b56 + a41 * b55 + a42 * b54 + a43 * b53 + a44 * b52 + a45 * b51 + a46 * b50 + a47 * b49 + a48 * b48 + a49 * b47 + a50 * b46 + a51 * b45 + a52 * b44 + a53 * b43 + a54 * b42 + a55 * b41 + a56 * b40 + a57 * b39 + a58 * b38 + a59 * b37 + a60 * b36 + a61 * b35 + a62 * b34 + a63 * b33 + carry);
        let (res97, carry) = split_64(a34 * b63 + a35 * b62 + a36 * b61 + a37 * b60 + a38 * b59 + a39 * b58 + a40 * b57 + a41 * b56 + a42 * b55 + a43 * b54 + a44 * b53 + a45 * b52 + a46 * b51 + a47 * b50 + a48 * b49 + a49 * b48 + a50 * b47 + a51 * b46 + a52 * b45 + a53 * b44 + a54 * b43 + a55 * b42 + a56 * b41 + a57 * b40 + a58 * b39 + a59 * b38 + a60 * b37 + a61 * b36 + a62 * b35 + a63 * b34 + carry);
        let (res98, carry) = split_64(a35 * b63 + a36 * b62 + a37 * b61 + a38 * b60 + a39 * b59 + a40 * b58 + a41 * b57 + a42 * b56 + a43 * b55 + a44 * b54 + a45 * b53 + a46 * b52 + a47 * b51 + a48 * b50 + a49 * b49 + a50 * b48 + a51 * b47 + a52 * b46 + a53 * b45 + a54 * b44 + a55 * b43 + a56 * b42 + a57 * b41 + a58 * b40 + a59 * b39 + a60 * b38 + a61 * b37 + a62 * b36 + a63 * b35 + carry);
        let (res99, carry) = split_64(a36 * b63 + a37 * b62 + a38 * b61 + a39 * b60 + a40 * b59 + a41 * b58 + a42 * b57 + a43 * b56 + a44 * b55 + a45 * b54 + a46 * b53 + a47 * b52 + a48 * b51 + a49 * b50 + a50 * b49 + a51 * b48 + a52 * b47 + a53 * b46 + a54 * b45 + a55 * b44 + a56 * b43 + a57 * b42 + a58 * b41 + a59 * b40 + a60 * b39 + a61 * b38 + a62 * b37 + a63 * b36 + carry);
        let (res100, carry) = split_64(a37 * b63 + a38 * b62 + a39 * b61 + a40 * b60 + a41 * b59 + a42 * b58 + a43 * b57 + a44 * b56 + a45 * b55 + a46 * b54 + a47 * b53 + a48 * b52 + a49 * b51 + a50 * b50 + a51 * b49 + a52 * b48 + a53 * b47 + a54 * b46 + a55 * b45 + a56 * b44 + a57 * b43 + a58 * b42 + a59 * b41 + a60 * b40 + a61 * b39 + a62 * b38 + a63 * b37 + carry);
        let (res101, carry) = split_64(a38 * b63 + a39 * b62 + a40 * b61 + a41 * b60 + a42 * b59 + a43 * b58 + a44 * b57 + a45 * b56 + a46 * b55 + a47 * b54 + a48 * b53 + a49 * b52 + a50 * b51 + a51 * b50 + a52 * b49 + a53 * b48 + a54 * b47 + a55 * b46 + a56 * b45 + a57 * b44 + a58 * b43 + a59 * b42 + a60 * b41 + a61 * b40 + a62 * b39 + a63 * b38 + carry);
        let (res102, carry) = split_64(a39 * b63 + a40 * b62 + a41 * b61 + a42 * b60 + a43 * b59 + a44 * b58 + a45 * b57 + a46 * b56 + a47 * b55 + a48 * b54 + a49 * b53 + a50 * b52 + a51 * b51 + a52 * b50 + a53 * b49 + a54 * b48 + a55 * b47 + a56 * b46 + a57 * b45 + a58 * b44 + a59 * b43 + a60 * b42 + a61 * b41 + a62 * b40 + a63 * b39 + carry);
        let (res103, carry) = split_64(a40 * b63 + a41 * b62 + a42 * b61 + a43 * b60 + a44 * b59 + a45 * b58 + a46 * b57 + a47 * b56 + a48 * b55 + a49 * b54 + a50 * b53 + a51 * b52 + a52 * b51 + a53 * b50 + a54 * b49 + a55 * b48 + a56 * b47 + a57 * b46 + a58 * b45 + a59 * b44 + a60 * b43 + a61 * b42 + a62 * b41 + a63 * b40 + carry);
        let (res104, carry) = split_64(a41 * b63 + a42 * b62 + a43 * b61 + a44 * b60 + a45 * b59 + a46 * b58 + a47 * b57 + a48 * b56 + a49 * b55 + a50 * b54 + a51 * b53 + a52 * b52 + a53 * b51 + a54 * b50 + a55 * b49 + a56 * b48 + a57 * b47 + a58 * b46 + a59 * b45 + a60 * b44 + a61 * b43 + a62 * b42 + a63 * b41 + carry);
        let (res105, carry) = split_64(a42 * b63 + a43 * b62 + a44 * b61 + a45 * b60 + a46 * b59 + a47 * b58 + a48 * b57 + a49 * b56 + a50 * b55 + a51 * b54 + a52 * b53 + a53 * b52 + a54 * b51 + a55 * b50 + a56 * b49 + a57 * b48 + a58 * b47 + a59 * b46 + a60 * b45 + a61 * b44 + a62 * b43 + a63 * b42 + carry);
        let (res106, carry) = split_64(a43 * b63 + a44 * b62 + a45 * b61 + a46 * b60 + a47 * b59 + a48 * b58 + a49 * b57 + a50 * b56 + a51 * b55 + a52 * b54 + a53 * b53 + a54 * b52 + a55 * b51 + a56 * b50 + a57 * b49 + a58 * b48 + a59 * b47 + a60 * b46 + a61 * b45 + a62 * b44 + a63 * b43 + carry);
        let (res107, carry) = split_64(a44 * b63 + a45 * b62 + a46 * b61 + a47 * b60 + a48 * b59 + a49 * b58 + a50 * b57 + a51 * b56 + a52 * b55 + a53 * b54 + a54 * b53 + a55 * b52 + a56 * b51 + a57 * b50 + a58 * b49 + a59 * b48 + a60 * b47 + a61 * b46 + a62 * b45 + a63 * b44 + carry);
        let (res108, carry) = split_64(a45 * b63 + a46 * b62 + a47 * b61 + a48 * b60 + a49 * b59 + a50 * b58 + a51 * b57 + a52 * b56 + a53 * b55 + a54 * b54 + a55 * b53 + a56 * b52 + a57 * b51 + a58 * b50 + a59 * b49 + a60 * b48 + a61 * b47 + a62 * b46 + a63 * b45 + carry);
        let (res109, carry) = split_64(a46 * b63 + a47 * b62 + a48 * b61 + a49 * b60 + a50 * b59 + a51 * b58 + a52 * b57 + a53 * b56 + a54 * b55 + a55 * b54 + a56 * b53 + a57 * b52 + a58 * b51 + a59 * b50 + a60 * b49 + a61 * b48 + a62 * b47 + a63 * b46 + carry);
        let (res110, carry) = split_64(a47 * b63 + a48 * b62 + a49 * b61 + a50 * b60 + a51 * b59 + a52 * b58 + a53 * b57 + a54 * b56 + a55 * b55 + a56 * b54 + a57 * b53 + a58 * b52 + a59 * b51 + a60 * b50 + a61 * b49 + a62 * b48 + a63 * b47 + carry);
        let (res111, carry) = split_64(a48 * b63 + a49 * b62 + a50 * b61 + a51 * b60 + a52 * b59 + a53 * b58 + a54 * b57 + a55 * b56 + a56 * b55 + a57 * b54 + a58 * b53 + a59 * b52 + a60 * b51 + a61 * b50 + a62 * b49 + a63 * b48 + carry);
        let (res112, carry) = split_64(a49 * b63 + a50 * b62 + a51 * b61 + a52 * b60 + a53 * b59 + a54 * b58 + a55 * b57 + a56 * b56 + a57 * b55 + a58 * b54 + a59 * b53 + a60 * b52 + a61 * b51 + a62 * b50 + a63 * b49 + carry);
        let (res113, carry) = split_64(a50 * b63 + a51 * b62 + a52 * b61 + a53 * b60 + a54 * b59 + a55 * b58 + a56 * b57 + a57 * b56 + a58 * b55 + a59 * b54 + a60 * b53 + a61 * b52 + a62 * b51 + a63 * b50 + carry);
        let (res114, carry) = split_64(a51 * b63 + a52 * b62 + a53 * b61 + a54 * b60 + a55 * b59 + a56 * b58 + a57 * b57 + a58 * b56 + a59 * b55 + a60 * b54 + a61 * b53 + a62 * b52 + a63 * b51 + carry);
        let (res115, carry) = split_64(a52 * b63 + a53 * b62 + a54 * b61 + a55 * b60 + a56 * b59 + a57 * b58 + a58 * b57 + a59 * b56 + a60 * b55 + a61 * b54 + a62 * b53 + a63 * b52 + carry);
        let (res116, carry) = split_64(a53 * b63 + a54 * b62 + a55 * b61 + a56 * b60 + a57 * b59 + a58 * b58 + a59 * b57 + a60 * b56 + a61 * b55 + a62 * b54 + a63 * b53 + carry);
        let (res117, carry) = split_64(a54 * b63 + a55 * b62 + a56 * b61 + a57 * b60 + a58 * b59 + a59 * b58 + a60 * b57 + a61 * b56 + a62 * b55 + a63 * b54 + carry);
        let (res118, carry) = split_64(a55 * b63 + a56 * b62 + a57 * b61 + a58 * b60 + a59 * b59 + a60 * b58 + a61 * b57 + a62 * b56 + a63 * b55 + carry);
        let (res119, carry) = split_64(a56 * b63 + a57 * b62 + a58 * b61 + a59 * b60 + a60 * b59 + a61 * b58 + a62 * b57 + a63 * b56 + carry);
        let (res120, carry) = split_64(a57 * b63 + a58 * b62 + a59 * b61 + a60 * b60 + a61 * b59 + a62 * b58 + a63 * b57 + carry);
        let (res121, carry) = split_64(a58 * b63 + a59 * b62 + a60 * b61 + a61 * b60 + a62 * b59 + a63 * b58 + carry);
        let (res122, carry) = split_64(a59 * b63 + a60 * b62 + a61 * b61 + a62 * b60 + a63 * b59 + carry);
        let (res123, carry) = split_64(a60 * b63 + a61 * b62 + a62 * b61 + a63 * b60 + carry);
        let (res124, carry) = split_64(a61 * b63 + a62 * b62 + a63 * b61 + carry);
        let (res125, carry) = split_64(a62 * b63 + a63 * b62 + carry);
        let (res126, carry) = split_64(a63 * b63 + carry);

        // Returning Uint4096 split into `low` and `high`.
        return (
            low=Uint4096(
                d00=res00 + HALF_SHIFT * res01, d01=res02 + HALF_SHIFT * res03, d02=res04 + HALF_SHIFT * res05, d03=res06 + HALF_SHIFT * res07,
                d04=res08 + HALF_SHIFT * res09, d05=res10 + HALF_SHIFT * res11, d06=res12 + HALF_SHIFT * res13, d07=res14 + HALF_SHIFT * res15,
                d08=res16 + HALF_SHIFT * res17, d09=res18 + HALF_SHIFT * res19, d10=res20 + HALF_SHIFT * res21, d11=res22 + HALF_SHIFT * res23,
                d12=res24 + HALF_SHIFT * res25, d13=res26 + HALF_SHIFT * res27, d14=res28 + HALF_SHIFT * res29, d15=res30 + HALF_SHIFT * res31,
                d16=res32 + HALF_SHIFT * res33, d17=res34 + HALF_SHIFT * res35, d18=res36 + HALF_SHIFT * res37, d19=res38 + HALF_SHIFT * res39,
                d20=res40 + HALF_SHIFT * res41, d21=res42 + HALF_SHIFT * res43, d22=res44 + HALF_SHIFT * res45, d23=res46 + HALF_SHIFT * res47,
                d24=res48 + HALF_SHIFT * res49, d25=res50 + HALF_SHIFT * res51, d26=res52 + HALF_SHIFT * res53, d27=res54 + HALF_SHIFT * res55,
                d28=res56 + HALF_SHIFT * res57, d29=res58 + HALF_SHIFT * res59, d30=res60 + HALF_SHIFT * res61, d31=res62 + HALF_SHIFT * res63
            ),
            high=Uint4096(
                d00=res64 + HALF_SHIFT * res65, d01=res66 + HALF_SHIFT * res67, d02=res68 + HALF_SHIFT * res69, d03=res70 + HALF_SHIFT * res71,
                d04=res72 + HALF_SHIFT * res73, d05=res74 + HALF_SHIFT * res75, d06=res76 + HALF_SHIFT * res77, d07=res78 + HALF_SHIFT * res79,
                d08=res80 + HALF_SHIFT * res81, d09=res82 + HALF_SHIFT * res83, d10=res84 + HALF_SHIFT * res85, d11=res86 + HALF_SHIFT * res87,
                d12=res88 + HALF_SHIFT * res89, d13=res90 + HALF_SHIFT * res91, d14=res92 + HALF_SHIFT * res93, d15=res94 + HALF_SHIFT * res95,
                d16=res96 + HALF_SHIFT * res97, d17=res98 + HALF_SHIFT * res99, d18=res100 + HALF_SHIFT * res101, d19=res102 + HALF_SHIFT * res103,
                d20=res104 + HALF_SHIFT * res105, d21=res106 + HALF_SHIFT * res107, d22=res108 + HALF_SHIFT * res109, d23=res110 + HALF_SHIFT * res111,
                d24=res112 + HALF_SHIFT * res113, d25=res114 + HALF_SHIFT * res115, d26=res116 + HALF_SHIFT * res117, d27=res118 + HALF_SHIFT * res119,
                d28=res120 + HALF_SHIFT * res121, d29=res122 + HALF_SHIFT * res123, d30=res124 + HALF_SHIFT * res125, d31=res126 + HALF_SHIFT * carry
            )
        );
    }

    // Return true if both integers are equal.
    func eq{range_check_ptr}(a: Uint4096, b: Uint4096) -> felt {
        if (a.d00 != b.d00) {
            return 0;
        }
        if (a.d01 != b.d01) {
            return 0;
        }
        if (a.d02 != b.d02) {
            return 0;
        }
        if (a.d03 != b.d03) {
            return 0;
        }
        if (a.d04 != b.d04) {
            return 0;
        }
        if (a.d05 != b.d05) {
            return 0;
        }
        if (a.d06 != b.d06) {
            return 0;
        }
        if (a.d07 != b.d07) {
            return 0;
        }
        if (a.d08 != b.d08) {
            return 0;
        }
        if (a.d09 != b.d09) {
            return 0;
        }
        if (a.d10 != b.d10) {
            return 0;
        }
        if (a.d11 != b.d11) {
            return 0;
        }
        if (a.d12 != b.d12) {
            return 0;
        }
        if (a.d13 != b.d13) {
            return 0;
        }
        if (a.d14 != b.d14) {
            return 0;
        }
        if (a.d15 != b.d15) {
            return 0;
        }
        if (a.d16 != b.d16) {
            return 0;
        }
        if (a.d17 != b.d17) {
            return 0;
        }
        if (a.d18 != b.d18) {
            return 0;
        }
        if (a.d19 != b.d19) {
            return 0;
        }
        if (a.d20 != b.d20) {
            return 0;
        }
        if (a.d21 != b.d21) {
            return 0;
        }
        if (a.d22 != b.d22) {
            return 0;
        }
        if (a.d23 != b.d23) {
            return 0;
        }
        if (a.d24 != b.d24) {
            return 0;
        }
        if (a.d25 != b.d25) {
            return 0;
        }
        if (a.d26 != b.d26) {
            return 0;
        }
        if (a.d27 != b.d27) {
            return 0;
        }
        if (a.d28 != b.d28) {
            return 0;
        }
        if (a.d29 != b.d29) {
            return 0;
        }
        if (a.d30 != b.d30) {
            return 0;
        }
        if (a.d31 != b.d31) {
            return 0;
        }
        return 1;
    }

    // Multiplies two integers. Returns the result as two 4096-bit integers: the result has 2*4096 bits,
    // the returned integers represent the lower 4096-bits and the higher 4096-bits, respectively.
    func mul{range_check_ptr}(a: Uint4096, b: Uint4096) -> (low: Uint4096, high: Uint4096) {
        // Splitting Uint4096 fields for `a`
        let (a00, a01) = split_64(a.d00);
        let (a02, a03) = split_64(a.d01);
        let (a04, a05) = split_64(a.d02);
        let (a06, a07) = split_64(a.d03);
        let (a08, a09) = split_64(a.d04);
        let (a10, a11) = split_64(a.d05);
        let (a12, a13) = split_64(a.d06);
        let (a14, a15) = split_64(a.d07);
        let (a16, a17) = split_64(a.d08);
        let (a18, a19) = split_64(a.d09);
        let (a20, a21) = split_64(a.d10);
        let (a22, a23) = split_64(a.d11);
        let (a24, a25) = split_64(a.d12);
        let (a26, a27) = split_64(a.d13);
        let (a28, a29) = split_64(a.d14);
        let (a30, a31) = split_64(a.d15);
        let (a32, a33) = split_64(a.d16);
        let (a34, a35) = split_64(a.d17);
        let (a36, a37) = split_64(a.d18);
        let (a38, a39) = split_64(a.d19);
        let (a40, a41) = split_64(a.d20);
        let (a42, a43) = split_64(a.d21);
        let (a44, a45) = split_64(a.d22);
        let (a46, a47) = split_64(a.d23);
        let (a48, a49) = split_64(a.d24);
        let (a50, a51) = split_64(a.d25);
        let (a52, a53) = split_64(a.d26);
        let (a54, a55) = split_64(a.d27);
        let (a56, a57) = split_64(a.d28);
        let (a58, a59) = split_64(a.d29);
        let (a60, a61) = split_64(a.d30);
        let (a62, a63) = split_64(a.d31);

        // Splitting Uint4096 fields for `b`
        let (b00, b01) = split_64(b.d00);
        let (b02, b03) = split_64(b.d01);
        let (b04, b05) = split_64(b.d02);
        let (b06, b07) = split_64(b.d03);
        let (b08, b09) = split_64(b.d04);
        let (b10, b11) = split_64(b.d05);
        let (b12, b13) = split_64(b.d06);
        let (b14, b15) = split_64(b.d07);
        let (b16, b17) = split_64(b.d08);
        let (b18, b19) = split_64(b.d09);
        let (b20, b21) = split_64(b.d10);
        let (b22, b23) = split_64(b.d11);
        let (b24, b25) = split_64(b.d12);
        let (b26, b27) = split_64(b.d13);
        let (b28, b29) = split_64(b.d14);
        let (b30, b31) = split_64(b.d15);
        let (b32, b33) = split_64(b.d16);
        let (b34, b35) = split_64(b.d17);
        let (b36, b37) = split_64(b.d18);
        let (b38, b39) = split_64(b.d19);
        let (b40, b41) = split_64(b.d20);
        let (b42, b43) = split_64(b.d21);
        let (b44, b45) = split_64(b.d22);
        let (b46, b47) = split_64(b.d23);
        let (b48, b49) = split_64(b.d24);
        let (b50, b51) = split_64(b.d25);
        let (b52, b53) = split_64(b.d26);
        let (b54, b55) = split_64(b.d27);
        let (b56, b57) = split_64(b.d28);
        let (b58, b59) = split_64(b.d29);
        let (b60, b61) = split_64(b.d30);
        let (b62, b63) = split_64(b.d31);

        // Allocate local variables
        alloc_locals;

        // Compute intermediate sums for Karatsuba
        local A0 = a00 + a32;
        local A1 = a01 + a33;
        local A2 = a02 + a34;
        local A3 = a03 + a35;
        local A4 = a04 + a36;
        local A5 = a05 + a37;
        local A6 = a06 + a38;
        local A7 = a07 + a39;
        local A8 = a08 + a40;
        local A9 = a09 + a41;
        local A10 = a10 + a42;
        local A11 = a11 + a43;
        local A12 = a12 + a44;
        local A13 = a13 + a45;
        local A14 = a14 + a46;
        local A15 = a15 + a47;
        local A16 = a16 + a48;
        local A17 = a17 + a49;
        local A18 = a18 + a50;
        local A19 = a19 + a51;
        local A20 = a20 + a52;
        local A21 = a21 + a53;
        local A22 = a22 + a54;
        local A23 = a23 + a55;
        local A24 = a24 + a56;
        local A25 = a25 + a57;
        local A26 = a26 + a58;
        local A27 = a27 + a59;
        local A28 = a28 + a60;
        local A29 = a29 + a61;
        local A30 = a30 + a62;
        local A31 = a31 + a63;

        local B0 = b00 + b32;
        local B1 = b01 + b33;
        local B2 = b02 + b34;
        local B3 = b03 + b35;
        local B4 = b04 + b36;
        local B5 = b05 + b37;
        local B6 = b06 + b38;
        local B7 = b07 + b39;
        local B8 = b08 + b40;
        local B9 = b09 + b41;
        local B10 = b10 + b42;
        local B11 = b11 + b43;
        local B12 = b12 + b44;
        local B13 = b13 + b45;
        local B14 = b14 + b46;
        local B15 = b15 + b47;
        local B16 = b16 + b48;
        local B17 = b17 + b49;
        local B18 = b18 + b50;
        local B19 = b19 + b51;
        local B20 = b20 + b52;
        local B21 = b21 + b53;
        local B22 = b22 + b54;
        local B23 = b23 + b55;
        local B24 = b24 + b56;
        local B25 = b25 + b57;
        local B26 = b26 + b58;
        local B27 = b27 + b59;
        local B28 = b28 + b60;
        local B29 = b29 + b61;
        local B30 = b30 + b62;
        local B31 = b31 + b63;

        // Compute partial products
        local d00 = a.d00 * b.d00;
        local d01 = a.d00 * b.d01 + a.d01 * b.d00;
        local d02 = a.d00 * b.d02 + a.d01 * b.d01 + a.d02 * b.d00;
        local d03 = a.d00 * b.d03 + a.d01 * b.d02 + a.d02 * b.d01 + a.d03 * b.d00;
        local d04 = a.d00 * b.d04 + a.d01 * b.d03 + a.d02 * b.d02 + a.d03 * b.d01 + a.d04 * b.d00;
        local d05 = a.d00 * b.d05 + a.d01 * b.d04 + a.d02 * b.d03 + a.d03 * b.d02 + a.d04 * b.d01 + a.d05 * b.d00;
        local d06 = a.d00 * b.d06 + a.d01 * b.d05 + a.d02 * b.d04 + a.d03 * b.d03 + a.d04 * b.d02 + a.d05 * b.d01 + a.d06 * b.d00;
        local d07 = a.d00 * b.d07 + a.d01 * b.d06 + a.d02 * b.d05 + a.d03 * b.d04 + a.d04 * b.d03 + a.d05 * b.d02 + a.d06 * b.d01 + a.d07 * b.d00;
        local d08 = a.d00 * b.d08 + a.d01 * b.d07 + a.d02 * b.d06 + a.d03 * b.d05 + a.d04 * b.d04 + a.d05 * b.d03 + a.d06 * b.d02 + a.d07 * b.d01 + a.d08 * b.d00;
        local d09 = a.d00 * b.d09 + a.d01 * b.d08 + a.d02 * b.d07 + a.d03 * b.d06 + a.d04 * b.d05 + a.d05 * b.d04 + a.d06 * b.d03 + a.d07 * b.d02 + a.d08 * b.d01 + a.d09 * b.d00;
        local d10 = a.d00 * b.d10 + a.d01 * b.d09 + a.d02 * b.d08 + a.d03 * b.d07 + a.d04 * b.d06 + a.d05 * b.d05 + a.d06 * b.d04 + a.d07 * b.d03 + a.d08 * b.d02 + a.d09 * b.d01 + a.d10 * b.d00;
        local d11 = a.d00 * b.d11 + a.d01 * b.d10 + a.d02 * b.d09 + a.d03 * b.d08 + a.d04 * b.d07 + a.d05 * b.d06 + a.d06 * b.d05 + a.d07 * b.d04 + a.d08 * b.d03 + a.d09 * b.d02 + a.d10 * b.d01 + a.d11 * b.d00;
        local d12 = a.d00 * b.d12 + a.d01 * b.d11 + a.d02 * b.d10 + a.d03 * b.d09 + a.d04 * b.d08 + a.d05 * b.d07 + a.d06 * b.d06 + a.d07 * b.d05 + a.d08 * b.d04 + a.d09 * b.d03 + a.d10 * b.d02 + a.d11 * b.d01 + a.d12 * b.d00;
        local d13 = a.d00 * b.d13 + a.d01 * b.d12 + a.d02 * b.d11 + a.d03 * b.d10 + a.d04 * b.d09 + a.d05 * b.d08 + a.d06 * b.d07 + a.d07 * b.d06 + a.d08 * b.d05 + a.d09 * b.d04 + a.d10 * b.d03 + a.d11 * b.d02 + a.d12 * b.d01 + a.d13 * b.d00;
        local d14 = a.d00 * b.d14 + a.d01 * b.d13 + a.d02 * b.d12 + a.d03 * b.d11 + a.d04 * b.d10 + a.d05 * b.d09 + a.d06 * b.d08 + a.d07 * b.d07 + a.d08 * b.d06 + a.d09 * b.d05 + a.d10 * b.d04 + a.d11 * b.d03 + a.d12 * b.d02 + a.d13 * b.d01 + a.d14 * b.d00;
        local d15 = a.d00 * b.d15 + a.d01 * b.d14 + a.d02 * b.d13 + a.d03 * b.d12 + a.d04 * b.d11 + a.d05 * b.d10 + a.d06 * b.d09 + a.d07 * b.d08 + a.d08 * b.d07 + a.d09 * b.d06 + a.d10 * b.d05 + a.d11 * b.d04 + a.d12 * b.d03 + a.d13 * b.d02 + a.d14 * b.d01 + a.d15 * b.d00;
        local d16 = a.d00 * b.d16 + a.d01 * b.d15 + a.d02 * b.d14 + a.d03 * b.d13 + a.d04 * b.d12 + a.d05 * b.d11 + a.d06 * b.d10 + a.d07 * b.d09 + a.d08 * b.d08 + a.d09 * b.d07 + a.d10 * b.d06 + a.d11 * b.d05 + a.d12 * b.d04 + a.d13 * b.d03 + a.d14 * b.d02 + a.d15 * b.d01 + a.d16 * b.d00;
        local d17 = a.d00 * b.d17 + a.d01 * b.d16 + a.d02 * b.d15 + a.d03 * b.d14 + a.d04 * b.d13 + a.d05 * b.d12 + a.d06 * b.d11 + a.d07 * b.d10 + a.d08 * b.d09 + a.d09 * b.d08 + a.d10 * b.d07 + a.d11 * b.d06 + a.d12 * b.d05 + a.d13 * b.d04 + a.d14 * b.d03 + a.d15 * b.d02 + a.d16 * b.d01 + a.d17 * b.d00;
        local d18 = a.d00 * b.d18 + a.d01 * b.d17 + a.d02 * b.d16 + a.d03 * b.d15 + a.d04 * b.d14 + a.d05 * b.d13 + a.d06 * b.d12 + a.d07 * b.d11 + a.d08 * b.d10 + a.d09 * b.d09 + a.d10 * b.d08 + a.d11 * b.d07 + a.d12 * b.d06 + a.d13 * b.d05 + a.d14 * b.d04 + a.d15 * b.d03 + a.d16 * b.d02 + a.d17 * b.d01 + a.d18 * b.d00;
        local d19 = a.d00 * b.d19 + a.d01 * b.d18 + a.d02 * b.d17 + a.d03 * b.d16 + a.d04 * b.d15 + a.d05 * b.d14 + a.d06 * b.d13 + a.d07 * b.d12 + a.d08 * b.d11 + a.d09 * b.d10 + a.d10 * b.d09 + a.d11 * b.d08 + a.d12 * b.d07 + a.d13 * b.d06 + a.d14 * b.d05 + a.d15 * b.d04 + a.d16 * b.d03 + a.d17 * b.d02 + a.d18 * b.d01 + a.d19 * b.d00;
        local d20 = a.d00 * b.d20 + a.d01 * b.d19 + a.d02 * b.d18 + a.d03 * b.d17 + a.d04 * b.d16 + a.d05 * b.d15 + a.d06 * b.d14 + a.d07 * b.d13 + a.d08 * b.d12 + a.d09 * b.d11 + a.d10 * b.d10 + a.d11 * b.d09 + a.d12 * b.d08 + a.d13 * b.d07 + a.d14 * b.d06 + a.d15 * b.d05 + a.d16 * b.d04 + a.d17 * b.d03 + a.d18 * b.d02 + a.d19 * b.d01 + a.d20 * b.d00;
        local d21 = a.d00 * b.d21 + a.d01 * b.d20 + a.d02 * b.d19 + a.d03 * b.d18 + a.d04 * b.d17 + a.d05 * b.d16 + a.d06 * b.d15 + a.d07 * b.d14 + a.d08 * b.d13 + a.d09 * b.d12 + a.d10 * b.d11 + a.d11 * b.d10 + a.d12 * b.d09 + a.d13 * b.d08 + a.d14 * b.d07 + a.d15 * b.d06 + a.d16 * b.d05 + a.d17 * b.d04 + a.d18 * b.d03 + a.d19 * b.d02 + a.d20 * b.d01 + a.d21 * b.d00;
        local d22 = a.d00 * b.d22 + a.d01 * b.d21 + a.d02 * b.d20 + a.d03 * b.d19 + a.d04 * b.d18 + a.d05 * b.d17 + a.d06 * b.d16 + a.d07 * b.d15 + a.d08 * b.d14 + a.d09 * b.d13 + a.d10 * b.d12 + a.d11 * b.d11 + a.d12 * b.d10 + a.d13 * b.d09 + a.d14 * b.d08 + a.d15 * b.d07 + a.d16 * b.d06 + a.d17 * b.d05 + a.d18 * b.d04 + a.d19 * b.d03 + a.d20 * b.d02 + a.d21 * b.d01 + a.d22 * b.d00;
        local d23 = a.d00 * b.d23 + a.d01 * b.d22 + a.d02 * b.d21 + a.d03 * b.d20 + a.d04 * b.d19 + a.d05 * b.d18 + a.d06 * b.d17 + a.d07 * b.d16 + a.d08 * b.d15 + a.d09 * b.d14 + a.d10 * b.d13 + a.d11 * b.d12 + a.d12 * b.d11 + a.d13 * b.d10 + a.d14 * b.d09 + a.d15 * b.d08 + a.d16 * b.d07 + a.d17 * b.d06 + a.d18 * b.d05 + a.d19 * b.d04 + a.d20 * b.d03 + a.d21 * b.d02 + a.d22 * b.d01 + a.d23 * b.d00;
        local d24 = a.d00 * b.d24 + a.d01 * b.d23 + a.d02 * b.d22 + a.d03 * b.d21 + a.d04 * b.d20 + a.d05 * b.d19 + a.d06 * b.d18 + a.d07 * b.d17 + a.d08 * b.d16 + a.d09 * b.d15 + a.d10 * b.d14 + a.d11 * b.d13 + a.d12 * b.d12 + a.d13 * b.d11 + a.d14 * b.d10 + a.d15 * b.d09 + a.d16 * b.d08 + a.d17 * b.d07 + a.d18 * b.d06 + a.d19 * b.d05 + a.d20 * b.d04 + a.d21 * b.d03 + a.d22 * b.d02 + a.d23 * b.d01 + a.d24 * b.d00;
        local d25 = a.d00 * b.d25 + a.d01 * b.d24 + a.d02 * b.d23 + a.d03 * b.d22 + a.d04 * b.d21 + a.d05 * b.d20 + a.d06 * b.d19 + a.d07 * b.d18 + a.d08 * b.d17 + a.d09 * b.d16 + a.d10 * b.d15 + a.d11 * b.d14 + a.d12 * b.d13 + a.d13 * b.d12 + a.d14 * b.d11 + a.d15 * b.d10 + a.d16 * b.d09 + a.d17 * b.d08 + a.d18 * b.d07 + a.d19 * b.d06 + a.d20 * b.d05 + a.d21 * b.d04 + a.d22 * b.d03 + a.d23 * b.d02 + a.d24 * b.d01 + a.d25 * b.d00;
        local d26 = a.d00 * b.d26 + a.d01 * b.d25 + a.d02 * b.d24 + a.d03 * b.d23 + a.d04 * b.d22 + a.d05 * b.d21 + a.d06 * b.d20 + a.d07 * b.d19 + a.d08 * b.d18 + a.d09 * b.d17 + a.d10 * b.d16 + a.d11 * b.d15 + a.d12 * b.d14 + a.d13 * b.d13 + a.d14 * b.d12 + a.d15 * b.d11 + a.d16 * b.d10 + a.d17 * b.d09 + a.d18 * b.d08 + a.d19 * b.d07 + a.d20 * b.d06 + a.d21 * b.d05 + a.d22 * b.d04 + a.d23 * b.d03 + a.d24 * b.d02 + a.d25 * b.d01 + a.d26 * b.d00;
        local d27 = a.d00 * b.d27 + a.d01 * b.d26 + a.d02 * b.d25 + a.d03 * b.d24 + a.d04 * b.d23 + a.d05 * b.d22 + a.d06 * b.d21 + a.d07 * b.d20 + a.d08 * b.d19 + a.d09 * b.d18 + a.d10 * b.d17 + a.d11 * b.d16 + a.d12 * b.d15 + a.d13 * b.d14 + a.d14 * b.d13 + a.d15 * b.d12 + a.d16 * b.d11 + a.d17 * b.d10 + a.d18 * b.d09 + a.d19 * b.d08 + a.d20 * b.d07 + a.d21 * b.d06 + a.d22 * b.d05 + a.d23 * b.d04 + a.d24 * b.d03 + a.d25 * b.d02 + a.d26 * b.d01 + a.d27 * b.d00;
        local d28 = a.d00 * b.d28 + a.d01 * b.d27 + a.d02 * b.d26 + a.d03 * b.d25 + a.d04 * b.d24 + a.d05 * b.d23 + a.d06 * b.d22 + a.d07 * b.d21 + a.d08 * b.d20 + a.d09 * b.d19 + a.d10 * b.d18 + a.d11 * b.d17 + a.d12 * b.d16 + a.d13 * b.d15 + a.d14 * b.d14 + a.d15 * b.d13 + a.d16 * b.d12 + a.d17 * b.d11 + a.d18 * b.d10 + a.d19 * b.d09 + a.d20 * b.d08 + a.d21 * b.d07 + a.d22 * b.d06 + a.d23 * b.d05 + a.d24 * b.d04 + a.d25 * b.d03 + a.d26 * b.d02 + a.d27 * b.d01 + a.d28 * b.d00;
        local d29 = a.d00 * b.d29 + a.d01 * b.d28 + a.d02 * b.d27 + a.d03 * b.d26 + a.d04 * b.d25 + a.d05 * b.d24 + a.d06 * b.d23 + a.d07 * b.d22 + a.d08 * b.d21 + a.d09 * b.d20 + a.d10 * b.d19 + a.d11 * b.d18 + a.d12 * b.d17 + a.d13 * b.d16 + a.d14 * b.d15 + a.d15 * b.d14 + a.d16 * b.d13 + a.d17 * b.d12 + a.d18 * b.d11 + a.d19 * b.d10 + a.d20 * b.d09 + a.d21 * b.d08 + a.d22 * b.d07 + a.d23 * b.d06 + a.d24 * b.d05 + a.d25 * b.d04 + a.d26 * b.d03 + a.d27 * b.d02 + a.d28 * b.d01 + a.d29 * b.d00;
        local d30 = a.d00 * b.d30 + a.d01 * b.d29 + a.d02 * b.d28 + a.d03 * b.d27 + a.d04 * b.d26 + a.d05 * b.d25 + a.d06 * b.d24 + a.d07 * b.d23 + a.d08 * b.d22 + a.d09 * b.d21 + a.d10 * b.d20 + a.d11 * b.d19 + a.d12 * b.d18 + a.d13 * b.d17 + a.d14 * b.d16 + a.d15 * b.d15 + a.d16 * b.d14 + a.d17 * b.d13 + a.d18 * b.d12 + a.d19 * b.d11 + a.d20 * b.d10 + a.d21 * b.d09 + a.d22 * b.d08 + a.d23 * b.d07 + a.d24 * b.d06 + a.d25 * b.d05 + a.d26 * b.d04 + a.d27 * b.d03 + a.d28 * b.d02 + a.d29 * b.d01 + a.d30 * b.d00;
        local d31 = a.d00 * b.d31 + a.d01 * b.d30 + a.d02 * b.d29 + a.d03 * b.d28 + a.d04 * b.d27 + a.d05 * b.d26 + a.d06 * b.d25 + a.d07 * b.d24 + a.d08 * b.d23 + a.d09 * b.d22 + a.d10 * b.d21 + a.d11 * b.d20 + a.d12 * b.d19 + a.d13 * b.d18 + a.d14 * b.d17 + a.d15 * b.d16 + a.d16 * b.d15 + a.d17 * b.d14 + a.d18 * b.d13 + a.d19 * b.d12 + a.d20 * b.d11 + a.d21 * b.d10 + a.d22 * b.d09 + a.d23 * b.d08 + a.d24 * b.d07 + a.d25 * b.d06 + a.d26 * b.d05 + a.d27 * b.d04 + a.d28 * b.d03 + a.d29 * b.d02 + a.d30 * b.d01 + a.d31 * b.d00;
        local d32 = a.d01 * b.d31 + a.d02 * b.d30 + a.d03 * b.d29 + a.d04 * b.d28 + a.d05 * b.d27 + a.d06 * b.d26 + a.d07 * b.d25 + a.d08 * b.d24 + a.d09 * b.d23 + a.d10 * b.d22 + a.d11 * b.d21 + a.d12 * b.d20 + a.d13 * b.d19 + a.d14 * b.d18 + a.d15 * b.d17 + a.d16 * b.d16 + a.d17 * b.d15 + a.d18 * b.d14 + a.d19 * b.d13 + a.d20 * b.d12 + a.d21 * b.d11 + a.d22 * b.d10 + a.d23 * b.d09 + a.d24 * b.d08 + a.d25 * b.d07 + a.d26 * b.d06 + a.d27 * b.d05 + a.d28 * b.d04 + a.d29 * b.d03 + a.d30 * b.d02 + a.d31 * b.d01;
        local d33 = a.d02 * b.d31 + a.d03 * b.d30 + a.d04 * b.d29 + a.d05 * b.d28 + a.d06 * b.d27 + a.d07 * b.d26 + a.d08 * b.d25 + a.d09 * b.d24 + a.d10 * b.d23 + a.d11 * b.d22 + a.d12 * b.d21 + a.d13 * b.d20 + a.d14 * b.d19 + a.d15 * b.d18 + a.d16 * b.d17 + a.d17 * b.d16 + a.d18 * b.d15 + a.d19 * b.d14 + a.d20 * b.d13 + a.d21 * b.d12 + a.d22 * b.d11 + a.d23 * b.d10 + a.d24 * b.d09 + a.d25 * b.d08 + a.d26 * b.d07 + a.d27 * b.d06 + a.d28 * b.d05 + a.d29 * b.d04 + a.d30 * b.d03 + a.d31 * b.d02;
        local d34 = a.d03 * b.d31 + a.d04 * b.d30 + a.d05 * b.d29 + a.d06 * b.d28 + a.d07 * b.d27 + a.d08 * b.d26 + a.d09 * b.d25 + a.d10 * b.d24 + a.d11 * b.d23 + a.d12 * b.d22 + a.d13 * b.d21 + a.d14 * b.d20 + a.d15 * b.d19 + a.d16 * b.d18 + a.d17 * b.d17 + a.d18 * b.d16 + a.d19 * b.d15 + a.d20 * b.d14 + a.d21 * b.d13 + a.d22 * b.d12 + a.d23 * b.d11 + a.d24 * b.d10 + a.d25 * b.d09 + a.d26 * b.d08 + a.d27 * b.d07 + a.d28 * b.d06 + a.d29 * b.d05 + a.d30 * b.d04 + a.d31 * b.d03;
        local d35 = a.d04 * b.d31 + a.d05 * b.d30 + a.d06 * b.d29 + a.d07 * b.d28 + a.d08 * b.d27 + a.d09 * b.d26 + a.d10 * b.d25 + a.d11 * b.d24 + a.d12 * b.d23 + a.d13 * b.d22 + a.d14 * b.d21 + a.d15 * b.d20 + a.d16 * b.d19 + a.d17 * b.d18 + a.d18 * b.d17 + a.d19 * b.d16 + a.d20 * b.d15 + a.d21 * b.d14 + a.d22 * b.d13 + a.d23 * b.d12 + a.d24 * b.d11 + a.d25 * b.d10 + a.d26 * b.d09 + a.d27 * b.d08 + a.d28 * b.d07 + a.d29 * b.d06 + a.d30 * b.d05 + a.d31 * b.d04;
        local d36 = a.d05 * b.d31 + a.d06 * b.d30 + a.d07 * b.d29 + a.d08 * b.d28 + a.d09 * b.d27 + a.d10 * b.d26 + a.d11 * b.d25 + a.d12 * b.d24 + a.d13 * b.d23 + a.d14 * b.d22 + a.d15 * b.d21 + a.d16 * b.d20 + a.d17 * b.d19 + a.d18 * b.d18 + a.d19 * b.d17 + a.d20 * b.d16 + a.d21 * b.d15 + a.d22 * b.d14 + a.d23 * b.d13 + a.d24 * b.d12 + a.d25 * b.d11 + a.d26 * b.d10 + a.d27 * b.d09 + a.d28 * b.d08 + a.d29 * b.d07 + a.d30 * b.d06 + a.d31 * b.d05;
        local d37 = a.d06 * b.d31 + a.d07 * b.d30 + a.d08 * b.d29 + a.d09 * b.d28 + a.d10 * b.d27 + a.d11 * b.d26 + a.d12 * b.d25 + a.d13 * b.d24 + a.d14 * b.d23 + a.d15 * b.d22 + a.d16 * b.d21 + a.d17 * b.d20 + a.d18 * b.d19 + a.d19 * b.d18 + a.d20 * b.d17 + a.d21 * b.d16 + a.d22 * b.d15 + a.d23 * b.d14 + a.d24 * b.d13 + a.d25 * b.d12 + a.d26 * b.d11 + a.d27 * b.d10 + a.d28 * b.d09 + a.d29 * b.d08 + a.d30 * b.d07 + a.d31 * b.d06;
        local d38 = a.d07 * b.d31 + a.d08 * b.d30 + a.d09 * b.d29 + a.d10 * b.d28 + a.d11 * b.d27 + a.d12 * b.d26 + a.d13 * b.d25 + a.d14 * b.d24 + a.d15 * b.d23 + a.d16 * b.d22 + a.d17 * b.d21 + a.d18 * b.d20 + a.d19 * b.d19 + a.d20 * b.d18 + a.d21 * b.d17 + a.d22 * b.d16 + a.d23 * b.d15 + a.d24 * b.d14 + a.d25 * b.d13 + a.d26 * b.d12 + a.d27 * b.d11 + a.d28 * b.d10 + a.d29 * b.d09 + a.d30 * b.d08 + a.d31 * b.d07;
        local d39 = a.d08 * b.d31 + a.d09 * b.d30 + a.d10 * b.d29 + a.d11 * b.d28 + a.d12 * b.d27 + a.d13 * b.d26 + a.d14 * b.d25 + a.d15 * b.d24 + a.d16 * b.d23 + a.d17 * b.d22 + a.d18 * b.d21 + a.d19 * b.d20 + a.d20 * b.d19 + a.d21 * b.d18 + a.d22 * b.d17 + a.d23 * b.d16 + a.d24 * b.d15 + a.d25 * b.d14 + a.d26 * b.d13 + a.d27 * b.d12 + a.d28 * b.d11 + a.d29 * b.d10 + a.d30 * b.d09 + a.d31 * b.d08;
        local d40 = a.d09 * b.d31 + a.d10 * b.d30 + a.d11 * b.d29 + a.d12 * b.d28 + a.d13 * b.d27 + a.d14 * b.d26 + a.d15 * b.d25 + a.d16 * b.d24 + a.d17 * b.d23 + a.d18 * b.d22 + a.d19 * b.d21 + a.d20 * b.d20 + a.d21 * b.d19 + a.d22 * b.d18 + a.d23 * b.d17 + a.d24 * b.d16 + a.d25 * b.d15 + a.d26 * b.d14 + a.d27 * b.d13 + a.d28 * b.d12 + a.d29 * b.d11 + a.d30 * b.d10 + a.d31 * b.d09;
        local d41 = a.d10 * b.d31 + a.d11 * b.d30 + a.d12 * b.d29 + a.d13 * b.d28 + a.d14 * b.d27 + a.d15 * b.d26 + a.d16 * b.d25 + a.d17 * b.d24 + a.d18 * b.d23 + a.d19 * b.d22 + a.d20 * b.d21 + a.d21 * b.d20 + a.d22 * b.d19 + a.d23 * b.d18 + a.d24 * b.d17 + a.d25 * b.d16 + a.d26 * b.d15 + a.d27 * b.d14 + a.d28 * b.d13 + a.d29 * b.d12 + a.d30 * b.d11 + a.d31 * b.d10;
        local d42 = a.d11 * b.d31 + a.d12 * b.d30 + a.d13 * b.d29 + a.d14 * b.d28 + a.d15 * b.d27 + a.d16 * b.d26 + a.d17 * b.d25 + a.d18 * b.d24 + a.d19 * b.d23 + a.d20 * b.d22 + a.d21 * b.d21 + a.d22 * b.d20 + a.d23 * b.d19 + a.d24 * b.d18 + a.d25 * b.d17 + a.d26 * b.d16 + a.d27 * b.d15 + a.d28 * b.d14 + a.d29 * b.d13 + a.d30 * b.d12 + a.d31 * b.d11;
        local d43 = a.d12 * b.d31 + a.d13 * b.d30 + a.d14 * b.d29 + a.d15 * b.d28 + a.d16 * b.d27 + a.d17 * b.d26 + a.d18 * b.d25 + a.d19 * b.d24 + a.d20 * b.d23 + a.d21 * b.d22 + a.d22 * b.d21 + a.d23 * b.d20 + a.d24 * b.d19 + a.d25 * b.d18 + a.d26 * b.d17 + a.d27 * b.d16 + a.d28 * b.d15 + a.d29 * b.d14 + a.d30 * b.d13 + a.d31 * b.d12;
        local d44 = a.d13 * b.d31 + a.d14 * b.d30 + a.d15 * b.d29 + a.d16 * b.d28 + a.d17 * b.d27 + a.d18 * b.d26 + a.d19 * b.d25 + a.d20 * b.d24 + a.d21 * b.d23 + a.d22 * b.d22 + a.d23 * b.d21 + a.d24 * b.d20 + a.d25 * b.d19 + a.d26 * b.d18 + a.d27 * b.d17 + a.d28 * b.d16 + a.d29 * b.d15 + a.d30 * b.d14 + a.d31 * b.d13;
        local d45 = a.d14 * b.d31 + a.d15 * b.d30 + a.d16 * b.d29 + a.d17 * b.d28 + a.d18 * b.d27 + a.d19 * b.d26 + a.d20 * b.d25 + a.d21 * b.d24 + a.d22 * b.d23 + a.d23 * b.d22 + a.d24 * b.d21 + a.d25 * b.d20 + a.d26 * b.d19 + a.d27 * b.d18 + a.d28 * b.d17 + a.d29 * b.d16 + a.d30 * b.d15 + a.d31 * b.d14;
        local d46 = a.d15 * b.d31 + a.d16 * b.d30 + a.d17 * b.d29 + a.d18 * b.d28 + a.d19 * b.d27 + a.d20 * b.d26 + a.d21 * b.d25 + a.d22 * b.d24 + a.d23 * b.d23 + a.d24 * b.d22 + a.d25 * b.d21 + a.d26 * b.d20 + a.d27 * b.d19 + a.d28 * b.d18 + a.d29 * b.d17 + a.d30 * b.d16 + a.d31 * b.d15;
        local d47 = a.d16 * b.d31 + a.d17 * b.d30 + a.d18 * b.d29 + a.d19 * b.d28 + a.d20 * b.d27 + a.d21 * b.d26 + a.d22 * b.d25 + a.d23 * b.d24 + a.d24 * b.d23 + a.d25 * b.d22 + a.d26 * b.d21 + a.d27 * b.d20 + a.d28 * b.d19 + a.d29 * b.d18 + a.d30 * b.d17 + a.d31 * b.d16;
        local d48 = a.d17 * b.d31 + a.d18 * b.d30 + a.d19 * b.d29 + a.d20 * b.d28 + a.d21 * b.d27 + a.d22 * b.d26 + a.d23 * b.d25 + a.d24 * b.d24 + a.d25 * b.d23 + a.d26 * b.d22 + a.d27 * b.d21 + a.d28 * b.d20 + a.d29 * b.d19 + a.d30 * b.d18 + a.d31 * b.d17;
        local d49 = a.d18 * b.d31 + a.d19 * b.d30 + a.d20 * b.d29 + a.d21 * b.d28 + a.d22 * b.d27 + a.d23 * b.d26 + a.d24 * b.d25 + a.d25 * b.d24 + a.d26 * b.d23 + a.d27 * b.d22 + a.d28 * b.d21 + a.d29 * b.d20 + a.d30 * b.d19 + a.d31 * b.d18;
        local d50 = a.d19 * b.d31 + a.d20 * b.d30 + a.d21 * b.d29 + a.d22 * b.d28 + a.d23 * b.d27 + a.d24 * b.d26 + a.d25 * b.d25 + a.d26 * b.d24 + a.d27 * b.d23 + a.d28 * b.d22 + a.d29 * b.d21 + a.d30 * b.d20 + a.d31 * b.d19;
        local d51 = a.d20 * b.d31 + a.d21 * b.d30 + a.d22 * b.d29 + a.d23 * b.d28 + a.d24 * b.d27 + a.d25 * b.d26 + a.d26 * b.d25 + a.d27 * b.d24 + a.d28 * b.d23 + a.d29 * b.d22 + a.d30 * b.d21 + a.d31 * b.d20;
        local d52 = a.d21 * b.d31 + a.d22 * b.d30 + a.d23 * b.d29 + a.d24 * b.d28 + a.d25 * b.d27 + a.d26 * b.d26 + a.d27 * b.d25 + a.d28 * b.d24 + a.d29 * b.d23 + a.d30 * b.d22 + a.d31 * b.d21;
        local d53 = a.d22 * b.d31 + a.d23 * b.d30 + a.d24 * b.d29 + a.d25 * b.d28 + a.d26 * b.d27 + a.d27 * b.d26 + a.d28 * b.d25 + a.d29 * b.d24 + a.d30 * b.d23 + a.d31 * b.d22;
        local d54 = a.d23 * b.d31 + a.d24 * b.d30 + a.d25 * b.d29 + a.d26 * b.d28 + a.d27 * b.d27 + a.d28 * b.d26 + a.d29 * b.d25 + a.d30 * b.d24 + a.d31 * b.d23;
        local d55 = a.d24 * b.d31 + a.d25 * b.d30 + a.d26 * b.d29 + a.d27 * b.d28 + a.d28 * b.d27 + a.d29 * b.d26 + a.d30 * b.d25 + a.d31 * b.d24;
        local d56 = a.d25 * b.d31 + a.d26 * b.d30 + a.d27 * b.d29 + a.d28 * b.d28 + a.d29 * b.d27 + a.d30 * b.d26 + a.d31 * b.d25;
        local d57 = a.d26 * b.d31 + a.d27 * b.d30 + a.d28 * b.d29 + a.d29 * b.d28 + a.d30 * b.d27 + a.d31 * b.d26;
        local d58 = a.d27 * b.d31 + a.d28 * b.d30 + a.d29 * b.d29 + a.d30 * b.d28 + a.d31 * b.d27;
        local d59 = a.d28 * b.d31 + a.d29 * b.d30 + a.d30 * b.d29 + a.d31 * b.d28;
        local d60 = a.d29 * b.d31 + a.d30 * b.d30 + a.d31 * b.d29;
        local d61 = a.d30 * b.d31 + a.d31 * b.d30;
        local d62 = a.d31 * b.d31;
    }
}