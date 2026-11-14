# Exact C simulation of Kyber NTT with int16_t/int32_t arithmetic
# Fixed: barrett_reduce uses correct v=20159 constant from reference reduce.c

q = 3329
QINV = -3327  # q^{-1} mod 2^16
BARRETT_V = 20159  # ((1<<26) + q/2) / q = (67108864 + 1664) / 3329

def int16(x):
    x = x & 0xFFFF
    if x >= 32768:
        x -= 65536
    return x

def int32(x):
    x = x & 0xFFFFFFFF
    if x >= 2147483648:
        x -= 4294967296
    return x

def montgomery_reduce(a):
    """Exact C: int16_t montgomery_reduce(int32_t a)"""
    a = int32(a)
    t = int16(a) * QINV
    t = int16(t)
    t = int32(a - int32(t) * q)
    t = t >> 16
    return int16(t)

def fqmul(a, b):
    """Exact C: int16_t fqmul(int16_t a, int16_t b)"""
    return montgomery_reduce(int32(a) * int32(b))

def barrett_reduce(a):
    """Exact C: int16_t barrett_reduce(int16_t a) from reduce.c"""
    a = int16(a)
    # const int16_t v = ((1l<<26) + KYBER_Q/2)/KYBER_Q;  // v = 20159
    # t = ((int32_t)v*a + (1l<<25)) >> 26;
    t = int32(BARRETT_V * a + (1 << 25))
    t = t >> 26
    # t *= KYBER_Q;
    t = int16(t * q)
    # return a - t;
    return int16(a - t)

# Exact zetas from pq-crystals/kyber ref/ntt.c
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
    """Exact C: void ntt(int16_t r[256])"""
    k = 1
    length = 128
    while length >= 2:
        for start in range(0, 256, 2 * length):
            zeta = zetas[k]
            k += 1
            for j in range(start, start + length):
                t = fqmul(zeta, r[j + length])
                r[j + length] = int16(r[j] - t)
                r[j] = int16(r[j] + t)
        length >>= 1

def invntt(r):
    """Exact C: void invntt(int16_t r[256])"""
    k = 127
    length = 2
    while length <= 128:
        for start in range(0, 256, 2 * length):
            zeta = zetas[k]
            k -= 1
            for j in range(start, start + length):
                t = r[j]
                r[j] = barrett_reduce(t + r[j + length])
                r[j + length] = int16(r[j + length] - t)
                r[j + length] = fqmul(zeta, r[j + length])
        length <<= 1
    for j in range(256):
        r[j] = fqmul(r[j], 1441)

def basemul(r, idx, a, b, zeta):
    """Exact C: void basemul(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta)"""
    r[idx] = fqmul(a[idx+1], b[idx+1])
    r[idx] = fqmul(r[idx], zeta)
    r[idx] = int16(r[idx] + fqmul(a[idx], b[idx]))
    r[idx+1] = fqmul(a[idx], b[idx+1])
    r[idx+1] = int16(r[idx+1] + fqmul(a[idx+1], b[idx]))

def poly_basemul_montgomery(r, a, b):
    """Exact C: void poly_basemul_montgomery"""
    for i in range(64):
        z = zetas[64 + i]
        basemul(r, 4*i, a, b, z)
        basemul(r, 4*i+2, a, b, -z)

def poly_mul_ntt(a_reg, b_reg):
    """
    Polynomial multiplication using exact reference Kyber NTT.
    Inputs: regular domain [0, q-1]. Output: regular domain [0, q-1].
    """
    a = [int16(x) for x in a_reg]
    b = [int16(x) for x in b_reg]

    # poly_ntt: ntt + poly_reduce (barrett_reduce each)
    ntt(a)
    a = [barrett_reduce(x) for x in a]
    ntt(b)
    b = [barrett_reduce(x) for x in b]

    # poly_basemul_montgomery
    c = [0] * 256
    poly_basemul_montgomery(c, a, b)

    # poly_invntt_tomont: invntt
    invntt(c)

    # Convert from Montgomery domain to regular domain
    # After invntt, values are in Montgomery domain
    # x_reg = montgomery_reduce(x_mont) = fqmul(x, 1)
    result = []
    for x in c:
        x_reg = fqmul(x, 1)
        if x_reg < 0:
            x_reg += q
        result.append(x_reg)
    return result

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