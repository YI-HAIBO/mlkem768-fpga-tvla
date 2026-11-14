"""Debug: trace zeta_cnt through the FSM"""
import random

q = 3329
QINV = 62209

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
    x = x & 0xFFFF
    if x >= 32768: x -= 65536
    return x

def montgomery_reduce(a):
    a = a & 0xFFFFFFFF
    t_low = (a & 0xFFFF) * QINV & 0xFFFF
    t_signed = t_low - 65536 if t_low >= 32768 else t_low
    result = (a - t_signed * q) >> 16
    return signed16(result)

def fqmul(a, b):
    prod = signed16(a) * signed16(b)
    return montgomery_reduce(prod)

def barrett_reduce(a):
    a_s = signed16(a)
    v_a = 20159 * a_s
    t = (v_a + 33554432) >> 26
    return signed16(a_s - t * 3329)

def modadd(a, b):
    s = signed16(a) + signed16(b)
    if s >= q: s -= q
    return s & 0xFFFF

def modsub(a, b):
    d = signed16(a) - signed16(b)
    if d < 0: d += q
    return d & 0xFFFF

S_IDLE=0; S_LAYER_SETUP=1; S_BUTTER=2; S_NEXT_BLOCK=3
S_NEXT_LAYER=4; S_REDUCE=5; S_SCALE=6; S_DONE=7

def ntl_fsm(coeff_in, inverse, debug=False):
    coeff = list(coeff_in)
    state = S_IDLE
    layer_idx = 0; block_cnt = 0; j_cnt = 0; length = 0
    zeta_cnt = 0; cnt = 0; inv_mode = inverse

    # Start
    busy = True
    if inverse:
        zeta_cnt = 127; length = 2
    else:
        zeta_cnt = 1; length = 128
    layer_idx = 0; block_cnt = 0; j_cnt = 0
    state = S_LAYER_SETUP

    cycle = 0
    max_cycles = 100000
    zeta_log = []

    while state != S_DONE and cycle < max_cycles:
        cycle += 1

        if state == S_LAYER_SETUP:
            if debug: print(f"  cyc{cycle}: LAYER_SETUP layer={layer_idx} len={length} block={block_cnt} zeta_cnt={zeta_cnt}")
            block_cnt = 0; j_cnt = 0
            state = S_BUTTER

        elif state == S_BUTTER:
            if j_cnt < length:
                block_start = block_cnt * (length << 1)
                if zeta_cnt < 0 or zeta_cnt >= 128:
                    if debug: print(f"  cyc{cycle}: BUTTER zeta_cnt={zeta_cnt} OUT OF RANGE!")
                    return coeff, cycle
                aj = coeff[block_start + j_cnt]
                ajl = coeff[block_start + j_cnt + length]
                zv = ZETAS[zeta_cnt]

                if inv_mode:
                    coeff[block_start + j_cnt] = barrett_reduce(aj + ajl)
                    coeff[block_start + j_cnt + length] = fqmul(zv, ajl - aj)
                else:
                    coeff[block_start + j_cnt] = modadd(aj, fqmul(zv, ajl))
                    coeff[block_start + j_cnt + length] = modsub(aj, fqmul(zv, ajl))

                j_cnt += 1
            else:
                state = S_NEXT_BLOCK

        elif state == S_NEXT_BLOCK:
            old_zeta = zeta_cnt
            if inv_mode: zeta_cnt -= 1
            else: zeta_cnt += 1
            if debug: print(f"  cyc{cycle}: NEXT_BLOCK layer={layer_idx} block={block_cnt} zeta {old_zeta}->{zeta_cnt} max_blocks={128//length}")

            if block_cnt + 1 < (128 // length):
                block_cnt += 1; j_cnt = 0
                state = S_LAYER_SETUP
            else:
                state = S_NEXT_LAYER

        elif state == S_NEXT_LAYER:
            if debug: print(f"  cyc{cycle}: NEXT_LAYER layer={layer_idx} len={length} inv={inv_mode}")
            if inv_mode:
                if layer_idx < 6:
                    layer_idx += 1; length <<= 1
                    block_cnt = 0; j_cnt = 0
                    state = S_LAYER_SETUP
                else:
                    cnt = 0; state = S_SCALE
            else:
                if layer_idx < 6:
                    layer_idx += 1; length >>= 1
                    block_cnt = 0; j_cnt = 0
                    state = S_LAYER_SETUP
                else:
                    cnt = 0; state = S_REDUCE

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

# Test with debug
a_test = [100, 200, 300] + [0]*253  # simple test
print("=== Forward NTT debug ===")
result, cycles = ntl_fsm(a_test, inverse=False, debug=True)
print(f"Cycles: {cycles}")
print(f"Result first 5: {result[:5]}")