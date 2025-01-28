%builtins range_check bitwise

from starkware.cairo.common.uint256 import Uint256
from uint512 import Uint512
from uint1024 import Uint1024
from uint2048 import (
    Uint2048,
    uint2048_add,
    uint2048_mul,
    uint2048_eq,
    uint2048_mul_div_mod,
    uint2048_add_div_mod,
    uint2048_pow_mod_recursive,
)
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

func main{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;
    %{
        def get_u512(v):
            return (v.high.high << 128*3) + (v.high.low << 128*2) + (v.low.high << 128*1) + (v.low.low << 128*0)

        def set_u512(v, value):
            v.low.low = (value >> 128*0) & ((1 << 128) - 1)
            v.low.high = (value >> 128*1) & ((1 << 128) - 1)
            v.high.low = (value >> 128*2) & ((1 << 128) - 1)
            v.high.high = (value >> 128*3) & ((1 << 128) - 1)

        def get_u1024(v):
            return (get_u512(v.high) << 512*1) + (get_u512(v.low) << 512*0)

        def set_u1024(v, value):
            set_u512(v.low, value >> 512*0)
            set_u512(v.high, value >> 512*1)

        def get_u2048(v):
            return (get_u1024(v.high) << 1024*1) + (get_u1024(v.low) << 1024*0)

        def set_u2048(v, value):
            set_u1024(v.low, value >> 1024*0)
            set_u1024(v.high, value >> 1024*1)

        A = 84672234939279020024841303153204474968810663921948959841342463954491385286682976989473715824330808812302118141619399389796350577757623952853295771724923759991954067521654791673695723870339307588834050107404265779157084083608961852636542424103178749028222572305702080054944680907976318825715960367058255917609
        N = 109840904909940404959744221876858620709969218326506407082221779394032326489812790786649034812718574099046117725854400828455845069780702401414898758049907995661494814186559221483509803472525659208951140463116595200877740816407104014421586827141402457631883375757223612729692148186236929622346251839432830432649
    %}

    local a: Uint2048;
    %{ set_u2048(ids.a, A) %}
    local n: Uint2048;
    %{ set_u2048(ids.n, N) %}

    let (c) = uint2048_pow_mod_recursive(a, 65537, n);

    %{ print(get_u2048(ids.c)) %}
    %{ print(pow(A, 65537, N)) %}

    return ();
}
