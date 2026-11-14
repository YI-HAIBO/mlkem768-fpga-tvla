"""Decisive check: is the TB's gold_mul really schoolbook(rt_a, rt_b)*R?

Extracts rt_poly[0..511] and gold_mul[0..255] from tb_unified_ntt_sign.v and
compares gold_mul against the independently computed negacyclic convolution
times R.  If they differ, the TB's Test 6 'gold standard' is self-consistent
(model-generated) rather than an independent schoolbook reference, and the
DUT zeta table does not satisfy the pointwise-product property.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ntt_model import RTLNTT, DILITHIUM_ZETAS, schoolbook

Q = 8380417
BW = 27
NL = 8
SCALE_K = 49145
BM = 33587228
SH = 48
R = pow(2, BW, Q)

TB = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                  'sim', 'tb_unified_ntt_sign.v')
with open(TB, 'r', encoding='utf-8-sig', errors='replace') as f:
    src = f.read()


def extract_arr(name, count, lo, hi):
    vals = [None] * count
    pat = re.compile(name + r"\[(\d+)\]\s*=\s*27'd(\d+)")
    for m in pat.finditer(src):
        idx = int(m.group(1))
        if lo <= idx < hi:
            vals[idx - lo] = int(m.group(2))
    missing = [i + lo for i, v in enumerate(vals) if v is None]
    if missing:
        raise RuntimeError('missing %s entries: %s' % (name, missing[:8]))
    return vals


rt = extract_arr('rt_poly', 512, 0, 512)
gold_mul = extract_arr('gold_mul', 256, 0, 256)

# rt_poly is stored as 27-bit unsigned; TB treats coefficients as signed BW-bit
def to_signed(v):
    return v - (1 << BW) if v >= (1 << (BW - 1)) else v

rt_s = [to_signed(v) for v in rt]
a = rt_s[0:256]
b = rt_s[256:512]

conv = schoolbook(a, b, Q)
expected = [(conv[i] * R) % Q for i in range(256)]

mm = [i for i in range(256) if gold_mul[i] != expected[i]]
print('TB gold_mul vs schoolbook(rt_a,rt_b)*R:')
if not mm:
    print('  MATCH 256/256  -> gold_mul IS an independent schoolbook reference')
else:
    print('  MISMATCH at %d/256 indices (e.g. %s)' % (len(mm), mm[:8]))
    for i in mm[:5]:
        print('    [%d] gold=%d  schoolbookR=%d' % (i, gold_mul[i], expected[i]))

# --- also run the bit-exact RTL model on the TB's own vectors -------------
print('\nRTL model (DUT zetas) on TB vectors a,b:')
dut_zetas = [0] * 256
DUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                   'rtl', 'core', 'dilithium_ntt.v')
with open(DUT, 'r', encoding='utf-8-sig', errors='replace') as f:
    dut = f.read()
for i in range(256):
    m = re.search(r"8'd%d:\s*get_zeta\s*=\s*27'sd\s*(\d+);" % i, dut)
    dut_zetas[i] = int(m.group(1)) if m else 0
dut_zs = [to_signed(v) for v in dut_zetas]

ntt = RTLNTT(Q, BW, NL, BM, SH, SCALE_K)
fa, _ = ntt.ntt(dut_zs, a)
fb, _ = ntt.ntt(dut_zs, b)
pt = [((fa[i] % Q) * (fb[i] % Q)) % Q for i in range(256)]
out = [v % Q for v in ntt.invntt(dut_zs, pt)[0]]

mm2 = [i for i in range(256) if out[i] != gold_mul[i]]
print('  model INTT(NTT(a).NTT(b)) vs gold_mul: %d/256 match' % (256 - len(mm2)))
if not mm2:
    print('  -> model reproduces gold_mul EXACTLY (gold_mul is model-generated)')
mm3 = [i for i in range(256) if out[i] != expected[i]]
print('  model vs schoolbook*R: %d/256 mismatch' % len(mm3))
for i in mm3[:5]:
    print('    [%d] model=%d schoolbookR=%d' % (i, out[i], expected[i]))

# --- what about the standard zetas on TB vectors? -------------------------
print('\nRTL model (STANDARD zetas) on TB vectors a,b:')
fa2, _ = ntt.ntt(DILITHIUM_ZETAS, a)
fb2, _ = ntt.ntt(DILITHIUM_ZETAS, b)
pt2 = [((fa2[i] % Q) * (fb2[i] % Q)) % Q for i in range(256)]
out2 = [v % Q for v in ntt.invntt(DILITHIUM_ZETAS, pt2)[0]]
mm4 = [i for i in range(256) if out2[i] != expected[i]]
print('  vs schoolbook*R: %d/256 mismatch' % len(mm4))

# derive correct scale for standard zetas
e0 = [0] * 256
e0[0] = 1
f0, _ = ntt.ntt(DILITHIUM_ZETAS, e0)
raw0, _ = ntt.invntt_raw(DILITHIUM_ZETAS, f0)
C = raw0[0] % Q
off = [i for i in range(1, 256) if (raw0[i] % Q) != 0]
print('  standard-zeta roundtrip factor C=%d, offdiag=%s' % (C, off[:5]))
k = (R * R % Q) * pow(C, -1, Q) % Q
print('  -> SCALE_K for standard zetas would be %d (current %d)' % (k, SCALE_K))
