from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_sha256.sha256_utils import (
    SHA256_INPUT_CHUNK_SIZE_FELTS,
    finalize_sha256,
    SHA256_STATE_SIZE_FELTS,
)
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.memcpy import memcpy

// requires arg data_ptr that is multiple of 16 u32 numbers to hash and padded specific to sha256 to give expected results
func sha256{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}(
    data_ptr: felt*, data_len: felt
) -> (hash_ptr: felt*, hash_len: felt) {
    alloc_locals;

    local init_state: felt*;  // Pointer to start of data
    %{
        from starkware.cairo.common.cairo_sha256.sha256_utils import IV
        ids.init_state = init_state = segments.add()
        for i, val in enumerate(IV):
            memory[init_state + i] = val
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
    finalize_sha256(hash256_ptr_start, hash256_ptr_end);

    return (hash_ptr=hash256_ptr_end - SHA256_STATE_SIZE_FELTS, hash_len=SHA256_STATE_SIZE_FELTS);
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
