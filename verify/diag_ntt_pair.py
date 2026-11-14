#!/usr/bin/env python3
"""diag_ntt_pair.py -- localise the 128/256 basemul mismatch: are the correct
coefficients the even (r[0]) or odd (r[1]) outputs, and what zeta would make
r[0] correct?  Throwaway diagnostic.
"""
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
P = os.path.join(HERE, "gen_ntt_vectors.py")
spec = importlib.util.spec_from_file_location("g", P)
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

Q, N = g.Q, g.N


def i16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


def u16(x):
    return i16(x) & 0xFFFF


def schoolbook(a, b):
    ar = [i16(v) % Q for v in a]
    br = [i16(v) % Q for v in b]
    return [(sum(ar[i - j] * br[j] if i >= j else -ar[i - j + N] * br[j]
                 for j in range(N))) % Q for i in range(N)]


rng = g._mulberry32(0xBEEF)
zetas = g.parse_rtl_zetas()
a = [i16(rng() % 32768 - 16384) for _ in range(N)]
b = [i16(rng() % 32768 - 16384) for _ in range(N)]
xa, xb = g.ntt(a, zetas), g.ntt(b, zetas)

# basemul with zeta = -1, as ref/ntt.c poly_basemul_montgomery uses
out = [0] * N
for k in range(128):
    r0 = g.fqmul(xa[2 * k + 1], xb[2 * k + 1])
    r0 = g.fqmul(r0, -1)
    r0 = i16(r0 + g.fqmul(xa[2 * k], xb[2 * k]))
    r1 = i16(g.fqmul(xa[2 * k], xb[2 * k + 1]) + g.fqmul(xa[2 * k + 1], xb[2 * k]))
    out[2 * k], out[2 * k + 1] = r0, r1
got = [i16(u16(v)) % Q for v in g.invntt(out, zetas)]
want = schoolbook(a, b)

even_hit = sum(1 for k in range(128) if got[2 * k] == want[2 * k])
odd_hit = sum(1 for k in range(128) if got[2 * k + 1] == want[2 * k + 1])
print("zeta=-1 : even(r[0]) hits = %d/128   odd(r[1]) hits = %d/128"
      % (even_hit, odd_hit))

# Now solve for the zeta that makes r[0] correct, on the first few pairs.
# r[0] = a1*b1*zeta*R^-2 + a0*b0*R^-1  ;  want r[0] == (a0b0 - a1b1)*R^-1
print()
print("per-pair required zeta (from the r[0] equation):")
count = {}
for k in range(128):
    r0c = g.fqmul(xa[2 * k + 1], xb[2 * k + 1])     # A1B1 R^-1
    r0v = i16(r0c + g.fqmul(xa[2 * k], xb[2 * k]))  # + A0B0 R^-1
    diff = i16(g.fqmul(xa[2 * k + 1], xb[2 * k + 1]))  # A1B1 R^-1
    if diff % Q == 0:
        continue
    need = i16(r0v - 2 * diff)  # placeholder
    # solve: fqmul(fqmul(A1B1, z), -?) -- instead just brute force z
    zbest = None
    for zc in range(0, Q):
        v = g.fqmul(diff, zc)
        if i16(v + g.fqmul(xa[2 * k], xb[2 * k])) % Q == want[2 * k]:
            zbest = zc
            break
    count[zbest] = count.get(zbest, 0) + 1
print("  zeta value : number of pairs it satisfies")
for zc, c in sorted(count.items(), key=lambda t: -t[1])[:6]:
    print("    %-6s : %d" % (zc, c))
