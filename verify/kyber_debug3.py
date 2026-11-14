# Debug exact C simulation - check round-trip first
q = 3329
QINV = -3327

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
    a = int32(a)
    t = int16(a) * QINV
    t = int16(t)
    t = int32(a - int32(t) * q)
    t = t >> 16
    return int16(t)

def fqmul(a, b):
    return montgomery_reduce(int32(a) * int32(b))

def barrett_reduce(a):
    a = int16(a)
    t = int32(a) * 5040
    t = t >> 26
    a = int16(a - int32(t) * q)
    return a

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
                r[j + length] = int16(r[j] - t)
                r[j] = int16(r[j] + t)
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
                r[j + length] = int16(r[j + length] - t)
                r[j + length] = fqmul(zeta, r[j + length])
        length <<= 1
    for j in range(256):
        r[j] = fqmul(r[j], 1441)

# Test round-trip: start with regular domain, ntt, invntt, convert back
import random
random.seed(42)

for test in range(3):
    a_orig = [random.randint(0, q-1) for _ in range(256)]
    
    # Convert to int16_t (signed representation)
    a = [int16(x) for x in a_orig]
    
    # NTT
    ntt(a)
    # barrett_reduce after NTT (as in poly_ntt)
    a = [barrett_reduce(x) for x in a]
    
    # INTT
    invntt(a)
    
    # After invntt, values are in Montgomery domain
    # Convert to regular domain: x_reg = montgomery_reduce(x_mont) = fqmul(x, 1)
    a_back = [fqmul(x, 1) for x in a]
    
    # Convert to [0, q-1]
    a_back_pos = [x if x >= 0 else x + q for x in a_back]
    a_orig_pos = [x for x in a_orig]
    
    match = all(a_back_pos[i] == a_orig_pos[i] for i in range(256))
    print(f"Round-trip test {test}: {'PASS' if match else 'FAIL'}")
    if not match:
        mismatches = [(i, a_back_pos[i], a_orig_pos[i]) for i in range(256) if a_back_pos[i] != a_orig_pos[i]]
        print(f"  Mismatches: {len(mismatches)}, first: {mismatches[:5]}")
        print(f"  a_back[0:8]: {a_back_pos[:8]}")
        print(f"  a_orig[0:8]: {a_orig_pos[:8]}")
    
    # Also check: what if we DON'T do barrett_reduce after ntt?
    a2 = [int16(x) for x in a_orig]
    ntt(a2)
    # NO barrett_reduce
    invntt(a2)
    a2_back = [fqmul(x, 1) for x in a2]
    a2_back_pos = [x if x >= 0 else x + q for x in a2_back]
    match2 = all(a2_back_pos[i] == a_orig_pos[i] for i in range(256))
    print(f"  Without barrett after ntt: {'PASS' if match2 else 'FAIL'}")
    if not match2:
        mismatches2 = [(i, a2_back_pos[i], a_orig_pos[i]) for i in range(256) if a2_back_pos[i] != a_orig_pos[i]]
        print(f"    Mismatches: {len(mismatches2)}, first: {mismatches2[:5]}")