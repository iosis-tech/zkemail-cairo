%builtins range_check

from starkware.cairo.common.uint256 import Uint256
from uint512 import Uint512
from uint1024 import Uint1024
from uint2048 import Uint2048, uint2048_add, uint2048_mul, uint2048_eq

func main{range_check_ptr}() {
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

    %}
    
    local a: Uint2048;
    %{ set_u2048(ids.a, 10) %}
    local b: Uint2048;
    %{ set_u2048(ids.b, 2) %}

    return ();
}