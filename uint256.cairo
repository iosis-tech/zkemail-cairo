from starkware.cairo.common.uint256 import Uint256, uint256_check

const SHIFT = 2 ** 128;

func uint256_add{range_check_ptr}(a: Uint256, b: Uint256, c_in: felt) -> (c: Uint256, c_out: felt) {
    alloc_locals;
    local res: Uint256;
    local carry_low: felt;
    local carry_high: felt;

    %{
        sum_low = ids.a.low + ids.b.low + ids.c_in
        ids.carry_low = 1 if sum_low >= ids.SHIFT else 0
        sum_high = ids.a.high + ids.b.high + ids.carry_low
        ids.carry_high = 1 if sum_high >= ids.SHIFT else 0
    %}

    assert carry_low * carry_low = carry_low;
    assert carry_high * carry_high = carry_high;

    assert res.low = a.low + b.low + c_in - carry_low * SHIFT;
    assert res.high = a.high + b.high + carry_low - carry_high * SHIFT;
    uint256_check(res);

    return (c=res, c_out=carry_high);
}

func uint256_eq{range_check_ptr}(a: Uint256, b: Uint256) -> felt {
    if (a.high != b.high) {
        return 0;
    }
    if (a.low != b.low) {
        return 0;
    }
    return 1;
}

func uint256_from_u8_be(ch: felt*) -> (res: Uint256) {
    return (
        res=Uint256(
            low=ch[16 + 0] * 0x1000000000000000000000000000000 + ch[16 + 1] *
            0x10000000000000000000000000000 + ch[16 + 2] * 0x100000000000000000000000000 + ch[
                16 + 3
            ] * 0x1000000000000000000000000 + ch[16 + 4] * 0x10000000000000000000000 + ch[16 + 5] *
            0x100000000000000000000 + ch[16 + 6] * 0x1000000000000000000 + ch[16 + 7] *
            0x10000000000000000 + ch[16 + 8] * 0x100000000000000 + ch[16 + 9] * 0x1000000000000 +
            ch[16 + 10] * 0x10000000000 + ch[16 + 11] * 0x100000000 + ch[16 + 12] * 0x1000000 + ch[
                16 + 13
            ] * 0x10000 + ch[16 + 14] * 0x100 + ch[16 + 15] * 0x1,
            high=ch[0] * 0x1000000000000000000000000000000 + ch[1] *
            0x10000000000000000000000000000 + ch[2] * 0x100000000000000000000000000 + ch[3] *
            0x1000000000000000000000000 + ch[4] * 0x10000000000000000000000 + ch[5] *
            0x100000000000000000000 + ch[6] * 0x1000000000000000000 + ch[7] * 0x10000000000000000 +
            ch[8] * 0x100000000000000 + ch[9] * 0x1000000000000 + ch[10] * 0x10000000000 + ch[11] *
            0x100000000 + ch[12] * 0x1000000 + ch[13] * 0x10000 + ch[14] * 0x100 + ch[15] * 0x1,
        ),
    );
}

func uint256_from_u32_be(ch: felt*) -> (res: Uint256) {
    return (
        res=Uint256(
            low=ch[4] * 0x1000000000000000000000000 + ch[5] * 0x10000000000000000 + ch[6] *
            0x100000000 + ch[7] * 0x1,
            high=ch[0] * 0x1000000000000000000000000 + ch[1] * 0x10000000000000000 + ch[2] *
            0x100000000 + ch[3] * 0x1,
        ),
    );
}
