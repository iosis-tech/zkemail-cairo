#!/usr/bin/env python3
from typing import Dict, Optional
import re
import sys
from base64 import b64encode, b64decode
import email
import email.message
from Crypto.Signature import PKCS1_v1_5
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
from Crypto.Util.asn1 import DerSequence, DerNull, DerOctetString, DerObjectId
import Crypto.Util
from Crypto.Util.number import bytes_to_long, long_to_bytes
import dns.resolver


def bytes_to_u32_array(data):
    """
    Converts a byte array into an array of 32-bit unsigned integers.
    Each chunk contains 4 bytes (32 bits).
    
    Args:
        data (bytes): Input byte array.
    
    Returns:
        list[int]: List of 32-bit unsigned integers.
    """
    # Pad data to ensure it is a multiple of 4 bytes
    padding = len(data) % 4
    if padding != 0:
        data += b'\x00' * (4 - padding)

    # Convert chunks of 4 bytes into 32-bit integers
    u32_array = []
    for i in range(0, len(data), 4):
        chunk = data[i:i+4]
        u32_value = int.from_bytes(chunk, byteorder='big')  # Big-endian order
        u32_array.append(u32_value)
    
    return u32_array

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
    return result_bytes

def preprocess(message: bytearray):
    length = len(message) * 8 # len(message) is number of BYTES!!!
    message.append(0x80)
    while (len(message) * 8 + 64) % 512 != 0:
        message.append(0x00)
    message += length.to_bytes(8, 'big') # pad to 8 bytes or 64 bits
    assert (len(message) * 8) % 512 == 0, "Padding did not complete properly!"
    return message

K = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]

def generate_hash(message: bytearray) -> bytearray:
    """Return a SHA-256 hash from the message passed.
    The argument should be a bytes, bytearray, or
    string object."""

    if isinstance(message, str):
        message = bytearray(message, 'ascii')
    elif isinstance(message, bytes):
        message = bytearray(message)
    elif not isinstance(message, bytearray):
        raise TypeError

    # Padding
    length = len(message) * 8 # len(message) is number of BYTES!!!
    message.append(0x80)
    while (len(message) * 8 + 64) % 512 != 0:
        message.append(0x00)

    message += length.to_bytes(8, 'big') # pad to 8 bytes or 64 bits

    assert (len(message) * 8) % 512 == 0, "Padding did not complete properly!"

    print(bytes_to_u32_array(message))

    # Parsing
    blocks = [] # contains 512-bit chunks of message
    for i in range(0, len(message), 64): # 64 bytes is 512 bits
        blocks.append(message[i:i+64])

    # Setting Initial Hash Value
    h0 = 0x6a09e667
    h1 = 0xbb67ae85
    h2 = 0x3c6ef372
    h3 = 0xa54ff53a
    h5 = 0x9b05688c
    h4 = 0x510e527f
    h6 = 0x1f83d9ab
    h7 = 0x5be0cd19

    # SHA-256 Hash Computation
    for message_block in blocks:
        # Prepare message schedule
        message_schedule = []
        for t in range(0, 64):
            if t <= 15:
                # adds the t'th 32 bit word of the block,
                # starting from leftmost word
                # 4 bytes at a time
                message_schedule.append(bytes(message_block[t*4:(t*4)+4]))
            else:
                term1 = _sigma1(int.from_bytes(message_schedule[t-2], 'big'))
                term2 = int.from_bytes(message_schedule[t-7], 'big')
                term3 = _sigma0(int.from_bytes(message_schedule[t-15], 'big'))
                term4 = int.from_bytes(message_schedule[t-16], 'big')

                # append a 4-byte byte object
                schedule = ((term1 + term2 + term3 + term4) % 2**32).to_bytes(4, 'big')
                message_schedule.append(schedule)

        assert len(message_schedule) == 64

        # Initialize working variables
        a = h0
        b = h1
        c = h2
        d = h3
        e = h4
        f = h5
        g = h6
        h = h7

        # Iterate for t=0 to 63
        for t in range(64):
            t1 = ((h + _capsigma1(e) + _ch(e, f, g) + K[t] +
                   int.from_bytes(message_schedule[t], 'big')) % 2**32)

            t2 = (_capsigma0(a) + _maj(a, b, c)) % 2**32

            h = g
            g = f
            f = e
            e = (d + t1) % 2**32
            d = c
            c = b
            b = a
            a = (t1 + t2) % 2**32

        # Compute intermediate hash value
        h0 = (h0 + a) % 2**32
        h1 = (h1 + b) % 2**32
        h2 = (h2 + c) % 2**32
        h3 = (h3 + d) % 2**32
        h4 = (h4 + e) % 2**32
        h5 = (h5 + f) % 2**32
        h6 = (h6 + g) % 2**32
        h7 = (h7 + h) % 2**32

    return ((h0).to_bytes(4, 'big') + (h1).to_bytes(4, 'big') +
            (h2).to_bytes(4, 'big') + (h3).to_bytes(4, 'big') +
            (h4).to_bytes(4, 'big') + (h5).to_bytes(4, 'big') +
            (h6).to_bytes(4, 'big') + (h7).to_bytes(4, 'big'))

