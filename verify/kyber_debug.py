# Debug Kyber NTT step by step
q = 3329
RINV = 169

def fqmul(a, b):
    return (a * b * RINV) % q

def barrett_reduce(a):
    return a % q

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

# Test with a simple input: all zeros except a[0]=1
a = [0] * 256
a[0] = 1
b = [0] * 256
b[0] = 1

print("Input a[0:8]:", a[:8])
print("Input b[0:8]:", b[:8])

# NTT
def ntt(r):
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

ntt(a)
print("After ntt(a)[0:8]:", a[:8])
print("After ntt(a) non-zero count:", sum(1 for x in a if x != 0))

# Check if ntt of [1,0,0,...] gives all 1's (since NTT of delta function should be all 1's)
# Actually for the standard NTT, NTT([1,0,...,0]) = [1,1,...,1]
# But for the Kyber NTT with Montgomery arithmetic, it might be different
print("Expected: all entries should be non-zero for delta input")

# Now test with random input
import random
random.seed(42)
a2 = [random.randint(0, q-1) for _ in range(256)]
b2 = [random.randint(0, q-1) for _ in range(256)]

a_copy = a2[:]
ntt(a_copy)
print("\nRandom input after ntt:")
print("  a_copy[0:8]:", a_copy[:8])
print("  non-zero count:", sum(1 for x in a_copy if x != 0))
print("  min:", min(a_copy), "max:", max(a_copy))

# Now test the full poly_mul
def invntt(r):
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

def basemul(r, a, b, zeta):
    t0 = fqmul(a[1], b[1])
    t0 = fqmul(t0, zeta)
    t0 = (t0 + fqmul(a[0], b[0])) % q
    r[0] = t0
    t1 = fqmul(a[0], b[1])
    t1 = (t1 + fqmul(a[1], b[0])) % q
    r[1] = t1

def poly_basemul_montgomery(r, a, b):
    for i in range(64):
        z = zetas[64 + i]
        basemul(r[4*i:4*i+2], a[4*i:4*i+2], b[4*i:4*i+2], z)
        basemul(r[4*i+2:4*i+4], a[4*i+2:4*i+4], b[4*i+2:4*i+4], -z)

# Test round-trip: ntt then invntt
a3 = a2[:]
ntt(a3)
invntt(a3)
# After invntt, the result should be in Montgomery domain
# Convert back: fqmul(x, 1) = x * R^{-1}
a3_back = [fqmul(x, 1) for x in a3]
print("\nRound-trip test:")
print("  Original[0:8]:", a2[:8])
print("  After invntt[0:8] (Montgomery):", a3[:8])
print("  After from_mont[0:8]:", a3_back[:8])
match = all(a3_back[i] == a2[i] for i in range(256))
print(f"  Round-trip match: {match}")

if not match:
    mismatches = [(i, a3_back[i], a2[i]) for i in range(256) if a3_back[i] != a2[i]]
    print(f"  Mismatches: {len(mismatches)}, first: {mismatches[:5]}")