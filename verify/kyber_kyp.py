# Kyber NTT using kyber-py approach (mathematical Montgomery, no int16_t simulation)
# Fixed: use NEGACYCLIC convolution for direct multiplication (Kyber ring is Zq[X]/(X^256 + 1))

q = 3329
RINV = 169  # R^{-1} mod q
MONT_R2 = 1353  # R^2 mod q
F = 1441

# kyber-py zetas (UNSIGNED, in [0, q-1], Montgomery domain)
zetas = [2285, 2571, 2970, 1812, 1493, 1422, 287, 202, 3158, 622, 1577, 182, 962, 2127, 1855, 1468,
         573, 2004, 264, 383, 2500, 1458, 1727, 3199, 2648, 1017, 732, 608, 1787, 411, 3124, 1758,
         1223, 652, 2777, 1015, 2036, 1491, 3047, 1785, 516, 3321, 3009, 2663, 1711, 2167, 126, 1469,
         2476, 3239, 3058, 830, 107, 1908, 3082, 2378, 2931, 961, 1821, 2604, 448, 2264, 677, 2054,
         2226, 430, 555, 843, 2078, 871, 1550, 105, 422, 587, 177, 3094, 3038, 2869, 1574, 1653, 3083,
         778, 1159, 3182, 2552, 1483, 2727, 1119, 1739, 644, 2457, 349, 418, 329, 3173, 3254, 817,
         1097, 603, 610, 1322, 2044, 1864, 384, 2114, 3193, 1218, 1994, 2455, 220, 2142, 1670, 2144,
         1799, 2051, 794, 1819, 2475, 2459, 478, 3221, 3021, 996, 991, 958, 1869, 1522, 1628]

def ntt_mul(a, b):
    """Montgomery multiply: (a * b * R^{-1}) mod q"""
    return (a * b * RINV) % q

def reduce_mod_q(a):
    """a mod q"""
    return a % q

def to_ntt(coeffs):
    """Forward NTT (kyber-py style)."""
    k, l = 1, 128
    while l >= 2:
        start = 0
        while start < 256:
            zeta = zetas[k]
            k = k + 1
            for j in range(start, start + l):
                t = ntt_mul(zeta, coeffs[j+l])
                coeffs[j+l] = coeffs[j] - t
                coeffs[j]   = coeffs[j] + t
            start = l + (j + 1)
        l = l >> 1
    return coeffs

def from_ntt(coeffs):
    """Inverse NTT (kyber-py style)."""
    l, l_upper = 2, 128
    k = l_upper - 1
    while l <= 128:
        start = 0
        while start < 256:
            zeta = zetas[k]
            k = k - 1
            for j in range(start, start+l):
                t = coeffs[j]
                coeffs[j]   = reduce_mod_q(t + coeffs[j+l])
                coeffs[j+l] = coeffs[j+l] - t
                coeffs[j+l] = ntt_mul(zeta, coeffs[j+l])
            start = j + l + 1
        l = l << 1
    for j in range(256):
        coeffs[j] = ntt_mul(coeffs[j], F)
    return coeffs

def ntt_base_multiplication(a0, a1, b0, b1, zeta):
    """basemul (kyber-py style)."""
    r0  = ntt_mul(a1, b1)
    r0  = ntt_mul(r0, zeta)
    r0 += ntt_mul(a0, b0)
    r1  = ntt_mul(a0, b1)
    r1 += ntt_mul(a1, b0)
    return r0, r1

def ntt_coefficient_multiplication(f_coeffs, g_coeffs):
    """poly_basemul_montgomery (kyber-py style)."""
    new_coeffs = []
    for i in range(64):
        r0, r1 = ntt_base_multiplication(
                            f_coeffs[4*i+0], f_coeffs[4*i+1],
                            g_coeffs[4*i+0], g_coeffs[4*i+1],
                            zetas[64+i])
        r2, r3 = ntt_base_multiplication(
                            f_coeffs[4*i+2], f_coeffs[4*i+3],
                            g_coeffs[4*i+2], g_coeffs[4*i+3],
                            -zetas[64+i])
        new_coeffs += [r0, r1, r2, r3]
    return new_coeffs

def from_montgomery(coeffs):
    """Convert Montgomery domain to regular domain."""
    return [ntt_mul(c, 1) for c in coeffs]

def poly_mul_ntt(a_reg, b_reg):
    """
    Polynomial multiplication in Zq[X]/(X^256 + 1) using NTT.
    Inputs: regular domain. Output: regular domain.
    """
    a = a_reg[:]
    b = b_reg[:]
    to_ntt(a)
    to_ntt(b)
    c = ntt_coefficient_multiplication(a, b)
    from_ntt(c)
    return from_montgomery(c)

def poly_mul_direct(a, b):
    """Direct negacyclic convolution: multiplication in Zq[X]/(X^256 + 1)."""
    n = 256
    result = [0] * n
    for i in range(n):
        for j in range(0, n - i):
            result[i + j] += a[i] * b[j]
        for j in range(n - i, n):
            result[i + j - n] -= a[i] * b[j]
    return [c % q for c in result]

# Test
import random
random.seed(42)

all_pass = True
for test in range(10):
    a = [random.randint(0, q-1) for _ in range(256)]
    b = [random.randint(0, q-1) for _ in range(256)]

    c_ntt = poly_mul_ntt(a, b)
    c_direct = poly_mul_direct(a, b)

    if c_ntt != c_direct:
        mismatches = [(i, c_ntt[i], c_direct[i]) for i in range(256) if c_ntt[i] != c_direct[i]]
        print(f"Poly mul FAIL at test {test}: {len(mismatches)} mismatches, first: {mismatches[:5]}")
        all_pass = False
    else:
        print(f"Poly mul PASS at test {test}")

if all_pass:
    print("\n=== ALL TESTS PASSED ===")
else:
    print("\n=== SOME TESTS FAILED ===")