def _sigma0(num: int):
    """As defined in the specification."""
    num = (_rotate_right(num, 7) ^
           _rotate_right(num, 18) ^
           (num >> 3))
    return num

def _sigma1(num: int):
    """As defined in the specification."""
    num = (_rotate_right(num, 17) ^
           _rotate_right(num, 19) ^
           (num >> 10))
    return num

def _capsigma0(num: int):
    """As defined in the specification."""
    num = (_rotate_right(num, 2) ^
           _rotate_right(num, 13) ^
           _rotate_right(num, 22))
    return num

def _capsigma1(num: int):
    """As defined in the specification."""
    num = (_rotate_right(num, 6) ^
           _rotate_right(num, 11) ^
           _rotate_right(num, 25))
    return num

def _ch(x: int, y: int, z: int):
    """As defined in the specification."""
    return (x & y) ^ (~x & z)

def _maj(x: int, y: int, z: int):
    """As defined in the specification."""
    return (x & y) ^ (x & z) ^ (y & z)

def _rotate_right(num: int, shift: int, size: int = 32):
    """Rotate an integer right."""
    return (num >> shift) | (num << size - shift)

def hash_body(body: str) -> str:
    # https://tools.ietf.org/html/rfc6376#section-3.4.4
    # body canonicalization as specified in https://tools.ietf.org/html/rfc6376#section-3.4.4
    # this code is not RFC compliant. It misses for example:
    # ** Reduce all sequences of WSP within a line to a single SP ** 
    canonicalized_body = body.strip().encode() + b"\r\n"
    print("canonicalized_body:", bytes_to_u32_array(preprocess(bytearray(canonicalized_body))))
    print("data:", canonicalized_body)
    print("hash:", generate_hash(canonicalized_body).hex())
    print("hash:", SHA256.new(canonicalized_body).digest().hex())
    bh = b64encode(SHA256.new(canonicalized_body).digest())
    assert bh == b'aeLbTnlUQQv2UFEWKHeiL5Q0NjOwj4ktNSInk8rN/P0='
    return bh.decode()


def get_public_key(domain: str, selector: str) -> RSA.RsaKey:
    dns_response = dns.resolver.resolve("{}._domainkey.{}.".format(selector, domain), "TXT").response.answer[0].to_text()
    p = re.search(r'p=([\w\d/+]*)', dns_response).group(1)
    pub_key = RSA.importKey(b64decode(p))
    assert pub_key.e == 65537
    assert pub_key.n == 109840904909940404959744221876858620709969218326506407082221779394032326489812790786649034812718574099046117725854400828455845069780702401414898758049907995661494814186559221483509803472525659208951140463116595200877740816407104014421586827141402457631883375757223612729692148186236929622346251839432830432649
    return pub_key


def parse_dkim_header(dkim_header: str) -> Dict[str, str]:
    """
    dkim_header: DKIM-Signature header from the mail as str
        v=1; a=rsa-sha256; c=relaxed/relaxed; d=androidloves.me;
        s=2019022801; t=1584218937;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=aeLbTnlUQQv2UFEWKHeiL5Q0NjOwj4ktNSInk8rN/P0=;
        b=eJPHovlwH6mU2kj8rEYF2us6TJwQg0/T7NbJ6A1zHNbVJ5UJjyMOfn+tN3R/oSsBcSDsHT
        xGysZJIRPeXEEcAOPNqUV4PcybFf/5cQDVpKZtY7kj/SdapzeFKCPT+uTYGQp1VMUtWfc1
        SddyAZSw8lHcvkTqWhJKrCU0EoVAsik=

    return: Dict of parsed DKIM-Signature header
        {'v': '1',
         'a': 'rsa-sha256',
         'c': 'relaxed/relaxed',
         'd': 'androidloves.me',
         's': '2019022801',
         't': '1584218937',
         'h': 'from:from:reply-to:subject:subject:date:date:message-id:message-id:to:to:cc:content-type:content-type:content-transfer-encoding:content-transfer-encoding',
         'bh': 'aeLbTnlUQQv2UFEWKHeiL5Q0NjOwj4ktNSInk8rN/P0=',
         'b': 'eJPHovlwH6mU2kj8rEYF2us6TJwQg0/T7NbJ6A1zHNbVJ5UJjyMOfn+tN3R/oSsBcSDsHTxGysZJIRPeXEEcAOPNqUV4PcybFf/5cQDVpKZtY7kj/SdapzeFKCPT+uTYGQp1VMUtWfc1SddyAZSw8lHcvkTqWhJKrCU0EoVAsik='
        }
    """
    parameter = {}
    parts = dkim_header.split(";")
    for part in parts:
        key, value = part.split("=", 1)
        parameter[key.strip()] = re.sub(r'(\n|\t\|\r|\s)', "", value)
    return parameter


