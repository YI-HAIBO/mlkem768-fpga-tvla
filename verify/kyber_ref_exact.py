"""
Exact pq-crystals/kyber reference implementation in Python.
Simulates int16_t arithmetic for montgomery_reduce/barrett_reduce.
Verifies poly_mul against schoolbook.
"""
import random

q = 3329
QINV = -3327  # q^{-1} mod 2^16, signed

# Reference zetas from ref/ntt.c (signed, Montgomery form)
ZETAS = [
    -1044, -758, -359, -1517, 1493, 1422, 287, 202,
    3158, 622, 1577, 182, 962, 2127, 1855, 1468,
    573, 2004, 264, 383, 2500, 1458, 1727, 3199,
    2648, 1017, 732, 608, 1787, 411, 3124, 1758,
    1223, 652, 2777, 1015, 2036, 1491, 3047, 1785,
    516, 3321, 3009, 2663, 1711, 2167, 126, 1469,
    2476, 3239, 3058, 830, 107, 1908, 3082, 2378,
    2931, 961, 1821, 2604, 448, 2264, 677, 2054,
    2226, 430, 555, 843, 2078, 871, 1550, 105,
    422, 587, 177, 3094, 3038, 2869, 1574, 1653,
    3083, 778, 1159, 3182, 2552, 1483, 2727, 1119,
    1739, 644, 2457, 349, 418, 329, 3173, 3254,
    817, 1097, 603, 610, 1322, 2044, 1864, 384,
    2114, 3193, 1218, 1994, 2455, 220, 2142, 1670,
    2144, 1799, 2051, 794, 1819, 2475, 2459, 478,
    3221, 3021, 996, 991, 958, 1869, 1522, 1628,
]

def montgomery_reduce(a):
    """Reference: int16_t montgomery_reduce(int32_t a)"""
    # Simulate int16_t t = (int16_t)a * QINV
    t = (a & 0xFFFF) * QINV
    t = t & 0xFFFF  # cast to int16_t (take lower 16 bits, signed)
    if t >= 32768:
        t -= 65536
    # t = (a - (int32_t)t * KYBER_Q) >> 16
    result = (a - t * q) >> 16
    return result

def barrett_reduce(a):
    """Reference: int16_t barrett_reduce(int16_t a)"""
    v = 20159  # ((1<<26) + q/2)/q
    t = (v * a + (1 << 25)) >> 26
    return a - t * q

def fqmul(a, b):
    """Reference: int16_t fqmul(int16_t a, int16_t b)"""
    return montgomery_reduce(a * b)

def ntt(a):
    """Reference: void ntt(int16_t r[256]) — forward NTT"""
    a = list(a)  # copy
    k = 1
    length = 128
    while length >= 2:
        start = 0
        while start < 256:
            zeta = ZETAS[k]
            k += 1
            for j in range(start, start + length):
                t = fqmul(zeta, a[j + length])
                a[j + length] = a[j] - t
                a[j] = a[j] + t
            start = j + length + 1  # Note: reference uses start = j + len + 1
        length >>= 1
    return a

def invntt(a):
    """Reference: void invntt(int16_t r[256]) — inverse NTT"""
    a = list(a)  # copy
    k = 127
    length = 2
    f = 1441  # mont^2/128
    while length <= 128:
        start = 0
        while start < 256:
            zeta = ZETAS[k]
            k -= 1
            for j in range(start, start + length):
                t = a[j]
                a[j] = barrett_reduce(t + a[j + length])
                a[j + length] = a[j + length] - t
                a[j + length] = fqmul(zeta, a[j + length])
            start = j + length + 1
        length <<= 1
    for j in range(256):
        a[j] = fqmul(a[j], f)
    return a

def basemul(r, r_off, a, a_off, b, b_off, zeta):
    """Reference basemul on 2-element slices"""
    a0, a1 = a[a_off], a[a_off + 1]
    b0, b1 = b[b_off], b[b_off + 1]
    r0 = fqmul(a1, b1)
    r0 = fqmul(r0, zeta)
    r0 += fqmul(a0, b0)
    r1 = fqmul(a0, b1)
    r1 += fqmul(a1, b0)
    r[r_off] = r0
    r[r_off + 1] = r1

