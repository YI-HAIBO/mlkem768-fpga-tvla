# Test Kyber NTT reference algorithm for polynomial multiplication
# Fixed: basemul uses index-based access (Python slice bug fix)
# q = 3329, R = 2^16, R^{-1} mod q = 169

q = 3329
n = 256
RINV = 169   # R^{-1} mod q

def fqmul(a, b):
    """Montgomery multiply: (a * b * R^{-1}) mod q, result in [0, q-1]."""
    return (a * b * RINV) % q

def barrett_reduce(a):
    """Barrett reduction: a mod q, result in [0, q-1]."""
    return a % q

# EXACT zetas from pq-crystals/kyber ref/ntt.c (128 entries, SIGNED Montgomery form)
zetas = [
  -1044,  -758,  -359, -1517,  1493,  1422,   287,   202,
   -171,   622,  1577,   182,   962, -1202, -1474,  1468,
    573, -1325,   264,   383,  -829,  1458, -1602,  -130,
   -681,  1017,   732,   608, -1542,   411,  -205, -1571,
   1223,   652,  -552,  1015, -1293,  1491,  -282, -1544,
    516,    -8,  -320,  -666, -1618, -1162,   126,  1469,
   -853,   -90,  -271,   830,   107, -1421,  -247,  -951,
   -398,   961, -1508,  -725,   448, -1065,   677, -1275,
  -1103,   430,   555,   843, -1251,   871,  1550,   105,
    422,   587,   177,  -235,  -291,  -460,  1574,  1653,
   -246,   778,  1159,  -147,  -777,  1483,  -602,  1119,
  -1590,   644,  -872,   349,   418,   329,  -156,   -75,
    817,  1097,   603,   610,  1322, -1285, -1465,   384,
  -1215,  -136,  1218, -1335,  -874,   220, -1187, -1659,
  -1185, -1530, -1278,   794, -1510,  -854,  -870,   478,
   -108,  -308,   996,   991,   958, -1460,  1522,  1628
]

def ntt(r):
    """Forward NTT (exact reference algorithm)."""
    k = 1
    length = 128
    while length >= 2:
        for start in range(0, 256, 2 * length):
            zeta = zetas[k]
            k += 1
            for j in range(start, start + length):
                t = fqmul(zeta, r[j + length])
                r[j + length] = (r[j] - t) % q
                r[j] = (r[j] + t) % q
        length >>= 1

def invntt(r):
    """Inverse NTT (exact reference algorithm)."""
    k = 127
    length = 2
    while length <= 128:
        for start in range(0, 256, 2 * length):
            zeta = zetas[k]
            k -= 1
            for j in range(start, start + length):
                t = r[j]
                r[j] = barrett_reduce(t + r[j + length])
                r[j + length] = (r[j + length] - t) % q
                r[j + length] = fqmul(zeta, r[j + length])
        length <<= 1
    for j in range(256):
        r[j] = fqmul(r[j], 1441)

def basemul_idx(r, idx, a, b, zeta):
    """basemul: multiply two degree-1 polynomials in Zq[X]/(X^2 - zeta).
    r[idx], r[idx+1] = result; a[idx], a[idx+1] and b[idx], b[idx+1] = inputs.
    """
    a0, a1 = a[idx], a[idx+1]
    b0, b1 = b[idx], b[idx+1]

    t0 = fqmul(a1, b1)
    t0 = fqmul(t0, zeta)
    t0 = (t0 + fqmul(a0, b0)) % q
    r[idx] = t0

    t1 = fqmul(a0, b1)
    t1 = (t1 + fqmul(a1, b0)) % q
    r[idx+1] = t1

def poly_basemul_montgomery(r, a, b):
    """poly_basemul_montgomery: multiply two polynomials in NTT domain (reference)."""
    for i in range(64):
        z = zetas[64 + i]
        basemul_idx(r, 4*i, a, b, z)
        basemul_idx(r, 4*i+2, a, b, -z)

def poly_mul_ntt(a_reg, b_reg):
    """
    Polynomial multiplication using reference Kyber NTT (exact poly.c flow).
    Inputs: regular domain. Output: regular domain.
    """
    a = [x % q for x in a_reg]
    b = [x % q for x in b_reg]

    # poly_ntt: ntt
    ntt(a)
    ntt(b)

    # poly_basemul_montgomery
    c = [0] * 256
    poly_basemul_montgomery(c, a, b)

    # poly_invntt_tomont: invntt
    invntt(c)

    # Convert from Montgomery to regular domain
    return [fqmul(x, 1) for x in c]

def poly_mul_direct(a, b):
    """Direct O(n^2) polynomial multiplication (regular domain)."""
    result = [0] * 256
    for i in range(256):
        for j in range(256 - i):
            result[i + j] = (result[i + j] + a[i] * b[j]) % q
    return result

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