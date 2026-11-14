"""Targeted diagnostic: why do some bytes report 'no inverse'?"""

POLY = 0x11B


def reduce_prod(prod):
    while prod.bit_length() > 8:
        d = prod.bit_length() - 1
        prod ^= POLY << (d - 8)
    return prod & 0xFF


def mul(a, b):
    return reduce_prod((a & 0xFF) * (b & 0xFF))


print("hand checks:")
print("  mul(0x80,0x80) = 0x%02x  (x^14 = 0x9A by hand)" % mul(0x80, 0x80))
print("  mul(0x57,0x83) = 0x%02x  (0x7C by hand)" % mul(0x57, 0x83))
print("  mul(0x57,0x01) = 0x%02x  (0x57)" % mul(0x57, 0x01))
print("  reduce_prod(1<<51) = 0x%02x" % reduce_prod(1 << 51))
print("  reduce_prod(1<<255) = 0x%02x" % reduce_prod(1 << 255))

# scan 0x05 * b over all b, look for 1
hits = [(b, mul(0x05, b)) for b in range(256) if mul(0x05, b) == 1]
print()
print("0x05 * b == 1  -> %s" % (["b=0x%02x" % b for b, _ in hits] or "NONE"))

# is the multiplication table a group at all? check closure + a known inverse pair
# 0x53 * 0xCA by independent brute force over the raw integer product
for a, b in ((0x53, 0xCA), (0x57, 0xBF), (0x80, 0x9B), (0x05, 0xA1)):
    print("  mul(0x%02x,0x%02x) = 0x%02x" % (a, b, mul(a, b)))

# irreducibility with CORRECTED range: degree-d monic polys are [2^d, 2^(d+1))
def divmod_gf2(f, g):
    dg = g.bit_length() - 1
    q, r = 0, f
    while r.bit_length() - 1 >= dg and r:
        shift = r.bit_length() - 1 - dg
        q |= 1 << shift
        r ^= g << shift
    return q, r


found = []
for d in range(1, 8):
    for f in range(1 << d, 1 << (d + 1)):
        if divmod_gf2(POLY, f)[1] == 0:
            found.append(f)
print()
print("monic divisors of 0x11B (deg 1..7): %s" % (["0x%02x" % f for f in found] or "NONE -> irreducible"))
