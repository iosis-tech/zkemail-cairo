from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location

func extract_bytes{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    arr: felt*, res: felt*, chunk: felt, byte: felt, end_chunk: felt, end_byte: felt
) {
    if (chunk == end_chunk and byte == end_byte) {
        return ();
    }

    let (matrix_address) = get_label_location(matrix);
    let (shifter_address) = get_label_location(shifter);
    let (x_and_y) = bitwise_and(arr[chunk], matrix_address[byte]);
    let v = x_and_y / shifter_address[byte];
    assert res[0] = v;

    if (byte == 3) {
        extract_bytes(arr, res + 1, chunk + 1, 0, end_chunk, end_byte);
    } else {
        extract_bytes(arr, res + 1, chunk, byte + 1, end_chunk, end_byte);
    }

    return ();
}

matrix:
dw 0xFF000000;
dw 0xFF0000;
dw 0xFF00;
dw 0xFF;

shifter:
dw 0x1000000;
dw 0x10000;
dw 0x100;
dw 0x1;

func bytes_len{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    a: felt, a_rem: felt, b: felt, b_rem: felt
) -> felt {
    return ((b - a) * 4 - a_rem + b_rem);
}
