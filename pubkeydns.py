#!/usr/bin/env python3
from typing import Dict
import re
import sys
from base64 import b64encode, b64decode
import email
import email.message
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
from Crypto.Util.asn1 import DerSequence, DerNull, DerOctetString, DerObjectId
import Crypto.Util
from Crypto.Util.number import bytes_to_long, long_to_bytes
import dns.resolver


def get_public_key(domain: str, selector: str) -> RSA.RsaKey:
    dns_response = (
        dns.resolver.resolve("{}._domainkey.{}.".format(selector, domain), "TXT")
        .response.answer[0]
        .to_text()
    )
    p = re.search(r"p=([\w\d/+]*)", dns_response).group(1)
    pub_key = RSA.importKey(
        b64decode(
            "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAntvSKT1hkqhKe0xcaZ0x+QbouDsJuBfby/S82jxsoC/SodmfmVs2D1KAH3mi1AqdMdU12h2VfETeOJkgGYq5ljd996AJ7ud2SyOLQmlhaNHH7Lx+Mdab8/zDN1SdxPARDgcM7AsRECHwQ15R20FaKUABGu4NTbR2fDKnYwiq5jQyBkLWP+LgGOgfUF4T4HZb2PY2bQtEP6QeqOtcW4rrsH24L7XhD+HSZb1hsitrE0VPbhJzxDwI4JF815XMnSVjZgYUXP8CxI1Y0FONlqtQYgsorZ9apoW1KPQe8brSSlRsi9sXB/tu56LmG7tEDNmrZ5XUwQYUUADBOu7t1niwXwIDAQAB"
        )
    )

    return pub_key


print(get_public_key(domain="gmail.com", selector="20230601").e)
print(get_public_key(domain="gmail.com", selector="20230601").n)
