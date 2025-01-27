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
