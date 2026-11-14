"""
Python oracle that EXACTLY mirrors the RTL kyber_ntt.v arithmetic & control,
to establish what the RTL SHOULD compute (bug-free reference for diffing).
Forward: zetas[1..127] blockwise, int16 wrap butterflies, poly_reduce at end.
Inverse: zetas[127..1] blockwise, barrett in butterfly, scale by 1441.
"""
q = 3329
QINV = -3327

# Signed zetas (same as RTL get_zeta / kyber_ref_exact ZETAS)
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

def to_s16(x):
    x &= 0xFFFF
    return x - 65536 if x >= 32768 else x

def montgomery_reduce(a):
    # a is full int32 product
    t_low = (a & 0xFFFF) * 62209
    t_low = t_low & 0xFFFF
    t_signed = t_low - 65536 if (t_low & 0x8000) else t_low
    result = (a - t_signed * q) >> 16   # arithmetic shift
    return to_s16(result & 0xFFFF)

def fqmul(a, b):
    return montgomery_reduce(to_s16(a) * to_s16(b))

def barrett_reduce(a):
    a = to_s16(a)
    v = 20159
    t = (v * a + (1 << 25)) >> 26
    return to_s16(a - t * q)

def rtl_forward(coeff):
    coeff = [to_s16(x) for x in coeff]
    zeta_cnt = 1
    length = 128
    while length >= 2:
        nblocks = 128 // length
        for blk in range(nblocks):
            block_start = blk * (length << 1)
            zv = ZETAS[zeta_cnt]
            zeta_cnt += 1
            for j in range(length):
                aj = coeff[block_start + j]
                ajl = coeff[block_start + j + length]
                t = fqmul(zv, ajl)
                coeff[block_start + j] = to_s16(aj + t)        # int16 wrap
                coeff[block_start + j + length] = to_s16(aj - t)
        length >>= 1
    # poly_reduce
    coeff = [barrett_reduce(x) for x in coeff]
    return coeff

def rtl_inverse(coeff):
    coeff = [to_s16(x) for x in coeff]
    zeta_cnt = 127
    length = 2
    while length <= 128:
        nblocks = 128 // length
        for blk in range(nblocks):
            block_start = blk * (length << 1)
            zv = ZETAS[zeta_cnt]
            zeta_cnt -= 1
            for j in range(length):
                aj = coeff[block_start + j]
                ajl = coeff[block_start + j + length]
                coeff[block_start + j] = barrett_reduce(aj + ajl)
                coeff[block_start + j + length] = fqmul(zv, to_s16(ajl - aj))
        length <<= 1
    coeff = [fqmul(x, 1441) for x in coeff]
    return coeff

if __name__ == "__main__":
    # Test f[i] = i
    f = [i for i in range(256)]
    fwd = rtl_forward(f)
    rt = rtl_inverse(fwd)
    rt_mod = [((x % q) + q) % q for x in rt]
    exp = [(i * 2285) % q for i in range(256)]
    ok = all(rt_mod[i] == exp[i] for i in range(256))
    print("RTL-model forward(f[i]=i)[:8]:", fwd[:8])
    print("RTL-model round-trip OK:", ok)
    if not ok:
        mm = [(i, rt_mod[i], exp[i]) for i in range(256) if rt_mod[i] != exp[i]]
        print("  mismatches:", len(mm), mm[:5])
    # f[i] = i+1 forward
    f2 = [(i + 1) for i in range(256)]
    fwd2 = rtl_forward(f2)
    print("RTL-model forward(f[i]=i+1)[:8]:", fwd2[:8])
