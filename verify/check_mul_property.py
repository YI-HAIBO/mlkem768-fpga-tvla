"""Check if INTT(NTT(a) * NTT(b)) == schoolbook_conv * R for DUT zetas."""
import sys, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ntt_model import RTLNTT, DILITHIUM_ZETAS, schoolbook

Q = 8380417
BW = 27
NL = 8
SCALE_K = 49145
BM = 33587228
SH = 48
R = pow(2, BW, Q)

# Extract DUT zetas from get_zeta function
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'core', 'dilithium_ntt.v'), 'r', encoding='utf-8-sig', errors='replace') as f:
    content = f.read()

dut_zetas = []
for i in range(256):
    pattern = r"8'd%d:\s*get_zeta\s*=\s*27'sd\s*(\d+);" % i
    match = re.search(pattern, content)
    if match:
        dut_zetas.append(int(match.group(1)))
    else:
        dut_zetas.append(0)

# Convert to signed
dut_zetas_signed = []
for z in dut_zetas:
    if z >= (1 << 26):
        dut_zetas_signed.append(z - (1 << 27))
    else:
        dut_zetas_signed.append(z)

print(f"DUT zetas[0..4] = {dut_zetas_signed[:5]}")
print(f"Standard zetas[0..4] = {DILITHIUM_ZETAS[:5]}")

ntt = RTLNTT(Q, BW, NL, BM, SH, SCALE_K)

# Test with a=[1,2,0..], b=[3,4,0..]
a = [0]*256
a[0] = 1
a[1] = 2
b = [0]*256
b[0] = 3
b[1] = 4

# Compute NTT
fwd_a, _ = ntt.ntt(dut_zetas_signed, a)
fwd_b, _ = ntt.ntt(dut_zetas_signed, b)

print(f"\nNTT(a)[0..4] = {fwd_a[:5]}")
print(f"NTT(b)[0..4] = {fwd_b[:5]}")

# Pointwise product (signed mod-q reduction, same as TB)
pt = [0]*256
for i in range(256):
    ua = fwd_a[i] % Q
    if ua < 0:
        ua += Q
    ub = fwd_b[i] % Q
    if ub < 0:
        ub += Q
    pt[i] = (ua * ub) % Q

print(f"pt[0..4] = {pt[:5]}")

# INTT
intt_out, _ = ntt.invntt(dut_zetas_signed, pt)
print(f"INTT(pt)[0..4] = {intt_out[:5]}")

# Expected: schoolbook_conv * R mod Q
conv = schoolbook(a, b, Q)
expected = [(conv[i] * R) % Q for i in range(256)]
print(f"Expected (conv*R)[0..4] = {expected[:5]}")

# Compare
mismatches = 0
for i in range(256):
    if intt_out[i] % Q != expected[i]:
        if mismatches < 5:
            print(f"MISMATCH[{i}]: got={intt_out[i] % Q} expected={expected[i]}")
        mismatches += 1

if mismatches == 0:
    print(f"\n*** ALL PASS: INTT(NTT(a)*NTT(b)) == schoolbook_conv * R (256/256) ***")
else:
    print(f"\n*** FAIL: {mismatches} mismatches ***")

# Also test with standard zetas
print(f"\n--- Testing with STANDARD Dilithium zetas ---")
fwd_a2, _ = ntt.ntt(DILITHIUM_ZETAS, a)
fwd_b2, _ = ntt.ntt(DILITHIUM_ZETAS, b)

pt2 = [0]*256
for i in range(256):
    ua = fwd_a2[i] % Q
    if ua < 0: ua += Q
    ub = fwd_b2[i] % Q
    if ub < 0: ub += Q
    pt2[i] = (ua * ub) % Q

intt_out2, _ = ntt.invntt(DILITHIUM_ZETAS, pt2)
print(f"INTT(pt2)[0..4] = {intt_out2[:5]}")
print(f"Expected (conv*R)[0..4] = {expected[:5]}")

mismatches2 = 0
for i in range(256):
    if intt_out2[i] % Q != expected[i]:
        if mismatches2 < 5:
            print(f"MISMATCH[{i}]: got={intt_out2[i] % Q} expected={expected[i]}")
        mismatches2 += 1

if mismatches2 == 0:
    print(f"\n*** ALL PASS with standard zetas ***")
else:
    print(f"\n*** FAIL with standard zetas: {mismatches2} mismatches ***")