def poly_reduce(a):
    """Reference: void poly_reduce(poly *r) — barrett_reduce each coeff"""
    return [barrett_reduce(x) for x in a]

def poly_ntt(a):
    """Reference: poly_ntt = ntt + poly_reduce"""
    return poly_reduce(ntt(a))

def poly_basemul_montgomery(a, b):
    """Reference: poly_basemul_montgomery"""
    r = [0] * 256
    for i in range(64):
        basemul(r, 4*i, a, 4*i, b, 4*i, ZETAS[64 + i])
        basemul(r, 4*i + 2, a, 4*i + 2, b, 4*i + 2, -ZETAS[64 + i])
    return r

def poly_invntt_tomont(a):
    """Reference: poly_invntt_tomont = invntt"""
    return invntt(a)

def poly_mul(a, b):
    """Reference: poly_mul = poly_ntt + poly_basemul_montgomery + poly_invntt_tomont"""
    a_ntt = poly_ntt(a)
    b_ntt = poly_ntt(b)
    c_ntt = poly_basemul_montgomery(a_ntt, b_ntt)
    return poly_invntt_tomont(c_ntt)

def schoolbook(a, b):
    """Negacyclic convolution: a*b in Zq[X]/(X^256+1)"""
    n = 256
    c = [0] * (2 * n)
    for i in range(n):
        for j in range(n):
            c[i + j] += a[i] * b[j]
    result = [0] * n
    for k in range(n):
        result[k] = c[k] - c[k + n]
    return [x % q for x in result]

# Test
random.seed(42)
a = [random.randint(0, q - 1) for _ in range(256)]
b = [random.randint(0, q - 1) for _ in range(256)]

# Reference poly_mul
c_ref = poly_mul(a, b)

# Schoolbook
c_sb = schoolbook(a, b)

# Check: poly_mul should give schoolbook * R mod q (Montgomery domain)
R_mod = 2285  # 2^16 mod q
c_sb_mont = [(x * R_mod) % q for x in c_sb]

# Reduce ref to [0, q-1] for comparison
c_ref_mod = [x % q for x in c_ref]

match_reg = all(c_ref_mod[i] == c_sb[i] for i in range(256))
print(f"poly_mul mod q == schoolbook mod q: {match_reg}")

# Also check without mod q reduction (signed vs unsigned)
match_signed = all(c_ref[i] % q == c_sb[i] for i in range(256))
print(f"poly_mul (signed) == schoolbook mod q: {match_signed}")

if not match_reg:
    mismatches = [(i, c_ref_mod[i], c_sb[i]) for i in range(256) if c_ref_mod[i] != c_sb[i]]
    print(f"  Mismatches: {len(mismatches)}, first 10: {mismatches[:10]}")

# Print first few
print(f"\n  ref (signed) first 5: {c_ref[:5]}")
print(f"  ref mod q first 5: {c_ref_mod[:5]}")
print(f"  sb  first 5: {c_sb[:5]}")

# Also verify NTT/INTT round-trip
print("\n=== NTT/INTT round-trip ===")
a_test = [random.randint(0, q - 1) for _ in range(256)]
a_ntt_ref = poly_ntt(a_test)
a_back_ref = invntt(a_ntt_ref)
a_back_mod = [x % q for x in a_back_ref]
a_expected = [(x * R_mod) % q for x in a_test]
match_rt = all(a_back_mod[i] == a_expected[i] for i in range(256))
print(f"invntt(poly_ntt(f)) == f * R mod q: {match_rt}")
if not match_rt:
    mismatches = [(i, a_back_mod[i], a_expected[i]) for i in range(256) if a_back_mod[i] != a_expected[i]]
    print(f"  Mismatches: {len(mismatches)}, first 5: {mismatches[:5]}")