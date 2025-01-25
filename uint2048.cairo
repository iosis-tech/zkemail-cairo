from uint1024 import Uint1024, uint1024_add, uint1024_mul

struct Uint2048 {
    low: Uint1024,
    high: Uint1024,
}

func uint2048_add{range_check_ptr}(a: Uint2048, b: Uint2048, c_in: felt) -> (c: Uint2048, c_out: felt) {
    let (ll, c) = uint1024_add(a.low, b.low, c_in);
    let (hh, c_out) = uint1024_add(a.high, b.high, c);
    return (c=Uint2048(low=ll, high=hh), c_out=c_out);
}

func uint2048_mul{range_check_ptr}(a: Uint2048, b: Uint2048) -> (c: Uint2048, d: Uint2048) {
    // Step 1: Multiply low and high parts
    let (z0_l, z0_h) = uint1024_mul(a.low, b.low);
    let (z2_l, z2_h) = uint1024_mul(a.high, b.high);

    // Step 2: Add the high and low parts of a and b
    let (X, _) = uint1024_add(a.high, a.low, 0);
    let (Y, _) = uint1024_add(b.high, b.low, 0);

    // Step 3: Multiply the sums
    let (z1_l, z1_h) = uint1024_mul(X, Y);

    // Step 4: Compute the cross terms
    let (L, _) = uint1024_add(z1_l, z0_h, 0);
    let (H, _) = uint1024_add(z1_h, z2_l, 0);

    return (c=Uint2048(low=z0_l, high=L), d=Uint2048(low=H, high=z2_h));
}