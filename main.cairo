%builtins output range_check bitwise

from base64 import base64_decode
from extract import extract_bytes
from sha256 import sha256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from uint1024 import Uint1024, uint1024_eq, uint1024_pow_mod_recursive
from uint2048 import Uint2048, uint2048_eq, uint2048_pow_mod_recursive
from uint256 import uint256_from_u8_be, uint256_from_u32_be
from uint512 import Uint512

func main{output_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;
    %{
        def get_u256_u32(v):
            ret = 0
            for i, val in enumerate(v[::-1]):
                ret += val << (32*i)
            return ret

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

        SIGNATURE = 0x34ebb391efedcd1c6d1f2d29670d8acb205eea258b1a80d031848cfd12f5e0a308888b773d0a4a9c5201b7481c57bb3183570892ac2a0c9a9c2b0c850d76356aafbdccd99b02a0b96c4ae7e7a2bc89c7cbf17eb02ff04513f6b8ce6a3cbabd84d0f128a255d7a4831d4fa3d8542d7029b8daa8a77e3e4fd647176264593175e74471555c08e6efb6862a7b6cf4e17c972817b14ebd88f4490615ad82bd5bece9e98bb2034d1a335ebb9913d3e3206b34335328c1c23a1b7afd3c93eddbca29b6beafc46806f21ca13b635acc38be063489791c23705bf5e6ee7de426c3ef25e6402b3fb6485eec2527838352b67c4d8a3352fa4f2614da142442ba14413d1ca8
        N = 20054049931062868895890884170436368122145070743595938421415808271536128118589158095389269883866014690926251520949836343482211446965168263353397278625494421205505467588876376305465260221818103647257858226961376710643349248303872103127777544119851941320649869060657585270523355729363214754986381410240666592048188131951162530964876952500210032559004364102337827202989395200573305906145708107347940692172630683838117810759589085094521858867092874903269345174914871903592244831151967447426692922405241398232069182007622735165026000699140578092635934951967194944536539675594791745699200646238889064236642593556016708235359
        BODY = [757936176, 808464432, 808464432, 808465205, 1630615396, 808858211, 1681404473, 943197450, 1131376244, 1701737517, 1417244773, 975205477, 2020880240, 1818323310, 991978344, 1634890597, 1950163541, 1413885240, 571279885, 174355824, 1628244493, 170732848, 808464432, 808464432, 808464435, 895562039, 1680881202, 1667512370, 959985677, 172191598, 1952804468, 760510832, 1698308212, 1702392879, 1752460652, 991978344, 1634890597, 1950163541, 1413885240, 571279885, 171730025, 1981834345, 1916609132, 1953636926, 1685418081, 1009738857, 1983778058, 218770733, 808464432, 808464432, 808464432, 859136305, 929312822, 845374520, 842610744, 757927178, 2147483648, 0, 0, 0, 0, 0, 0, 1792]
        HEADERS = [1953446498, 1634890863, 1937391720, 1701998436, 1869903219, 778331510, 218788725, 1651139939, 1949961482, 1835365235, 1634166061, 1768176188, 1128350817, 1362721396, 1464357962, 1162836290, 893670738, 726489191, 1346204503, 1666401365, 1515025709, 1313101424, 1714575471, 1750036592, 1195861824, 1835100524, 778530145, 1768697443, 1869430285, 174350708, 1698322277, 1680613426, 958417505, 1847603760, 842342449, 876228921, 976368928, 724578608, 806160998, 1919905082, 1113682548, 1701519438, 1870094699, 540828257, 1920230763, 1848849207, 1080520033, 1768697443, 1869430285, 174942573, 1697478245, 1920166255, 1849307438, 806160996, 1802071341, 1936287598, 1635022194, 1698330173, 825958497, 1030910817, 762538081, 842348091, 543374706, 1701601656, 1701064562, 1701601656, 1701067552, 1681745773, 1634298926, 1668246843, 544423218, 808596272, 909127995, 544488753, 926103601, 892745527, 909844600, 1026635571, 943142449, 892810811, 543449458, 1849518181, 1919902831, 1953854254, 1684371003, 543702388, 1866101621, 1651139939, 1949986149, 1936941415, 1697474916, 979657076, 1698326130, 1869429357, 1768777005, 1986359923, 1768910394, 1718775661, 980709178, 1667447411, 1969384037, 1668554810, 1684108389, 980247923, 1935763301, 761881658, 1919250540, 2033022063, 991978088, 1031292782, 1496337780, 1179529039, 1985373766, 1817723959, 1684563310, 1232032590, 2049669742, 859207542, 1785875321, 1112364377, 1027285090, 1031798784, 0, 0, 0, 0, 0, 3880]
    %}

    local sig: Uint2048;
    %{ set_u2048(ids.sig, SIGNATURE) %}
    local n: Uint2048;
    %{ set_u2048(ids.n, N) %}

    let headers: felt* = alloc();
    %{ segments.write_arg(ids.headers, HEADERS) %}
    local headers_len = nondet %{ len(HEADERS) %};

    let body: felt* = alloc();
    %{ segments.write_arg(ids.body, BODY) %}
    local body_len = nondet %{ len(BODY) %};

    let b64_body_hash: felt* = alloc();
    extract_bytes(headers, b64_body_hash, 109, 1, 120, 1);
    let b64_body_hash_len = (120 - 109) * 4 - 1 + 1;

    let (local body_hash_bytes) = alloc();
    let body_hash_bytes_len = base64_decode(b64_body_hash, b64_body_hash_len, body_hash_bytes);
    let (header_body_hash) = uint256_from_u8_be(body_hash_bytes);

    let (local body_hash_ptr, local body_hash_len) = sha256(body, body_len);
    let (calculated_body_hash) = uint256_from_u32_be(body_hash_ptr);

    let (eq) = uint256_eq(header_body_hash, calculated_body_hash);
    assert eq = 1;

    let (local headers_hash_ptr, local headers_hash_len) = sha256(headers, headers_len);
    let (calculated_headers_hash) = uint256_from_u32_be(headers_hash_ptr);

    // https://github.com/dlitz/pycrypto/blob/v2.7a1/lib/Crypto/Signature/PKCS1_v1_5.py#L173
    local expected_hash: Uint2048 = Uint2048(
        low=Uint1024(
            low=Uint512(
                low=calculated_headers_hash,
                high=Uint256(
                    low=0x0d060960864801650304020105000420, high=0xFFFFFFFFFFFFFFFFFFFFFFFF00303130
                ),
            ),
            high=Uint512(
                low=Uint256(
                    low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                ),
                high=Uint256(
                    low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                ),
            ),
        ),
        high=Uint1024(
            low=Uint512(
                low=Uint256(
                    low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                ),
                high=Uint256(
                    low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                ),
            ),
            high=Uint512(
                low=Uint256(
                    low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                ),
                high=Uint256(
                    low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0x0001FFFFFFFFFFFFFFFFFFFFFFFFFFFF
                ),
            ),
        ),
    );

    let (calculated_hash) = uint2048_pow_mod_recursive(sig, 65537, n);

    let eq = uint2048_eq(calculated_hash, expected_hash);
    assert eq = 1;

    let (local domain) = alloc();
    extract_bytes(headers, domain, 67, 0, 70, 0);
    let domain_len = (70 - 67) * 4 - 0 + 0;

    %{ print("domain: ", bytes(memory.get_range(ids.domain, ids.domain_len)).decode('utf-8')) %}
    %{ print("body hash: ", hex((ids.header_body_hash.high << 128) + ids.header_body_hash.low)) %}

    memcpy(output_ptr, domain, domain_len);
    let output_ptr = output_ptr + domain_len;
    memcpy(output_ptr, body_hash_bytes, body_hash_bytes_len);
    let output_ptr = output_ptr + body_hash_bytes_len;

    return ();
}
