"""Discriminator: run the bit-exact RTL model with the TB's OWN sign_zeta table.

check_gold_mul.py showed the model with dilithium_ntt.v's get_zeta table does
NOT reproduce gold_mul, while the RTL (TB, which loads sign_zeta) does.
If the model with sign_zeta DOES reproduce gold_mul, then sign_zeta != get_zeta
and the wrapper is loading the wrong zeta table.  If it still fails, the
model's invntt() does not match the RTL inverse path.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ntt_model import RTLNTT, schoolbook

Q = 8380417
BW = 27
NL = 8
SCALE_K = 49145
BM = 33587228
SH = 48
R = pow(2, BW, Q)

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def extract_arr(fname, name, count):
    with open(os.path.join(BASE, fname), 'r', encoding='utf-8-sig', errors='replace') as f:
        src = f.read()
    vals = [None] * count
    for m in re.finditer(name + r"\[(\d+)\]\s*=\s*27'd(\d+)", src):
        idx = int(m.group(1))
        if idx < count:
            vals[idx] = int(m.group(2))
    missing = [i for i, v in enumerate(vals) if v is None]
    if missing:
        raise RuntimeError('%s missing %s' % (name, missing[:8]))
    return vals


def to_signed(v):
    return v - (1 << BW) if v >= (1 << (BW - 1)) else v


rt = extract_arr('sim/tb_unified_ntt_sign.v', 'rt_poly', 512)
gold_mul = extract_arr('sim/tb_unified_ntt_sign.v', 'gold_mul', 256)
sign_zeta = extract_arr('sim/tb_unified_ntt_sign.v', 'sign_zeta', 256)

a = [to_signed(v) for v in rt[0:256]]
b = [to_signed(v) for v in rt[256:512]]
zs = [to_signed(v) for v in sign_zeta]

ntt = RTLNTT(Q, BW, NL, BM, SH, SCALE_K)

# sanity: forward NTT of the TB's Test-1 vector should match gold_ntt
gold_ntt = extract_arr('sim/tb_unified_ntt_sign.v', 'gold_ntt', 256)
f1 = [to_signed(rt[i]) for i in range(256)]
fa, _ = ntt.ntt(zs, f1)
mm = [i for i in range(256) if (fa[i] % Q) != gold_ntt[i]]
print('model ntt(sign_zeta, f1) vs gold_ntt: %d/256 mismatch' % len(mm))

# the real discriminator
fa, _ = ntt.ntt(zs, a)
fb, _ = ntt.ntt(zs, b)
pt = [((fa[i] % Q) * (fb[i] % Q)) % Q for i in range(256)]
out = [v % Q for v in ntt.invntt(zs, pt)[0]]
mm = [i for i in range(256) if out[i] != gold_mul[i]]
print('model(sign_zeta) INTT(NTT(a).NTT(b)) vs gold_mul: %d/256 mismatch' % len(mm))
for i in mm[:5]:
    print('    [%d] model=%d gold=%d' % (i, out[i], gold_mul[i]))

# also verify the model roundtrip with sign_zeta
e0 = [0] * 256
e0[0] = 1
f0, _ = ntt.ntt(zs, e0)
raw0, _ = ntt.invntt_raw(zs, f0)
C = raw0[0] % Q
off = [i for i in range(1, 256) if (raw0[i] % Q) != 0]
print('sign_zeta roundtrip C=%d offdiag=%s' % (C, off[:5]))
