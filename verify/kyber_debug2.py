# Debug basemul step by step
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

# Test with simple polynomials: a = [1, 0, 0, ...], b = [1, 0, 0, ...]
# Expected result: c = [1, 0, 0, ...] (since 1*1 = 1)
a = [0] * 256
a[0] = 1
b = [0] * 256
b[0] = 1

print("=== Test 1: a=[1,0,...], b=[1,0,...] ===")
print(f"a[0:4] = {a[:4]}")
print(f"b[0:4] = {b[:4]}")

# NTT
ntt(a)
ntt(b)
print(f"After NTT, a[0:8] = {a[:8]}")
print(f"After NTT, b[0:8] = {b[:8]}")

# basemul for first pair (i=0)
z = zetas[64]
print(f"\nbasemul i=0: zeta = {z}")
print(f"  a[0:2] = {a[0:2]}, b[0:2] = {b[0:2]}")
print(f"  fqmul(a[1], b[1]) = fqmul({a[1]}, {b[1]}) = {fqmul(a[1], b[1])}")
print(f"  fqmul(fqmul(a[1],b[1]), zeta) = fqmul({fqmul(a[1], b[1])}, {z}) = {fqmul(fqmul(a[1], b[1]), z)}")
print(f"  fqmul(a[0], b[0]) = fqmul({a[0]}, {b[0]}) = {fqmul(a[0], b[0])}")

# Do basemul manually
r0 = [0, 0]
basemul(r0, a[0:2], b[0:2], z)
print(f"  basemul result: {r0}")

# Full poly_basemul_montgomery
c = [0] * 256
for i in range(64):
    z = zetas[64 + i]
    basemul(c[4*i:4*i+2], a[4*i:4*i+2], b[4*i:4*i+2], z)
    basemul(c[4*i+2:4*i+4], a[4*i+2:4*i+4], b[4*i+2:4*i+4], -z)

print(f"\nAfter basemul, c[0:8] = {c[:8]}")
print(f"c non-zero count: {sum(1 for x in c if x != 0)}")

# Inverse NTT
invntt(c)
print(f"\nAfter invntt, c[0:8] = {c[:8]}")
print(f"c non-zero count: {sum(1 for x in c if x != 0)}")

# Convert from Montgomery
c_reg = [fqmul(x, 1) for x in c]
print(f"After from_mont, c[0:8] = {c_reg[:8]}")
print(f"Expected: [1, 0, 0, ...]")

# Now test with random polynomials
print("\n=== Test 2: Random polynomials ===")
import random
random.seed(42)
a2 = [random.randint(0, q-1) for _ in range(256)]
b2 = [random.randint(0, q-1) for _ in range(256)]

# Direct multiplication
def poly_mul_direct(a, b):
    result = [0] * 256
    for i in range(256):
        for j in range(256 - i):
            result[i + j] = (result[i + j] + a[i] * b[j]) % q
    return result

c_direct = poly_mul_direct(a2, b2)
print(f"Direct result[0:8] = {c_direct[:8]}")

# NTT-based
a_ntt = a2[:]
b_ntt = b2[:]
ntt(a_ntt)
ntt(b_ntt)

c_ntt = [0] * 256
for i in range(64):
    z = zetas[64 + i]
    basemul(c_ntt[4*i:4*i+2], a_ntt[4*i:4*i+2], b_ntt[4*i:4*i+2], z)
    basemul(c_ntt[4*i+2:4*i+4], a_ntt[4*i+2:4*i+4], b_ntt[4*i+2:4*i+4], -z)

print(f"After basemul, c_ntt[0:8] = {c_ntt[:8]}")
print(f"c_ntt non-zero count: {sum(1 for x in c_ntt if x != 0)}")

invntt(c_ntt)
c_ntt_reg = [fqmul(x, 1) for x in c_ntt]
print(f"After invntt + from_mont, c_ntt[0:8] = {c_ntt_reg[:8]}")

match = all(c_ntt_reg[i] == c_direct[i] for i in range(256))
print(f"Match: {match}")
if not match:
    mismatches = [(i, c_ntt_reg[i], c_direct[i]) for i in range(256) if c_ntt_reg[i] != c_direct[i]]
    print(f"Mismatches: {len(mismatches)}, first: {mismatches[:5]}")