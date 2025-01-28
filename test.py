import hashlib

def preprocess(message: bytearray):
    length = len(message) * 8 # len(message) is number of BYTES!!!
    message.append(0x80)
    while (len(message) * 8 + 64) % 512 != 0:
        message.append(0x00)
    message += length.to_bytes(8, 'big') # pad to 8 bytes or 64 bits
    assert (len(message) * 8) % 512 == 0, "Padding did not complete properly!"
    return message

# Padded data
message = preprocess(bytearray(b'test test\r\n'))

# Compute SHA-256 hash
sha256_hash = hashlib.sha256(message).hexdigest()
print("SHA-256 Hash:", sha256_hash)