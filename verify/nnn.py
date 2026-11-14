#!/usr/bin/env python3
"""Find the reference NTT zeta indexing by testing both conventions.

Earlier work validated the transform only through self-consistency oracles
(ring homomorphism, zeta identity, round trip).  Those tests are invariant
across a family of distinct schedules, so they cannot pick the right one.
This script pins the convention down by brute force:

  * hypothesis A  -- ref_ntt uses zetas[k] with k starting at 1
                     (i.e. the table as indexed by the RTL's zeta_cnt).
  * hypothesis B  -- ref_ntt uses zetas[k] with k starting at 0.

Each hypothesis is scored on whether ntt is a ring isomorphism with the
recovered pair-zetas (the deciding property), and the recovered zeta
power sequence is printed so the correct schedule can be recognised by
eye: the Kyber forward NTT must consume 128th roots of -1 in bit-reversed
order.
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "g", os.path.join(HERE, "gen_ntt_vectors.py"))
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

Q = 3329
N = 256


def to_i16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


def ring_mul(a, b):
    c = [0] * (2 * N)
    for i in range(N):
        if a[i] % Q == 0:
            continue
        for j in range(N):
            if b[j] % Q == 0:
                continue
            c[i + j] += a[i] * b[j]
    return [(c[i] - c[i + N]) % Q for i in range(N)]


def run_ntt(x, z, base):
    a = [to_i16(v) for v in x]
    k, ln = base, 128
    while ln >= 2:
        start = 0
        while start < N:
            zz = z[k]
            k += 1
            for j in range(start, start + ln):
                t = g.fqmul(zz, a[j + ln])
                a[j + ln] = to_i16(a[j] - t)
                a[j] = to_i16(a[j] + t)
            start += 2 * ln
        ln >>= 1
    return a


def score(z, base, label):
    rng = g._mulberry32(0x1234)
    polys = [[to_i16(rng() % 32768 - 16384) for _ in range(N)] for _ in range(3)]
    T = lambda p: run_ntt(p, z, base)
    ok = tot = 0
    rec = {}
    for a in polys:
        for b in polys:
            ya, yb, yab = T(a), T(b), T(ring_mul(a, b))
            for k in range(128):
                a0, a1 = ya[2 * k] % Q, ya[2 * k + 1] % Q
                b0, b1 = yb[2 * k] % Q, yb[2 * k + 1] % Q
                num = (yab[2 * k] - a0 * b0) % Q
                den = (a1 * b1) % Q
                if den:
                    z2 = num * pow(den, -1, Q) % Q
                    rec.setdefault(k, set()).add(z2)
                num2 = (yab[2 * k + 1] - (a0 * b1 + a1 * b0)) % Q
                tot += 1
                if num2 == 0:
                    ok += 1
    uniq = sum(1 for k in rec if len(rec[k]) == 1)
    allroots = all(pow(v, 128, Q) == Q - 1
                   for k in rec for v in rec[k])
    print("%s : r[1] homomorphism %d/%d, unique pair-zetas %d/128, "
          "all 128th roots of -1: %s" % (label, ok, tot, uniq, allroots))
    return rec


def main():
    zu = g.parse_rtl_zetas()
    z = [to_i16(v) for v in zu]
    print("z table (i16): %s ..." % z[:8])

    recA = score(z, 1, "hypothesis A (k starts at 1, as the golden model uses)")
    recB = score(z, 0, "hypothesis B (k starts at 0)")

    for name, rec in (("A", recA), ("B", recB)):
        vals = [to_i16(rec[k].pop()) if len(rec[k]) == 1 else None
                for k in sorted(rec)]
        print("  %s first 8 pair zetas: %s" % (name, vals[:8]))

    return 0


if __name__ == "__main__":
    sys.exit(main())
