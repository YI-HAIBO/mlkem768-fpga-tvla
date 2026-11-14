"""B4 GF(2^8) multiplier arbitration.

The B4 golden model's gf() and the RTL's gf256_mult are the SAME textbook
comb (8 fixed shift-xtime steps).  This script is the independent referee:
it cross-checks that comb against the audited `galois` library field
GF(2^8)/x^8+x^4+x^3+x+1 over all 65536 byte pairs, and checks the published
AES inverse-table literals that depend only on that field.

It also documents two traps that cost real debugging time:

1. GF(2) polynomial multiplication is XOR-based with NO carries, so the
   integer product (a*b) is NOT the polynomial product.  Any 'ground truth'
   built on (a*b) is invalid -- it disagrees with galois on ~87% of pairs.
   Reduce with top-bit folding instead:

       while p.bit_length() > 8:
           p ^= 0x11B << (p.bit_length() - 9)

2. In this field x = 2 has multiplicative order 51, not 255: 0x11B is
   irreducible but 2 is not a primitive element.  A log/antilog table built
   on base 2 therefore has only 51 distinct entries and cannot be used as a
   multiplication oracle here.

Reference vectors (all confirmed by galois below):
    0x57 * 0x83 = 0xC1        inv(0x53) = 0xCA
    0x02 * 0xC0 = 0x9B        inv(0x57) = 0xBF
    x^8 = 0x1B, x^12 = 0xAB, x^24 = 0xB3, x^51 = 1
"""
import galois

POLY = 0x11B


def xtime(x):
    x &= 0xFF
    if x & 0x80:
        return ((x << 1) ^ 0x1B) & 0xFF
    return (x << 1) & 0xFF


def gf_shift(a, b):
    """Schoolbook comb: exactly what mpc_private_infer.v's gf256_mult does."""
    acc = 0
    ai = a & 0xFF
    for _ in range(8):
        if b & 1:
            acc ^= ai
        ai = xtime(ai)
        b >>= 1
    return acc & 0xFF


GF8 = galois.GF(2 ** 8, irreducible_poly=POLY, compile='python-calculate')

print("galois: |GF| = %d, characteristic = %d" % (GF8.order, GF8.characteristic))
print("galois: order of x (0x02) = %d  (51 -- 2 is NOT primitive here)"
      % GF8(2).multiplicative_order())
print("galois: inv(0x02) = 0x%02x   inv(0x53) = 0x%02x   inv(0x57) = 0x%02x"
      % (int(GF8(0x02) ** -1), int(GF8(0x53) ** -1), int(GF8(0x57) ** -1)))
print()

REF = {
    (0x57, 0x83): 0xC1,
    (0x02, 0xC0): 0x9B,
    (0x53, 0xCA): 0x01,   # AES inverse-table pair
    (0x57, 0xBF): 0x01,   # AES inverse-table pair
    (0x57, 0x01): 0x57,
    (0x00, 0xFF): 0x00,
}
for (a, b), want in REF.items():
    got = gf_shift(a, b)
    ref = int(GF8(a) * GF8(b))
    print("  %02x*%02x  want 0x%02x   gf_shift 0x%02x   galois 0x%02x   %s"
          % (a, b, want, got, ref, "OK" if got == want == ref else "** BAD **"))

bad = sum(1 for a in range(256) for b in range(256)
          if gf_shift(a, b) != int(GF8(a) * GF8(b)))
print()
print("gf_shift vs galois over all 65536 pairs: %d mismatches" % bad)

comm = sum(1 for a in range(256) for b in range(256)
           if gf_shift(a, b) != gf_shift(b, a))
dist = sum(1 for c in range(256) for a in range(64) for b in range(64)
           if gf_shift(a ^ b, c) != (gf_shift(a, c) ^ gf_shift(b, c)))
print("commutativity violations : %d" % comm)
print("distributivity violations: %d / 262144 sampled triples" % dist)

x = GF8(2)
print("x^8 = 0x%02x  x^12 = 0x%02x  x^24 = 0x%02x  x^51 = 0x%02x  x^255 = 0x%02x"
      % (int(x ** 8), int(x ** 12), int(x ** 24), int(x ** 51), int(x ** 255)))

print()
print("VERDICT: " + ("gf_shift == galois everywhere -- B4 multiplier is sound"
                     if bad == 0 else "MISMATCH -- do not tape out"))
