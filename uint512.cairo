from uint256 import uint256_add
from starkware.cairo.common.uint256 import Uint256, uint256_mul

struct Uint512 {
    low: Uint256,
    high: Uint256,
}

func uint512_add{range_check_ptr}(a: Uint512, b: Uint512, c_in: felt) -> (c: Uint512, c_out: felt) {
    let (ll, c) = uint256_add(a.low, b.low, c_in);
    let (hh, c_out) = uint256_add(a.high, b.high, c);
    return (c=Uint512(low=ll, high=hh), c_out=c_out);
}

func uint512_mul{range_check_ptr}(a: Uint512, b: Uint512) -> (c: Uint512, d: Uint512) {
    // Step 1: Multiply low and high parts
    let (z0_l, z0_h) = uint256_mul(a.low, b.low);
    let (z2_l, z2_h) = uint256_mul(a.high, b.high);

    // Step 2: Add the high and low parts of a and b
    let (X, _) = uint256_add(a.high, a.low, 0);
    let (Y, _) = uint256_add(b.high, b.low, 0);

    // Step 3: Multiply the sums
    let (z1_l, z1_h) = uint256_mul(X, Y);

    // Step 4: Compute the cross terms
    let (L, carry) = uint256_add(z1_l, z0_h, 0);
    let (H, carry) = uint256_add(z1_h, z2_l, carry);

    let (z2_h, _) = uint256_add(z1_h, 0, carry);

    return (c=Uint512(low=z0_l, high=L), d=Uint512(low=H, high=z2_h));
}
