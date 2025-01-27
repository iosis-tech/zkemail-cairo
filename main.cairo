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

        A = 53510340975471864078781935802302558486143677880838586945078569027
        N = 21127004321403151904174483573478613447353094177476856020974547413959042592929957931673186877543014472955633375722185120687093320748330876291988492328355360748819376274886191540997267467395818087343603610658467382135498585844746286354153280020278230193919481759715976771237026348814583860852891277287143685823079541064893519640910742794617104330313146710973705006867320406530936542401839508793704963123495657642104399887779814591494942464476267964398014081859509457155904799655461713345239771938453663711191245547994064288917976349971939874452758456656899286333018422830162235798733617698048144426966482806344383332911
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