def hash_headers(mail: email.message.Message, header_to_hash: str, bh: str) -> SHA256.SHA256Hash:
    # mail: email.message.Message object
    # header_to_hash: list of email headers to hash seperated by a colon
    # bh: body hash of the email body base64 encoded
    #
    # in:  'from:from:reply-to:subject:subject:date:date:message-id:message-id:to:to:cc:content-type:content-type:content-transfer-encoding:content-transfer-encoding'
    # build "from:Christian Schneider <christian.schneider@androidloves.me>\r\n..."
    #

    header_to_hash_list = header_to_hash.split(":")
    headers = ""

    for header in header_to_hash_list:
        if mail[header] and header in header_to_hash_list:
            headers += header.lower() + ":" + mail[header].strip() + "\r\n"
            header_to_hash_list.remove(header) # strip duplicate header like the from

    dkim_header = mail.get("DKIM-Signature")
    dkim_header = re.sub(r'(\n|\r)', "", dkim_header)
    dkim_header = re.sub(r'\s+', " ", dkim_header)
    headers += "dkim-signature:{}\r\n".format(dkim_header)
    headers = re.sub(r'b=[\w0-9\s/+=]+', "b=", headers) #replace b=... with be=

    print("headers:", bytes_to_u32_array(headers.encode()))

    hheader = SHA256.new(headers.encode())
    assert hheader.hexdigest() == "5188ff42a5ab71ae70236cf66822ab963b0977a3e7d932237fbfc35005195720"
    return hheader


def pkcs1_v1_5_encode(msg_hash: SHA256.SHA256Hash, emLen: int) -> bytes:
    # this code is copied from  EMSA_PKCS1_V1_5_ENCODE
    # https://github.com/dlitz/pycrypto/blob/v2.7a1/lib/Crypto/Signature/PKCS1_v1_5.py#L173
    digestAlgo = DerSequence([ DerObjectId(msg_hash.oid).encode() ])

    #if with_hash_parameters:
    if True:
        digestAlgo.append(DerNull().encode())

    digest      = DerOctetString(msg_hash.digest())
    digestInfo  = DerSequence([
                    digestAlgo.encode(),
                      digest.encode()
                    ]).encode()

    # We need at least 11 bytes for the remaining data: 3 fixed bytes and
    # at least 8 bytes of padding).
    if emLen<len(digestInfo)+11:
          raise TypeError("Selected hash algorith has a too long digest (%d bytes)." % len(digest))
    PS = b'\xFF' * (emLen - len(digestInfo) - 3)
    return b'\x00\x01' + PS + b'\x00' + digestInfo


def verify_signature(hashed_header: SHA256.SHA256Hash, signature: bytes, public_key: RSA.RsaKey) -> bool:
    modBits = Crypto.Util.number.size(public_key.n)
    emLen = modBits // 8

    signature_long = bytes_to_long(signature)
    print("signature_long:", signature_long.bit_length())
    print("public_key.e:", public_key.e)
    print("public_key.e:", public_key.n)
    expected_message_int = pow(signature_long, public_key.e, public_key.n)
    print("expected_message_int:", expected_message_int)
    expected_message = long_to_bytes(expected_message_int, emLen)

    padded_hash = pkcs1_v1_5_encode(hashed_header, emLen)

    assert padded_hash == expected_message
    return padded_hash == expected_message


if __name__ == '__main__':
    mail = email.message_from_bytes(open("email.eml", "rb").read())
    dkim_header = mail.get("DKIM-Signature")

    dkim_parameter = parse_dkim_header(dkim_header)

    body = mail.get_payload()

    print(dkim_header)
    print(body)

    body_hash = hash_body(body)

    if body_hash == dkim_parameter['bh']:
        print("body hash matches")
    else:
        print(f"body hash mismatch. Got {body_hash} - expected {dkim_parameter['bh']}")
        sys.exit(1)

    public_key = get_public_key(dkim_parameter['d'], dkim_parameter['s'])
    hashed_header = hash_headers(mail, dkim_parameter['h'], body_hash)

    signature = b64decode(dkim_parameter['b'])

    if verify_signature(hashed_header, signature, public_key):
        print("signature is valid")
    else:
        print("signature is NOOOOT valid")
    print("done")


