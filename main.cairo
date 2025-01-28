%builtins range_check bitwise

from base64 import base64_decode
from extract import extract_bytes
from sha256 import sha256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from uint1024 import Uint1024, uint1024_eq, uint1024_pow_mod_recursive
from uint256 import uint256_from_u8_be, uint256_from_u32_be
from uint512 import Uint512

func main{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
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

        SIGNATURE = 84672234939279020024841303153204474968810663921948959841342463954491385286682976989473715824330808812302118141619399389796350577757623952853295771724923759991954067521654791673695723870339307588834050107404265779157084083608961852636542424103178749028222572305702080054944680907976318825715960367058255917609
        N = 109840904909940404959744221876858620709969218326506407082221779394032326489812790786649034812718574099046117725854400828455845069780702401414898758049907995661494814186559221483509803472525659208951140463116595200877740816407104014421586827141402457631883375757223612729692148186236929622346251839432830432649
        BODY = [1952805748, 544499059, 1947011712, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 88]
        HEADERS = [1718775661, 977496178, 1769174121, 1634607187, 1667788389, 1768187250, 540828520, 1919513460, 1767992878, 1935894638, 1701405797, 1916821870, 1685221225, 1684828022, 1702047341, 1698565386, 1937072746, 1701016634, 1952999795, 543781664, 1629516901, 1936990317, 1634298893, 174350708, 1698321249, 1949048881, 874532193, 1914712624, 842014770, 825898040, 976566048, 724578608, 806161005, 1702064993, 1734684009, 1681538100, 1664235570, 946103853, 845439333, 758592614, 1714238054, 1631006053, 912352051, 909193264, 859058496, 1634624626, 1869177964, 1870030195, 778921278, 218788975, 980246889, 1816161133, 1768713317, 779580518, 218784623, 1853121902, 1949135993, 1885682292, 1702392879, 1886151017, 1849368675, 1751216755, 1702116725, 1952853304, 991979119, 1919770996, 1030122607, 2003133453, 174288750, 1952804468, 762606177, 1853056613, 1915577710, 1668244585, 1852258871, 1651078157, 174353257, 1831695209, 1735287156, 1970431290, 1983721787, 543243634, 1935748467, 1751200309, 909844579, 1030907244, 1635280228, 796026220, 1635280228, 991978557, 1634624626, 1869177964, 1870030195, 778921275, 544423218, 808532272, 842151984, 825958516, 1026635064, 875704632, 959657787, 543702374, 1919905082, 1718775661, 980575600, 1819880820, 1866101621, 1651139939, 1949987701, 1651139939, 1949983841, 1952791140, 1635018042, 1835365235, 1634166061, 1768176237, 1702064993, 1734684009, 1681530996, 1866101871, 979591994, 1668247156, 1701737517, 1954115685, 979595118, 1952804468, 762607984, 1698308195, 1869509733, 1853107572, 1918987891, 1717924397, 1701733231, 1684631143, 979595118, 1952804468, 762606177, 1853056613, 1915577710, 1668244585, 1852259104, 1650998625, 1699504724, 1852593489, 1366700629, 1178949451, 1214605644, 894513230, 1783592810, 879457358, 1397321323, 947015215, 1345338683, 543309184, 0, 0, 0, 0, 0, 4920]
    %}

    local sig: Uint1024;
    %{ set_u1024(ids.sig, SIGNATURE) %}
    local n: Uint1024;
    %{ set_u1024(ids.n, N) %}

    let headers: felt* = alloc();
    %{ segments.write_arg(ids.headers, HEADERS) %}
    local headers_len = nondet %{ len(HEADERS) %};

    let body: felt* = alloc();
    %{ segments.write_arg(ids.body, BODY) %}
    local body_len = nondet %{ len(BODY) %};

    let b64_body_hash: felt* = alloc();
    extract_bytes(headers, b64_body_hash, 141, 3, 152, 3);
    let b64_body_hash_len = (152 - 141) * 4 - 3 + 3;

    let (local body_hash_bytes) = alloc();
    let decoded_len = base64_decode(b64_body_hash, b64_body_hash_len, body_hash_bytes);
    let (header_body_hash) = uint256_from_u8_be(body_hash_bytes);

    let (local body_hash_ptr, local body_hash_len) = sha256(body, body_len);
    let (calculated_body_hash) = uint256_from_u32_be(body_hash_ptr);

    let (eq) = uint256_eq(header_body_hash, calculated_body_hash);
    assert eq = 1;

    let (local headers_hash_ptr, local headers_hash_len) = sha256(headers, headers_len);
    let (calculated_headers_hash) = uint256_from_u32_be(headers_hash_ptr);

    // https://github.com/dlitz/pycrypto/blob/v2.7a1/lib/Crypto/Signature/PKCS1_v1_5.py#L173
    local expected_hash: Uint1024 = Uint1024(
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
                low=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, high=0x0001FFFFFFFFFFFFFFFFFFFFFFFFFFFF
            ),
        ),
    );

    let (calculated_hash) = uint1024_pow_mod_recursive(sig, 65537, n);

    let eq = uint1024_eq(calculated_hash, expected_hash);
    assert eq = 1;

    let (local domain) = alloc();
    extract_bytes(headers, domain, 90, 0, 93, 3);
    let domain_len = (93 - 90) * 4 - 0 + 3;

    %{ print("domain: ", bytes(memory.get_range(ids.domain, ids.domain_len)).decode('utf-8')) %}
    %{ print("body hash: ", hex((ids.header_body_hash.high << 128) + ids.header_body_hash.low)) %}

    return ();
}
