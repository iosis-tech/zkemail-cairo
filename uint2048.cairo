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

func uint2048_mul{range_check_ptr}(a: Uint2048, b: Uint2048) -> (c: Uint2048, d: Uint2048) {
    alloc_locals;
    
    // Step 1: Multiply low and high parts
    let (z0_l, z0_h) = uint1024_mul(a.low, b.low);
    let (z2_l, z2_h) = uint1024_mul(a.high, b.high);

    // Step 2: Add the high and low parts of a and b
    let (X, local carry_X) = uint1024_add(a.high, a.low, 0);
    let (Y, local carry_Y) = uint1024_add(b.high, b.low, 0);

    let (res) = uint1024_zero();

    // Step 3: Multiply the sums
    let (z1_l, z1_h) = uint1024_mul(X, Y);

    if (carry_X == 1) {
        let (z1_h_new, carry_z1_h) = uint1024_add(z1_h, X, 0);
        let (z2_h_new, _) = uint1024_add(z2_h, res, carry_z1_h);

        // Step 4: Compute the cross terms
        let (L, carry_L) = uint1024_add(z1_l, z0_h, 0);
        let (H, carry_H) = uint1024_add(z1_h_new, z2_l, carry_L);

        let (z2_h_new, _) = uint1024_add(z2_h_new, res, carry_H);

        return (c=Uint2048(low=z0_l, high=L), d=Uint2048(low=H, high=z2_h_new));
    }

    if (carry_Y == 1) {
        let (z1_h_new, carry_z1_h) = uint1024_add(z1_h, Y, 0);
        let (z2_h_new, _) = uint1024_add(z2_h, res, carry_z1_h);

        // Step 4: Compute the cross terms
        let (L, carry_L) = uint1024_add(z1_l, z0_h, 0);
        let (H, carry_H) = uint1024_add(z1_h_new, z2_l, carry_L);

        let (z2_h_new, _) = uint1024_add(z2_h_new, res, carry_H);

        return (c=Uint2048(low=z0_l, high=L), d=Uint2048(low=H, high=z2_h_new));
    }

    // Step 4: Compute the cross terms
    let (L, carry_L) = uint1024_add(z1_l, z0_h, 0);
    let (H, carry_H) = uint1024_add(z1_h, z2_l, carry_L);

    let (z2_h, _) = uint1024_add(z2_h, res, carry_H);

    return (c=Uint2048(low=z0_l, high=L), d=Uint2048(low=H, high=z2_h));
}