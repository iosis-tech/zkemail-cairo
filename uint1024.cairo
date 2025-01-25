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

func uint1024_mul{range_check_ptr}(a: Uint1024, b: Uint1024) -> (c: Uint1024, d: Uint1024) {
    alloc_locals;
    
    // Step 1: Multiply low and high parts
    let (z0_l, z0_h) = uint512_mul(a.low, b.low);
    let (z2_l, z2_h) = uint512_mul(a.high, b.high);

    // Step 2: Add the high and low parts of a and b
    let (X, local carry_X) = uint512_add(a.high, a.low, 0);
    let (Y, local carry_Y) = uint512_add(b.high, b.low, 0);

    let (res) = uint512_zero();

    // Step 3: Multiply the sums
    let (z1_l, z1_h) = uint512_mul(X, Y);

    if (carry_X == 1) {
        let (z1_h_new, carry_z1_h) = uint512_add(z1_h, X, 0);
        let (z2_h_new, _) = uint512_add(z2_h, res, carry_z1_h);

        // Step 4: Compute the cross terms
        let (L, carry_L) = uint512_add(z1_l, z0_h, 0);
        let (H, carry_H) = uint512_add(z1_h_new, z2_l, carry_L);

        let (z2_h_new, _) = uint512_add(z2_h_new, res, carry_H);

        return (c=Uint1024(low=z0_l, high=L), d=Uint1024(low=H, high=z2_h_new));
    }

    if (carry_Y == 1) {
        let (z1_h_new, carry_z1_h) = uint512_add(z1_h, Y, 0);
        let (z2_h_new, _) = uint512_add(z2_h, res, carry_z1_h);

        // Step 4: Compute the cross terms
        let (L, carry_L) = uint512_add(z1_l, z0_h, 0);
        let (H, carry_H) = uint512_add(z1_h_new, z2_l, carry_L);

        let (z2_h_new, _) = uint512_add(z2_h_new, res, carry_H);

        return (c=Uint1024(low=z0_l, high=L), d=Uint1024(low=H, high=z2_h_new));
    }

    // Step 4: Compute the cross terms
    let (L, carry_L) = uint512_add(z1_l, z0_h, 0);
    let (H, carry_H) = uint512_add(z1_h, z2_l, carry_L);

    let (z2_h, _) = uint512_add(z2_h, res, carry_H);

    return (c=Uint1024(low=z0_l, high=L), d=Uint1024(low=H, high=z2_h));
}