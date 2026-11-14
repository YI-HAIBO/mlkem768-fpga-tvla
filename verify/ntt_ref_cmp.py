#!/usr/bin/env python3
"""Compare gen_ntt_vectors.py's ntt/invntt against the pq-crystals reference.

This was missing from the verification story: the golden model passed
self-consistency oracles (ring homomorphism, zeta identity, round trip)
but those tests are invariant to several distinct transforms, so they
cannot prove the model computes the *Kyber* NTT.  This script builds the
reference ntt/invntt verbatim from pq-crystals/kyber ref/ntt.c and
diffs every coefficient against the golden model.

Run from the project root:
    python verify/ntt_ref_cmp.py
"""
import importlib.util
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

spec = importlib.util.spec_from_file_location(
    "g", os.path.join(HERE, "gen_ntt_vectors.py"))
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

Q = 3329
N = 256


def to_i16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


# ---------------------------------------------------------------------------
# pq-crystals/kyber ref/ntt.c, verbatim structure
# ---------------------------------------------------------------------------
def ref_ntt(a, zetas):
    """ref ntt().  zetas[k] in *signed int16* form, as in ntt.c."""
    k = 0
    a = list(a)
    length = 128
    while length >= 2:
        start = 0
        while start < N:
            zeta = zetas[k]
            k += 1
            for j in range(start, start + length):
                t = g.fqmul(zeta, a[j + length])
                a[j + length] = to_i16(a[j] - t)
                a[j] = to_i16(a[j] + t)
            start += 2 * length
        length >>= 1
    return a


def ref_invntt(a, zetas):
    """ref invntt()."""
    k = 127
    a = list(a)
    length = 2
    while length < 2 * N:
        start = 0
        while start < N:
            zeta = zetas[k]
            k -= 1
            for j in range(start, start + length):
                t = a[j]
                a[j] = g.barrett_reduce(to_i16(t + a[j + length]))
                a[j + length] = to_i16(a[j + length] - t)
                a[j + length] = g.fqmul(zeta, a[j + length])
            start += 2 * length
        length <<= 1
    return a


def ref_scale(a):
    return [g.fqmul(v, 1441) for v in a]


def main():
    rtl_z_signed = [to_i16(u) for u in g.parse_rtl_zetas()]

    rng = g._mulberry32(0x5A5A)
    trials = 4
    bad_ntt = 0
    bad_intt = 0
    bad_rt = 0
    for trial in range(trials):
        x = [to_i16(rng() % 32768 - 16384) for _ in range(N)]

        mine = g.ntt(x, rtl_z_signed)
        ref = ref_ntt(x, rtl_z_signed)
        for i in range(N):
            if (to_i16(mine[i]) - to_i16(ref[i])) % Q != 0:
                bad_ntt += 1
                if bad_ntt <= 4:
                    print("  ntt mismatch t%d i%d: mine=%d ref=%d"
                          % (trial, i, to_i16(mine[i]), to_i16(ref[i])))

        y = ref_ntt(x, rtl_z_signed)
        mine_i = g.invntt(y, rtl_z_signed)
        ref_i = ref_invntt(y, rtl_z_signed)
        for i in range(N):
            if (to_i16(mine_i[i]) - to_i16(ref_i[i])) % Q != 0:
                bad_intt += 1
                if bad_intt <= 4:
                    print("  invntt mismatch t%d i%d: mine=%d ref=%d"
                          % (trial, i, to_i16(mine_i[i]), to_i16(ref_i[i])))

        rt_ref = ref_scale(ref_invntt(ref_ntt(x, rtl_z_signed), rtl_z_signed))
        for i in range(N):
            if (to_i16(rt_ref[i]) - x[i]) % Q != 0:
                bad_rt += 1
    print("forward NTT  mismatching coefficients : %d" % bad_ntt)
    print("inverse NTT  mismatching coefficients : %d" % bad_intt)
    print("reference round-trip mismatches       : %d  (0 => ref is consistent)"
          % bad_rt)
    return 0


if __name__ == "__main__":
    sys.exit(main())
