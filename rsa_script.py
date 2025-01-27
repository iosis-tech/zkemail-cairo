from cryptography.hazmat.primitives.asymmetric import rsa

# Generate RSA key pair for testing
private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
public_key = private_key.public_key()

# Extract public key components
n = public_key.public_numbers().n
e = public_key.public_numbers().e

# Example plaintext message and ciphertext
plaintext = 0x821391231231982893182941293819280398104908509832902843
ciphertext = pow(plaintext, e, n)  # Simulate RSA encryption

# Verify the ciphertext using divmod
# Step 1: Compute m^e
plaintext_power = pow(plaintext, e)  # plaintext^e

# Step 2: Use divmod to compute m^e mod n
quotient, remainder = divmod(plaintext_power, n)

# Step 3: Compare the remainder to the ciphertext
if remainder == ciphertext:
    print("Verification successful: Ciphertext is valid!")
else:
    print("Verification failed: Ciphertext is invalid.")

# Output the values
print("Plaintext:", plaintext)
print("Ciphertext:", ciphertext)
print("Computed Remainder (m^e mod n):", remainder)
print("E:", e)
print("N:", n)
