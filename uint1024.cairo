from uint512 import Uint512, uint512_add, uint512_mul

struct Uint1024 {
    low: Uint512,
    high: Uint512,
}

func uint1024_add{range_check_ptr}(a: Uint1024, b: Uint1024, c_in: felt) -> (c: Uint1024, c_out: felt) {
    let (ll, c) = uint512_add(a.low, b.low, c_in);
    let (hh, c_out) = uint512_add(a.high, b.high, c);
    return (c=Uint1024(low=ll, high=hh), c_out=c_out);
}

func uint1024_mul{range_check_ptr}(a: Uint1024, b: Uint1024) -> (c: Uint1024, d: Uint1024) {
    // Step 1: Multiply low and high parts
    let (z0_l, z0_h) = uint512_mul(a.low, b.low);
    let (z2_l, z2_h) = uint512_mul(a.high, b.high);

    // Step 2: Add the high and low parts of a and b
    let (X, _) = uint512_add(a.high, a.low, 0);
    let (Y, _) = uint512_add(b.high, b.low, 0);

    // Step 3: Multiply the sums
    let (z1_l, z1_h) = uint512_mul(X, Y);

    // Step 4: Compute the cross terms
    let (L, _) = uint512_add(z1_l, z0_h, 0);
    let (H, _) = uint512_add(z1_h, z2_l, 0);

    return (c=Uint1024(low=z0_l, high=L), d=Uint1024(low=H, high=z2_h));
}