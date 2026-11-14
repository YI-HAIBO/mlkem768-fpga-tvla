#!/usr/bin/env python3
"""diag_ntt_root.py -- find the (root, sign, permutation, scale) convention the
kyber_ntt.v butterfly actually implements, matching it against an independent
O(N^2) DFT.  Throwaway diagnostic; the surviving convention is baked into
gen_ntt_vectors.py.
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


rng = g._mulberry32(0xBEEF)
x = [i16(rng() % 32768 - 16384) for _ in range(N)]
y = g.ntt(x, g.parse_rtl_zetas())
got = [i16(u16(v)) % Q for v in y]
xr = [i16(v) % Q for v in x]

print("x[:4] mod q :", xr[:4])
print("y[:4] mod q :", got[:4])
print()


def dft_powers(a, w, sgn):
    """DFT using a precomputed table of w^(sgn*i*j) for each j."""
    out = []
    for j in range(N):
        s = 0
        wi = 1
        step = w if sgn == 1 else pow(w, -1, Q)
        for i in range(N):
            s += a[i] * wi
            wi = wi * pow(step, j, Q) % Q
        out.append(s % Q)
    return out


def dft(a, w, sgn):
    pw = [pow(w, (sgn * j) % N, Q) for j in range(N)]   # w^(sgn*j)
    out = []
    for j in range(N):
        s = 0
        for i in range(N):
            s += a[i] * pow(pw[j], i, Q)
        out.append(s % Q)
    return out


roots = {
    "17": 17,
    "17^2": pow(17, 2, Q),
    "17^-1": pow(17, -1, Q),
    "17^-2": pow(17, -2, Q),
    "17^3": pow(17, 3, Q),
    "17^4": pow(17, 4, Q),
    "17^-3": pow(17, -3, Q),
    "17^-4": pow(17, -4, Q),
}


def perm_list(name):
    if name == "identity":
        return list(range(N))
    if name == "bitrev":
        return [g.bitrev(i) for i in range(N)]
    if name == "lowhalf_first":
        return list(range(128)) + list(range(128, N))
    if name == "br4":
        # reverse only the low 4 bits, keep high 4 bits
        return [((i >> 4) << 4) | ((i & 0xF) << 0) |
                (((i & 0xF) >> 1) << 0) for i in range(N)]
    raise KeyError(name)


results = []
for rname, w in roots.items():
    for sgn in (1, -1):
        ref = dft(xr, w, sgn)
        for pname in ("identity", "bitrev"):
            pmap = perm_list(pname)
            perm = [ref[pmap[i]] for i in range(N)]
            hit = sum(1 for i in range(N) if got[i] == perm[i])
            if hit == 0:
                # try a constant scale
                s = None
                for i in range(N):
                    if perm[i] != 0:
                        s = got[i] * pow(perm[i], -1, Q) % Q
                        break
                if s is not None:
                    hit = sum(1 for i in range(N)
                              if perm[i] == 0 or got[i] == s * perm[i] % Q)
                    tag = "scale=%d" % s
                else:
                    tag = ""
            else:
                tag = "scale=1"
            results.append((hit, rname, sgn, pname, tag))

results.sort(reverse=True)
print("%-6s %-10s %-5s %-10s %s" % ("hits", "root", "sgn", "perm", "note"))
for hit, rname, sgn, pname, tag in results[:10]:
    print("%-6d %-10s %+d    %-10s %s" % (hit, rname, sgn, pname, tag))
