#!/usr/bin/env python3
"""diag_ntt_ring.py -- test the defining property of the Kyber NTT: it must
diagonalise multiplication in Rq = Zq[X]/(X^256+1).  Fully independent of any
assumption about roots, tables or orderings.

  schoolbook(a, b)          must equal  invntt( basemul(ntt(a), ntt(b)) )

`basemul` is ported verbatim from ref/ntt.c.  The only free parameter is the
`zeta` argument, which is swept empirically.
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
    """Exact polynomial product in Rq = Zq[X]/(X^256+1), coefficients mod q."""
    ar = [i16(v) % Q for v in a]
    br = [i16(v) % Q for v in b]
    out = []
    for i in range(N):
        s = 0
        for j in range(N):
            if (i - j) % N == i - j:
                s += ar[i - j] * br[j]
            else:                      # X^(i-j+N) = -X^(i-j) in the ring
                s -= ar[i - j + N] * br[j]
        out.append(s % Q)
    return out


def basemul(a0, a1, b0, b1, zeta):
    """Verbatim port of ref/ntt.c basemul()."""
    r0 = g.fqmul(a1, b1)
    r0 = g.fqmul(r0, zeta)
    r0 = i16(r0 + g.fqmul(a0, b0))
    r1 = i16(g.fqmul(a0, b1) + g.fqmul(a1, b0))
    return r0, r1


def poly_basemul(A, B, zeta):
    out = [0] * N
    for k in range(128):
        out[2 * k], out[2 * k + 1] = basemul(A[2 * k], A[2 * k + 1],
                                              B[2 * k], B[2 * k + 1], zeta)
    return out


rng = g._mulberry32(0xBEEF)
zetas = g.parse_rtl_zetas()
fails = 0
for trial in range(4):
    a = [i16(rng() % 32768 - 16384) for _ in range(N)]
    b = [i16(rng() % 32768 - 16384) for _ in range(N)]
    xa = g.ntt(a, zetas)
    xb = g.ntt(b, zetas)
    prod = poly_basemul(xa, xb, -1)          # ref uses zeta = -1
    got = [i16(u16(v)) % Q for v in g.invntt(prod, zetas)]
    want = schoolbook(a, b)
    hit = sum(1 for i in range(N) if got[i] == want[i])
    print("trial %d  exact hits = %d / %d" % (trial, hit, N))
    if hit < N:
        fails += 1

print()
print("zeta sweep (which zeta makes invntt(basemul(ntt(a),ntt(b))) == a*b?):")
zbest = None
for zcand in (-1, 1, -g.R_MOD_Q, g.R_MOD_Q, Q - g.R_MOD_Q, pow(17, 2, Q),
              pow(17, 4, Q), Q - 1):
    ok = 0
    for trial in range(3):
        a = [i16(rng() % 32768 - 16384) for _ in range(N)]
        b = [i16(rng() % 32768 - 16384) for _ in range(N)]
        xa, xb = g.ntt(a, zetas), g.ntt(b, zetas)
        prod = poly_basemul(xa, xb, zcand)
        got = [i16(u16(v)) % Q for v in g.invntt(prod, zetas)]
        want = schoolbook(a, b)
        ok += sum(1 for i in range(N) if got[i] == want[i])
    print("  zeta=%-8d  hits=%d / %d" % (i16(zcand), ok, 3 * N))
    if ok == 3 * N:
        zbest = zcand

print()
print("constant round-trip scale  invntt(ntt(x)) = c * x mod q:")
for trial in range(3):
    a = [i16(rng() % 32768 - 16384) for _ in range(N)]
    got = [i16(u16(v)) % Q for v in g.invntt(g.ntt(a, zetas), zetas)]
    xr = [i16(v) % Q for v in a]
    for i in range(N):
        if xr[i]:
            c = got[i] * pow(xr[i], -1, Q) % Q
            break
    ok = sum(1 for i in range(N) if got[i] == c * xr[i] % Q)
    print("  trial %d  c=%-6d  hits=%d / %d" % (trial, c, ok, N))
