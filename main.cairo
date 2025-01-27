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

        A = 908320182309821
        N = 27714405026401818324467619772854804109701646080324375369576659638501095973696572820384174032518797205822046128827034796522570143485924366491404495063640097302504839113356236065232633001903424754626690175402805922997761625395510649620618644383245741314658503511332977585693871421667807219482246379850396146609933173506508335962829140057322895675442360471117870884727703603581747384212036369566232400183879057131880248490875186644337427224010363373040152168980628444849068158399502103725454517781475555757846638904728163080666181323773190735750187560068214908428581802092383530937838293970179628682710915853221091019443
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
