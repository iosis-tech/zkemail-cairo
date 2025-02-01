%builtins output range_check bitwise

from base64 import base64_decode
from extract import extract_bytes, bytes_len
from pkcs1_v1_5 import pkcs_expected_hash
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

        SIGNATURE = 4950857126382090904395666539073412553915468586249064782730752283269420770803017179909266888714062423722402575770414696227104996512407513621161912263543535808180802657760978542968355153552121325495949043488066638746371804065033261690006082843555011711977191334442586314951871624110820074570957764029297641158177298891714351167093138528724731339181741264464337136841133187987764657690029227127280700339818947365744859419858282526281705712679095496257474865245147782713002085427107305594849748058252201693255071609329742094081113791314344742381607958750286333132026778080655356366738431112040252381457045173938422270120
        N = 20054049931062868895890884170436368122145070743595938421415808271536128118589158095389269883866014690926251520949836343482211446965168263353397278625494421205505467588876376305465260221818103647257858226961376710643349248303872103127777544119851941320649869060657585270523355729363214754986381410240666592048188131951162530964876952500210032559004364102337827202989395200573305906145708107347940692172630683838117810759589085094521858867092874903269345174914871903592244831151967447426692922405241398232069182007622735165026000699140578092635934951967194944536539675594791745699200646238889064236642593556016708235359
        BODY = [757936176, 808464432, 808464432, 808465252, 842097508, 808858211, 1714500409, 892341514, 1131376244, 1701737517, 1417244773, 975205477, 2020880240, 1818323310, 991978344, 1634890597, 1950163541, 1413885240, 571279885, 175268206, 1685024032, 1668247156, 1701737485, 168626733, 758132784, 808464432, 808464432, 808674354, 828597296, 909271910, 825440565, 806160963, 1869509733, 1853107540, 2037409082, 544499064, 1949263988, 1835809568, 1667785074, 1936028733, 576017478, 758653453, 168626748, 1684633120, 1684632125, 577533042, 574517857, 1852075885, 543387502, 1952804468, 1009738857, 1983778058, 218770733, 808464432, 808464432, 808464432, 862204465, 1667510326, 845375025, 859387184, 757927178, 2147483648, 0, 1952]
        HEADERS = [1953446498, 1634890863, 1937391720, 1701998436, 1869903219, 778331510, 218788725, 1651139939, 1949987941, 1835103245, 174941555, 1935763301, 761881658, 1011040580, 1632713082, 1984835943, 1479241574, 2050848122, 826098286, 1867148133, 2051162690, 1346851660, 843206506, 892420951, 945374765, 1781807463, 1080910185, 1814980461, 1634298926, 1668246846, 218784865, 1952791124, 1752509472, 858792010, 1634607154, 808596768, 842021425, 859451959, 539701297, 808455434, 1718775661, 977428850, 1952803616, 1315927905, 1797274722, 1634890853, 1802384179, 926967661, 1634298926, 1668246846, 218787177, 1835347318, 1701999465, 1869494833, 774901002, 1684760941, 762538343, 1851880565, 1919236726, 1026636576, 1631416947, 1630368616, 1630680374, 991978301, 1919249505, 2019910703, 1919249505, 2019910715, 543440231, 1835100524, 778268525, 991982397, 842019379, 808857649, 991982653, 825701176, 842413108, 825834272, 2017276215, 859322422, 959590713, 991978593, 1919827304, 1701998436, 1869903219, 778331510, 991979581, 1953446515, 1969384037, 1668561517, 1702064993, 1734684009, 1681548385, 1952791142, 1919905082, 1835625829, 762733938, 1936289646, 979792495, 1832547439, 979591994, 1937072746, 1701016608, 979657076, 1698327909, 1936941415, 1697474916, 980575600, 1819880820, 1866145890, 1748853065, 1917600065, 2004170544, 1448430415, 1966164016, 1211065957, 1261851458, 1800948022, 2036944201, 1969439081, 1630556780, 1362967328, 1648197632, 0, 0, 0, 0, 3920]

        body_advice = ((0,0),(61,0))
        body_hash_advice = ((110,2),(121,2))
        domain_advice = ((68,3),(71,0))
        darn_advice = ((82,3),(86,0))
    %}

    local sig: Uint2048;
    %{ set_u2048(ids.sig, SIGNATURE) %}
    local n: Uint2048;
    %{ set_u2048(ids.n, N) %}

    let (local headers) = alloc();
    %{ segments.write_arg(ids.headers, HEADERS) %}
    local headers_len = nondet %{ len(HEADERS) %};

    let (local body) = alloc();
    %{ segments.write_arg(ids.body, BODY) %}
    local body_len = nondet %{ len(BODY) %};

    %{ advice = body_hash_advice %}
    let (local b64_body_hash) = alloc();
    extract_bytes(
        headers,
        b64_body_hash,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local b64_body_hash_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    let (local body_hash_bytes) = alloc();
    let body_hash_bytes_len = base64_decode(b64_body_hash, b64_body_hash_len, body_hash_bytes);
    let (header_body_hash) = uint256_from_u8_be(body_hash_bytes);

    let (local body_hash_ptr, local body_hash_len) = sha256(body, body_len);
    let (calculated_body_hash) = uint256_from_u32_be(body_hash_ptr);

    let (eq) = uint256_eq(header_body_hash, calculated_body_hash);
    assert eq = 1;

    let (local headers_hash_ptr, local headers_hash_len) = sha256(headers, headers_len);
    let (calculated_headers_hash) = uint256_from_u32_be(headers_hash_ptr);

    let expected_hash = pkcs_expected_hash(calculated_headers_hash);

    let (calculated_hash) = uint2048_pow_mod_recursive(sig, 65537, n);

    let eq = uint2048_eq(calculated_hash, expected_hash);
    assert eq = 1;

    %{ advice = domain_advice %}
    let (local domain) = alloc();
    extract_bytes(
        headers,
        domain,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local domain_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    %{ advice = darn_advice %}
    let (local darn) = alloc();
    extract_bytes(
        headers,
        darn,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local darn_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    %{ advice = body_advice %}
    let (local body_str) = alloc();
    extract_bytes(
        body,
        body_str,
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );
    local body_str_len = bytes_len(
        nondet %{ advice.a_quo %},
        nondet %{ advice.a_rem %},
        nondet %{ advice.b_quo %},
        nondet %{ advice.b_rem %},
    );

    %{ print("domain: ", bytes(memory.get_range(ids.domain, ids.domain_len)).decode('utf-8')) %}
    %{ print("darn: ", bytes(memory.get_range(ids.darn, ids.darn_len)).decode('utf-8')) %}
    %{ print(bytes(memory.get_range(ids.body_str, ids.body_str_len)).decode('utf-8')) %}

    // assert [output_ptr] = domain_len;
    // let output_ptr = output_ptr + 1;
    // memcpy(output_ptr, domain, domain_len);
    // let output_ptr = output_ptr + domain_len;

    // assert [output_ptr] = darn_len;
    // let output_ptr = output_ptr + 1;
    // memcpy(output_ptr, darn, darn_len);
    // let output_ptr = output_ptr + darn_len;

    // assert [output_ptr] = body_str_len;
    // let output_ptr = output_ptr + 1;
    // memcpy(output_ptr, body_str, body_str_len);
    // let output_ptr = output_ptr + body_str_len;

    return ();
}
