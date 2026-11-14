"""Authoritative arbitration using two independent verified libraries:
  galois 0.4.11  - audited GF(p^n) arithmetic
  pycryptodome  - FIPS-197 AES S-box (depends only on the field inverse)
plus a textbook schoolbook (gf_shift) as the third voice.
"""
import galois
from Crypto.Cipher import AES as _AES

# ---------------------------------------------------------------- schoolbook
def xtime(x):
    x &= 0xFF
    if x & 0x80:
        return ((x << 1) ^ 0x1B) & 0xFF
    return (x << 1) & 0xFF


def gf_shift(a, b):
    acc = 0
    ai = a & 0xFF
    for _ in range(8):
        if b & 1:
            acc ^= ai
        ai = xtime(ai)
        b >>= 1
    return acc & 0xFF


# ---------------------------------------------------------------- galois lib
GF = galois.GF(2 ** 8, irreducible_poly=0x11B, compile='python-calculate')
x = GF(2)
order_x = x.multiplicative_order()
print("galois: GF(2^8)/0x11B constructed, |GF| = %d, p = %d" % (GF.order, GF.characteristic))
print("galois: order of x (0x02)      = %d   (255 => primitive)" % order_x)
print("galois: inv(0x02) = 0x%02x   inv(0x53) = 0x%02x   inv(0x57) = 0x%02x"
      % (int(GF(0x02) ** -1), int(GF(0x53) ** -1), int(GF(0x57) ** -1)))
print("galois: 0x02 * 0xC0 = 0x%02x    0x53 * 0xCA = 0x%02x"
      % (int(GF(0x02) * GF(0xC0)), int(GF(0x53) * GF(0xCA))))
print("galois: x^12 = 0x%02x   x^24 = 0x%02x   x^51 = 0x%02x   x^255 = 0x%02x"
      % (int(x ** 12), int(x ** 24), int(x ** 51), int(x ** 255)))

# ------------------------------------------------- pycryptodome AES S-box
SBOX = [int(v) for v in _AES.Sbox]
print()
print("pycryptodome AES S-box spot values:")
for a in (0x00, 0x01, 0x02, 0x50, 0x53, 0x57, 0x9A, 0xFF):
    print("  S(0x%02x) = 0x%02x" % (a, SBOX[a]))

# ---------------------------------------------------------------- agreement
bad = 0
badex = []
for a in range(256):
    for b in range(256):
        g = int(GF(a) * GF(b))
        s = gf_shift(a, b)
        if g != s:
            bad += 1
            if len(badex) < 8:
                badex.append((a, b, g, s))
print()
print("gf_shift vs galois over all 65536 pairs: %d mismatches" % bad)
for a, b, g, s in badex:
    print("   0x%02x*0x%02x  galois=0x%02x  gf_shift=0x%02x" % (a, b, g, s))
