from starkware.cairo.common.bitwise import bitwise_and, bitwise_or
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location

func base64_decode{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    arr: felt*, arr_len: felt, res: felt*
) -> felt {
    if (arr_len == 0) {
        return 0;
    }

    alloc_locals;
    let (decLookupTable_address) = get_label_location(decLookupTable);
    let b1 = decLookupTable_address[arr[0]];
    let b2 = decLookupTable_address[arr[1]];
    let b3 = decLookupTable_address[arr[2]];
    let b4 = decLookupTable_address[arr[3]];
    local increment: felt;

    if (arr[3] == '=') {
        if (arr[2] == '=') {
            // two padding characters, only one byte to decode
            let (b2_and_f0) = bitwise_and(b2, 0xF0);
            let (b2_shifted) = bitwise_or(b1 * 4, b2_and_f0 / 16);
            increment = 1;
            assert res[0] = b2_shifted;
        } else {
            // one padding character, two bytes to decode
            let (b2_and_f0) = bitwise_and(b2, 0xF0);
            let (c1) = bitwise_or(b1 * 4, b2_and_f0 / 16);
            let (b2_and_0f) = bitwise_and(b2, 0x0F);
            let (b3_and_3c) = bitwise_and(b3, 0x3C);
            let b3_shifted = b3_and_3c / 4;
            let (c2) = bitwise_or(b2_and_0f * 16, b3_shifted);
            increment = 2;
            assert res[0] = c1;
            assert res[1] = c2;
        }
    } else {
        // get 3 bytes from 4 base64 characters
        let (b2_and_f0) = bitwise_and(b2, 0xF0);
        let (c1) = bitwise_or(b1 * 4, b2_and_f0 / 16);
        let (b2_and_0f) = bitwise_and(b2, 0x0F);
        let (b3_and_3c) = bitwise_and(b3, 0x3C);
        let b3_shifted = b3_and_3c / 4;
        let (c2) = bitwise_or(b2_and_0f * 16, b3_shifted);
        let (b3_and_03) = bitwise_and(b3, 0x03);
        let (b4_and_3f) = bitwise_and(b4, 0x3F);
        let (c3) = bitwise_or(b3_and_03 * 64, b4_and_3f);
        increment = 3;
        assert res[0] = c1;
        assert res[1] = c2;
        assert res[2] = c3;
    }

    // Recursive call for the remaining Base64 string
    let len = base64_decode(arr + 4, arr_len - 4, res + increment);
    return increment + len;
}

decLookupTable:
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 62;
dw 80;
dw 80;
dw 80;
dw 63;
dw 52;
dw 53;
dw 54;
dw 55;
dw 56;
dw 57;
dw 58;
dw 59;
dw 60;
dw 61;
dw 80;
dw 80;
dw 80;
dw 64;
dw 80;
dw 80;
dw 80;
dw 0;
dw 1;
dw 2;
dw 3;
dw 4;
dw 5;
dw 6;
dw 7;
dw 8;
dw 9;
dw 10;
dw 11;
dw 12;
dw 13;
dw 14;
dw 15;
dw 16;
dw 17;
dw 18;
dw 19;
dw 20;
dw 21;
dw 22;
dw 23;
dw 24;
dw 25;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
dw 26;
dw 27;
dw 28;
dw 29;
dw 30;
dw 31;
dw 32;
dw 33;
dw 34;
dw 35;
dw 36;
dw 37;
dw 38;
dw 39;
dw 40;
dw 41;
dw 42;
dw 43;
dw 44;
dw 45;
dw 46;
dw 47;
dw 48;
dw 49;
dw 50;
dw 51;
dw 80;
dw 80;
dw 80;
dw 80;
dw 80;
