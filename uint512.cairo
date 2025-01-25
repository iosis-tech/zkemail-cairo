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

func uint512_mul{range_check_ptr}(a: Uint512, b: Uint512) -> (c: Uint512, d: Uint512) {
    alloc_locals;
    
    // Step 1: Multiply low and high parts
    let (z0_l, z0_h) = uint256_mul(a.low, b.low);
    let (z2_l, z2_h) = uint256_mul(a.high, b.high);

    // Step 2: Add the high and low parts of a and b
    let (X, local carry_X) = uint256_add(a.high, a.low, 0);
    let (Y, local carry_Y) = uint256_add(b.high, b.low, 0);

    let res: Uint256 = Uint256(low=0, high=0);

    // Step 3: Multiply the sums
    let (z1_l, z1_h) = uint256_mul(X, Y);

    if (carry_X == 1) {
        let (z1_h_new, carry_z1_h) = uint256_add(z1_h, X, 0);
        let (z2_h_new, _) = uint256_add(z2_h, res, carry_z1_h);

        // Step 4: Compute the cross terms
        let (L, carry_L) = uint256_add(z1_l, z0_h, 0);
        let (H, carry_H) = uint256_add(z1_h_new, z2_l, carry_L);

        let (z2_h_new, _) = uint256_add(z2_h_new, res, carry_H);

        return (c=Uint512(low=z0_l, high=L), d=Uint512(low=H, high=z2_h_new));
    }

    if (carry_Y == 1) {
        let (z1_h_new, carry_z1_h) = uint256_add(z1_h, Y, 0);
        let (z2_h_new, _) = uint256_add(z2_h, res, carry_z1_h);

        // Step 4: Compute the cross terms
        let (L, carry_L) = uint256_add(z1_l, z0_h, 0);
        let (H, carry_H) = uint256_add(z1_h_new, z2_l, carry_L);

        let (z2_h_new, _) = uint256_add(z2_h_new, res, carry_H);

        return (c=Uint512(low=z0_l, high=L), d=Uint512(low=H, high=z2_h_new));
    }

    // Step 4: Compute the cross terms
    let (L, carry_L) = uint256_add(z1_l, z0_h, 0);
    let (H, carry_H) = uint256_add(z1_h, z2_l, carry_L);

    let (z2_h, _) = uint256_add(z2_h, res, carry_H);

    return (c=Uint512(low=z0_l, high=L), d=Uint512(low=H, high=z2_h));
}
