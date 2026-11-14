"""
Cycle-accurate Python simulation of kyber_ntt.v FSM.
Verifies that the RTL FSM produces the same result as the reference algorithm.
"""
import random

q = 3329
QINV = 62209  # q^{-1} mod 2^16

# Reference zetas (unsigned)
ZETAS = [
    2285, 2571, 2970, 1812, 1493, 1422, 287, 202,
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

def signed16(x):
    """Convert to signed 16-bit"""
    x = x & 0xFFFF
    if x >= 32768:
        x -= 65536
    return x

def montgomery_reduce(a):
    """Simulate Verilog montgomery_reduce"""
    a = a & 0xFFFFFFFF
    t_low = (a & 0xFFFF) * QINV & 0xFFFF
    # Sign extend
    if t_low >= 32768:
        t_signed = t_low - 65536
    else:
        t_signed = t_low
    # result = (a - t_signed * q) >>> 16 (arithmetic)
    result = (a - t_signed * q) >> 16  # Python >> is arithmetic for negative
    return signed16(result)

def fqmul(a, b):
    """Simulate Verilog fqmul"""
    prod = signed16(a) * signed16(b)
    return montgomery_reduce(prod)

def barrett_reduce(a):
    """Simulate Verilog barrett_reduce"""
    a_s = signed16(a)
    v_a = 20159 * a_s
    t = (v_a + 33554432) >> 26
    result = a_s - t * 3329
    return signed16(result)

def modadd(a, b):
    """Simulate Verilog modadd"""
    s = signed16(a) + signed16(b)
    if s >= q:
        s -= q
    return s & 0xFFFF

def modsub(a, b):
    """Simulate Verilog modsub"""
    d = signed16(a) - signed16(b)
    if d < 0:
        d += q
    return d & 0xFFFF

def ntl_fsm(coeff_in, inverse):
    """
    Simulate the kyber_ntt.v FSM cycle by cycle.
    Returns the final coefficient array.
    """
    coeff = list(coeff_in)

    # FSM state
    S_IDLE = 0; S_LAYER_SETUP = 1; S_BUTTER = 2; S_NEXT_BLOCK = 3
    S_NEXT_LAYER = 4; S_REDUCE = 5; S_SCALE = 6; S_DONE = 7

    state = S_IDLE
    busy = False
    done = False
    layer_idx = 0
    block_cnt = 0
    j_cnt = 0
    length = 0
    zeta_cnt = 0
    cnt = 0
    inv_mode = inverse

    # Start the FSM
    # In S_IDLE, when start is asserted:
    busy = True
    if inverse:
        zeta_cnt = 127
        length = 2
    else:
        zeta_cnt = 1
        length = 128
    layer_idx = 0
    block_cnt = 0
    j_cnt = 0
    state = S_LAYER_SETUP

    cycle = 0
    max_cycles = 100000

    while state != S_DONE and cycle < max_cycles:
        cycle += 1

        if state == S_LAYER_SETUP:
            # Only reset j_cnt; block_cnt is already set
            j_cnt = 0
            state = S_BUTTER

        elif state == S_BUTTER:
            if j_cnt < length:
                block_start = block_cnt * (length << 1)
                aj = coeff[block_start + j_cnt]
                ajl = coeff[block_start + j_cnt + length]
                zv = ZETAS[zeta_cnt]

                if inv_mode:
                    # Inverse butterfly
                    coeff[block_start + j_cnt] = barrett_reduce(aj + ajl)
                    coeff[block_start + j_cnt + length] = fqmul(zv, ajl - aj)
                else:
                    # Forward butterfly
                    coeff[block_start + j_cnt] = modadd(aj, fqmul(zv, ajl))
                    coeff[block_start + j_cnt + length] = modsub(aj, fqmul(zv, ajl))

                j_cnt += 1
            else:
                state = S_NEXT_BLOCK

        elif state == S_NEXT_BLOCK:
            # Increment zeta_cnt for the block just processed
            if inv_mode:
                zeta_cnt -= 1
            else:
                zeta_cnt += 1

            if block_cnt + 1 < (128 // length):
                block_cnt += 1
                j_cnt = 0
                state = S_LAYER_SETUP
            else:
                state = S_NEXT_LAYER

        elif state == S_NEXT_LAYER:
            if inv_mode:
                if layer_idx < 6:
                    layer_idx += 1
                    length <<= 1
                    block_cnt = 0
                    j_cnt = 0
                    state = S_LAYER_SETUP
                else:
                    cnt = 0
                    state = S_SCALE
            else:
                if layer_idx < 6:
                    layer_idx += 1
                    length >>= 1
                    block_cnt = 0
                    j_cnt = 0
                    state = S_LAYER_SETUP
                else:
                    cnt = 0
                    state = S_REDUCE

        elif state == S_REDUCE:
            if cnt < 256:
                coeff[cnt] = barrett_reduce(coeff[cnt])
                cnt += 1
            else:
                state = S_DONE

        elif state == S_SCALE:
            if cnt < 256:
                coeff[cnt] = fqmul(coeff[cnt], 1441)
                cnt += 1
            else:
                state = S_DONE

    return coeff, cycle

# Reference implementation for comparison
def ref_ntt(a, inverse):
    """Reference pq-crystals/kyber NTT/INTT"""
    a = list(a)
    if not inverse:
        # Forward NTT
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
                start = j + length + 1
            length >>= 1
        # poly_reduce
        a = [barrett_reduce(x) for x in a]
    else:
        # Inverse NTT
        k = 127
        length = 2
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
        # Final scaling
        for j in range(256):
            a[j] = fqmul(a[j], 1441)
    return a

# Test
random.seed(42)

print("=== Forward NTT test ===")
a_test = [random.randint(0, q-1) for _ in range(256)]
a_orig = a_test[:]

fsm_result, cycles = ntl_fsm(a_test, inverse=False)
ref_result = ref_ntt(a_orig, inverse=False)

# Compare (both in signed representation)
match = all(signed16(fsm_result[i]) == signed16(ref_result[i]) for i in range(256))
print(f"Forward NTT match: {match} (cycles: {cycles})")
if not match:
    mismatches = [(i, signed16(fsm_result[i]), signed16(ref_result[i])) for i in range(256) if signed16(fsm_result[i]) != signed16(ref_result[i])]
    print(f"  Mismatches: {len(mismatches)}, first 10: {mismatches[:10]}")

print("\n=== Inverse NTT test ===")
# First do forward NTT, then inverse
a_ntt = ref_ntt(a_orig, inverse=False)
fsm_inv, cycles_inv = ntl_fsm(a_ntt, inverse=True)
ref_inv = ref_ntt(a_ntt, inverse=True)

match_inv = all(signed16(fsm_inv[i]) == signed16(ref_inv[i]) for i in range(256))
print(f"Inverse NTT match: {match_inv} (cycles: {cycles_inv})")
if not match_inv:
    mismatches = [(i, signed16(fsm_inv[i]), signed16(ref_inv[i])) for i in range(256) if signed16(fsm_inv[i]) != signed16(ref_inv[i])]
    print(f"  Mismatches: {len(mismatches)}, first 10: {mismatches[:10]}")

# Check round-trip: invntt(ntt(f)) should equal f * R mod q
R = 2285
expected_rt = [(x * R) % q for x in a_orig]
# ref_inv is in signed representation, convert to unsigned mod q
ref_inv_mod = [x % q for x in ref_inv]
match_rt = all(ref_inv_mod[i] == expected_rt[i] for i in range(256))
print(f"\nRound-trip invntt(ntt(f)) == f * R mod q: {match_rt}")

# Also check FSM round-trip
fsm_inv_mod = [x % q for x in fsm_inv]
match_rt_fsm = all(fsm_inv_mod[i] == expected_rt[i] for i in range(256))
print(f"FSM round-trip invntt(ntt(f)) == f * R mod q: {match_rt_fsm}")

print("\n=== Full poly_mul test (forward → basemul → inverse) ===")
# This requires basemul, which is in a separate module.
# But we can test: invntt(ntt(a) ⊙ ntt(b)) should equal schoolbook(a,b)
b_test = [random.randint(0, q-1) for _ in range(256)]

# Reference poly_mul
a_ntt_ref = ref_ntt(a_orig, inverse=False)
b_ntt_ref = ref_ntt(b_test, inverse=False)

# Basemul (same as reference)
def basemul_full(a, b):
    r = [0] * 256
    for i in range(64):
        zeta = ZETAS[64 + i]
        # Pair (4i, 4i+1) with zeta
        a0, a1 = a[4*i], a[4*i+1]
        b0, b1 = b[4*i], b[4*i+1]
        r0 = fqmul(a1, b1)
        r0 = fqmul(r0, zeta)
        r0 += fqmul(a0, b0)
        r1 = fqmul(a0, b1)
        r1 += fqmul(a1, b0)
        r[4*i] = r0
        r[4*i+1] = r1
        # Pair (4i+2, 4i+3) with -zeta
        a0, a1 = a[4*i+2], a[4*i+3]
        b0, b1 = b[4*i+2], b[4*i+3]
        zeta_neg = q - zeta  # -zeta mod q
        r0 = fqmul(a1, b1)
        r0 = fqmul(r0, zeta_neg)
        r0 += fqmul(a0, b0)
        r1 = fqmul(a0, b1)
        r1 += fqmul(a1, b0)
        r[4*i+2] = r0
        r[4*i+3] = r1
    return r

c_ntt_ref = basemul_full(a_ntt_ref, b_ntt_ref)
c_ref = ref_ntt(c_ntt_ref, inverse=True)

# Schoolbook
def schoolbook(a, b):
    n = 256
    c = [0] * (2 * n)
    for i in range(n):
        for j in range(n):
            c[i + j] += a[i] * b[j]
    result = [0] * n
    for k in range(n):
        result[k] = c[k] - c[k + n]
    return [x % q for x in result]

c_sb = schoolbook(a_orig, b_test)

match_mul = all(c_ref[i] % q == c_sb[i] for i in range(256))
print(f"Reference poly_mul == schoolbook: {match_mul}")

# Now test with FSM NTT
a_ntt_fsm, _ = ntl_fsm(a_orig, inverse=False)
b_ntt_fsm, _ = ntl_fsm(b_test, inverse=False)
c_ntt_fsm = basemul_full(a_ntt_fsm, b_ntt_fsm)
c_fsm, _ = ntl_fsm(c_ntt_fsm, inverse=True)

match_mul_fsm = all(c_fsm[i] % q == c_sb[i] for i in range(256))
print(f"FSM poly_mul == schoolbook: {match_mul_fsm}")

if not match_mul_fsm:
    mismatches = [(i, c_fsm[i] % q, c_sb[i]) for i in range(256) if c_fsm[i] % q != c_sb[i]]
    print(f"  Mismatches: {len(mismatches)}, first 10: {mismatches[:10]}")