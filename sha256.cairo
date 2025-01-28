%builtins output range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_sha256.sha256_utils import (
    SHA256_INPUT_CHUNK_SIZE_FELTS,
    finalize_sha256,
    SHA256_STATE_SIZE_FELTS,
)

func main{output_ptr: felt, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;

    local data_len;  // Number of elements to hash
    local data_ptr: felt*;  // Pointer to start of data
    local init_state: felt*;  // Pointer to start of data
    %{
        from starkware.cairo.common.cairo_sha256.sha256_utils import IV
        data = program_input['data']
        ids.data_len = len(data)

        ids.init_state = init_state = segments.add()
        for i, val in enumerate(IV):
            memory[init_state + i] = val

        ids.data_ptr = data_ptr = segments.add()
        for i, val in enumerate(data):
            memory[data_ptr + i] = val

        def ints_to_hex(int_list, byte_order='big', byte_size=4):
            """
            Converts a list of integers into a concatenated bytearray and displays it as a hexadecimal string.

            Args:
                int_list (list[int]): List of integers to be converted.
                byte_order (str): Byte order ('big' or 'little') for conversion. Default is 'big'.
                byte_size (int): Number of bytes per integer. Default is 4 (32-bit).

            Returns:
                str: Hexadecimal representation of the concatenated bytearray.
            """
            # Convert each integer to a bytearray and concatenate
            result_bytes = bytearray()
            for value in int_list:
                result_bytes += value.to_bytes(byte_size, byteorder=byte_order)

            # Convert to hexadecimal string
            return result_bytes.hex()
    %}

    // Number of hash blocks needed to hash data
    let (num_data_blocks, _) = unsigned_div_rem(data_len, SHA256_INPUT_CHUNK_SIZE_FELTS);

    let (hash256_ptr: felt*) = alloc();

    let hash256_ptr_start = hash256_ptr;

    with hash256_ptr {
        memcpy(hash256_ptr, data_ptr, SHA256_INPUT_CHUNK_SIZE_FELTS);
        memcpy(hash256_ptr + SHA256_INPUT_CHUNK_SIZE_FELTS, init_state, SHA256_STATE_SIZE_FELTS);
        hash256_loop(data_ptr, num_data_blocks);
    }

    let hash256_ptr_end = hash256_ptr;

    %{ print(ints_to_hex(memory.get_range(ids.hash256_ptr_end - ids.SHA256_STATE_SIZE_FELTS, ids.SHA256_STATE_SIZE_FELTS))) %}

    finalize_sha256(hash256_ptr_start, hash256_ptr_end);
    return ();
}

func hash256_loop{range_check_ptr, hash256_ptr: felt*}(data_ptr: felt*, n) {
    let chunk = hash256_ptr;
    let hash256_ptr = hash256_ptr + SHA256_INPUT_CHUNK_SIZE_FELTS;

    let hash256_state = hash256_ptr;
    let hash256_ptr = hash256_ptr + SHA256_STATE_SIZE_FELTS;
    %{
        from starkware.cairo.common.cairo_sha256.sha256_utils import (
            IV, compute_message_schedule, sha2_compress_function)
        hash256 = sha2_compress_function(
            memory.get_range(ids.hash256_state, ids.SHA256_STATE_SIZE_FELTS),
            compute_message_schedule(memory.get_range(ids.chunk, ids.SHA256_INPUT_CHUNK_SIZE_FELTS))
        )
        segments.write_arg(ids.hash256_ptr, hash256)
    %}

    let hash256_ptr = hash256_ptr + SHA256_STATE_SIZE_FELTS;

    if (n - 1 == 0) {
        return ();
    }

    let data_ptr = data_ptr + SHA256_INPUT_CHUNK_SIZE_FELTS;

    memcpy(hash256_ptr, data_ptr, SHA256_INPUT_CHUNK_SIZE_FELTS);
    memcpy(
        hash256_ptr + SHA256_INPUT_CHUNK_SIZE_FELTS,
        hash256_ptr - SHA256_STATE_SIZE_FELTS,
        SHA256_STATE_SIZE_FELTS,
    );
    return hash256_loop(data_ptr, n - 1);
}
