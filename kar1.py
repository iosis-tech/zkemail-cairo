def generate_karatsuba_res_code(num_limbs, chunk_size):
    # Generate the code for combining results using the Karatsuba formula
    # num_limbs: Total number of limbs (32 for Uint4096, but 63 partial sums)
    # chunk_size: Size of each chunk (e.g., 3 in the Uint384 example)
    
    # Initialize the list to store the generated code
    code = []
    
    # Generate the code for combining results
    for i in range(0, num_limbs * 2 - 1, 2):  # Iterate over even indices (0, 2, 4, ..., 62)
        if i == 0:
            # First chunk: res0 = d0 + d1 * HALF_SHIFT
            terms = [f"d{i}", f"d{i + 1} * HALF_SHIFT"]
            code.append(f"let (res{i}, carry) = split_128({' + '.join(terms)});")
        else:
            # Subsequent chunks: res{i} = d{i} + (d{i + 1} + A{k} * B{k} - d{i - chunk_size} - d{i + chunk_size}) * HALF_SHIFT + carry
            k = i // 2  # Index for A and B
            terms = [
                f"d{i}",
                f"(d{i + 1} + A{k} * B{k} - d{i - chunk_size} - d{i + chunk_size}) * HALF_SHIFT",
                "carry",
            ]
            code.append(f"let (res{i}, carry) = split_128({' + '.join(terms)});")
    
    # Add the final carry handling
    code.append(f"let (res{num_limbs * 2 - 2}, carry) = split_128(d{num_limbs * 2 - 2} + carry);")
    
    return "\n".join(code)

# Number of limbs in Uint4096 (32 limbs, but 63 partial sums)
num_limbs = 32

# Chunk size (e.g., 3 in the Uint384 example)
chunk_size = 3

# Generate the Karatsuba combine code
karatsuba_res_code = generate_karatsuba_res_code(num_limbs, chunk_size)

# Print the generated code
print(karatsuba_res_code)