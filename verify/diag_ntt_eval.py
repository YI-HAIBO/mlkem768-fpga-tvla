#!/usr/bin/env python3
"""diag_ntt_eval.py -- check whether kyber_ntt.v's forward NTT equals
polynomial evaluation at the 256 roots of X^256+1 (i.e. the odd powers of
17), under each candidate output ordering.  Throwaway diagnostic.
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


rtl_z = g.parse_rtl_zetas()
ref_z = g.ref_zetas()
print("RTL zetas == ref_zetas() exactly      :", rtl_z == ref_z)
cong = sum(1 for k in range(128) if i16(u16(rtl_z[k])) % Q == ref_z[k] % Q)
print("RTL zetas congruent mod q (0..127)    : %d/128" % cong)
if rtl_z != ref_z:
    bad = [k for k in range(128) if rtl_z[k] != ref_z[k]]
    print("  first representation diffs (rtl, ref):",
          [(k, i16(u16(rtl_z[k])), ref_z[k]) for k in bad[:8]])

rng = g._mulberry32(0xBEEF)
x = [i16(rng() % 32768 - 16384) for _ in range(N)]
y = g.ntt(x, rtl_z)
got = [i16(u16(v)) % Q for v in y]

pts = [pow(17, 2 * i + 1, Q) for i in range(N)]

print()
print("forward NTT vs  x(17^(2i+1))  under candidate orderings:")


def perm(name):
    if name == "identity":
        return list(range(N))
    if name == "bitrev":
        return [g.bitrev(i) for i in range(N)]
    if name == "tree":
        return list(g.TREE)
    if name == "halfsplit":
        return list(range(128)) + list(range(128, N))
    if name == "interleave":
        o = []
        for i in range(128):
            o += [i, i + 128]
        return o
    raise KeyError(name)


for pname in ("identity", "bitrev", "tree", "halfsplit", "interleave"):
    p = perm(pname)
    ref = g.eval_at_roots(x, "identity")
    permed = [ref[p[i]] for i in range(N)]
    hit = sum(1 for i in range(N) if got[i] == permed[i])
    # try constant scale
    s = None
    for i in range(N):
        if permed[i]:
            s = got[i] * pow(permed[i], -1, Q) % Q
            break
    hit_s = sum(1 for i in range(N) if permed[i] == 0 or
                got[i] == s * permed[i] % Q) if s is not None else 0
    print("  %-10s exact=%-4d  scale=%-5d -> %d hits"
          % (pname, hit, s if s is not None else -1, hit_s))

print()
print("same, but with roots taken as 17^(2i+1) reversed / negated:")
for tag, pts2 in (("17^(-(2i+1))", [pow(17, -(2 * i + 1), Q) for i in range(N)]),
                  ("17^(2i-1)", [pow(17, (2 * i - 1) % 512, Q) for i in range(N)])):
    xr = [i16(v) % Q for v in x]
    for pname in ("identity", "bitrev"):
        p = perm(pname)
        ref = []
        for j in p:
            p2 = pts2[j]
            s2 = 0
            pw = 1
            for i in range(N):
                s2 += xr[i] * pw
                pw = pw * p2 % Q
            ref.append(s2 % Q)
        hit = sum(1 for i in range(N) if got[i] == ref[i])
        print("  %-16s %-9s exact=%d" % (tag, pname, hit))
