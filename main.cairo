%builtins range_check

from starkware.cairo.common.uint256 import Uint256
from uint512 import Uint512
from uint1024 import Uint1024
from uint2048 import Uint2048, uint2048_add, uint2048_mul

func main{range_check_ptr}() {
    
    let a = Uint2048(low=Uint1024(low=Uint512(low=Uint256(low=0xfffffffffffffffffffffff, high=0), high=Uint256(low=0, high=0)), high=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0))), high=Uint1024(low=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0)), high=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0))));
    let b = Uint2048(low=Uint1024(low=Uint512(low=Uint256(low=0xfffffffffffffffffffffff, high=0), high=Uint256(low=0, high=0)), high=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0))), high=Uint1024(low=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0)), high=Uint512(low=Uint256(low=0, high=0), high=Uint256(low=0, high=0))));
    let (res, carry) = uint2048_mul(a, b);
    %{ print(ids.res.low.low.low.high) %}

    return ();
}