def generate_partial_sums(num_limbs):
    # Generate the partial sums for the multiplication of two Uint4096 numbers
    # Each Uint4096 has 32 limbs (d00, d01, ..., d31)
    
    # Initialize the list to store the partial sums
    partial_sums = []
    
    # Loop through each limb of the first number (a)
    for i in range(num_limbs):
        # Loop through each limb of the second number (b)
        for j in range(num_limbs):
            # Calculate the product of a[i] and b[j]
            product = f"a.d{i:02d} * b.d{j:02d}"
            
            # Determine the index of the partial sum
            sum_index = i + j
            
            # Append the product to the corresponding partial sum
            if sum_index >= len(partial_sums):
                partial_sums.append([])
            partial_sums[sum_index].append(product)
    
    # Generate the code for the partial sums
    code = []
    for idx, terms in enumerate(partial_sums):
        if terms:
            code.append(f"local d{idx:02d} = {' + '.join(terms)};")
    
    return "\n".join(code)

# Number of limbs in Uint4096
num_limbs = 32

# Generate the partial sums code
partial_sums_code = generate_partial_sums(num_limbs)

# Print the generated code
print(partial_sums_code)