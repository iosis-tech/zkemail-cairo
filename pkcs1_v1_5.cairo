from starkware.cairo.common.uint256 import Uint256
from uint1024 import Uint1024
from uint2048 import Uint2048
from uint512 import Uint512

// https://github.com/dlitz/pycrypto/blob/v2.7a1/lib/Crypto/Signature/PKCS1_v1_5.py#L173
func pkcs_expected_hash(headers_hash: Uint256) -> Uint2048 {
    return (
        Uint2048(
            low=Uint1024(
                low=Uint512(
                    low=headers_hash,
                    high=Uint256(
                        low=0x0d060960864801650304020105000420,
                        high=0xFFFFFFFFFFFFFFFFFFFFFFFF00303130,
                    ),
                ),
                high=Uint512(
                    low=Uint256(
                        low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                    ),
                    high=Uint256(
                        low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                    ),
                ),
            ),
            high=Uint1024(
                low=Uint512(
                    low=Uint256(
                        low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                    ),
                    high=Uint256(
                        low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                    ),
                ),
                high=Uint512(
                    low=Uint256(
                        low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                    ),
                    high=Uint256(
                        low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        high=0x0001FFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                    ),
                ),
            ),
        )
    );
}
