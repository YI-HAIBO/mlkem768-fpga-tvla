#!/usr/bin/env python3
"""diag_ntt_struct.py -- convention-free structural checks on the ported
reference NTT.  Any genuine linear transform over a product decomposition of
Zq[X]/(X^256+1) must satisfy these; no knowledge of roots or tables needed.

  A. ntt(e_0) is constant   (a constant polynomial evaluates to itself)
  B. linearity: ntt(a + c*b) == ntt(a) + c*ntt(b)      (mod q, c in Zq)
  C. ntt is injective on a sample (distinct inputs -> distinct outputs)
  D. invntt is the exact inverse up to the documented Montgomery factor R
"""
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
P = os.path.join(HERE, "gen_ntt_vectors.py")
spec = importlib.util.spec_from_file_location("g", P)
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

Q, N = g.Q, g.N
MONT = g.R_MOD_Q


def i16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


def u16(x):
    return i16(x) & 0xFFFF


def val(v):
    """Coefficient of a transformed value, reduced into [0, q)."""
    return i16(u16(v)) % Q


rng = g._mulberry32(0xBEEF)
zetas = g.parse_rtl_zetas()
ok = True

print("A. ntt(e_0) must be a constant vector")
for c in range(5):
    e = [0] * N
    e[0] = (c + 1) * 1000
    y = [val(v) for v in g.ntt(e, zetas)]
    distinct = len(set(y))
    print("    e_0 = %-6d  distinct output values = %d  (want 1)" % (e[0], distinct))
    if distinct != 1:
        ok = False

print()
print("B. ntt(e_j) must be a geometric sequence  y[i] = y[0] * r^i")
for j in (0, 1, 2, 3, 4, 128, 255):
    e = [0] * N
    e[j] = 1
    y = [val(v) for v in g.ntt(e, zetas)]
    # find the common ratio on the first few entries
    ratios = set()
    for i in range(1, 24):
        if y[i - 1]:
            ratios.add(y[i] * pow(y[i - 1], -1, Q) % Q)
    print("    j=%-4d y[0]=%-5d  distinct ratios over i=1..23 : %d"
          % (j, y[0], len(ratios)))
    if len(ratios) > 1:
        ok = False
        print("      -> NOT geometric, ratios:", sorted(ratios)[:6])

print()
print("C. linearity  ntt(a + c*b) == ntt(a) + c*ntt(b)   mod q")
bad = 0
for _ in range(5):
    a = [i16(rng() % 32768 - 16384) for _ in range(N)]
    b = [i16(rng() % 32768 - 16384) for _ in range(N)]
    c = rng() % (Q - 1) + 1
    lhs = [val(v) for v in g.ntt([(a[k] + c * b[k]) % Q for k in range(N)], zetas)]
    ya = [val(v) for v in g.ntt(a, zetas)]
    yb = [val(v) for v in g.ntt(b, zetas)]
    for k in range(N):
        if lhs[k] != (ya[k] + c * yb[k]) % Q:
            bad += 1
print("    mismatched coefficients over 5 trials x 256 = %d / 1280" % bad)
if bad:
    ok = False

print()
print("D. injectivity (12 random inputs must give 12 distinct NTT images)")
imgs = []
for _ in range(12):
    a = [i16(rng() % 32768 - 16384) for _ in range(N)]
    imgs.append(tuple(val(v) for v in g.ntt(a, zetas)))
print("    distinct images = %d / 12" % len(set(imgs)))
if len(set(imgs)) != 12:
    ok = False

print()
print("E. invntt(ntt(x)) == MONT * x mod q   (MONT = R mod q = %d)" % MONT)
bad = 0
for _ in range(5):
    a = [i16(rng() % 32768 - 16384) for _ in range(N)]
    z = [val(v) for v in g.invntt(g.ntt(a, zetas), zetas)]
    for k in range(N):
        if z[k] != MONT * (i16(a[k]) % Q) % Q:
            bad += 1
print("    mismatched coefficients over 5 trials x 256 = %d / 1280" % bad)
if bad:
    ok = False

print()
print("ALL STRUCTURAL CHECKS PASSED" if ok else "STRUCTURAL CHECK FAILURE")
