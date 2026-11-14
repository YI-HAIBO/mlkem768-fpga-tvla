"""Check if Python model's pointwise multiplication gives correct result."""
import sys, re
sys.path.insert(0, '.')
from ntt_model import RTLNTT, DILITHIUM_ZETAS, schoolbook

Q = 8380417
BW = 27
NL = 8
SCALE_K = 49145
BM = 33587228
SH = 48
R = pow(2, BW, Q)
Rinv = pow(R, -1, Q)

# Extract DUT zetas
with open('rtl/core/dilithium_ntt.v', 'r') as f:
    content = f.read()
dut_zetas = []
for i in range(256):
    pattern = f"8'd{i}:\\s*get_zeta\\s*=\\s*27'sd\\s*(\\d+);"
    match = re.search(pattern, content)
    if match:
        v = int(match.group(1))
        dut_zetas.append(v - (1 << 27) if v >= (1 << 26) else v)

ntt = RTLNTT(Q, BW, NL, BM, SH, SCALE_K)

a = [0]*256; a[0] = 1; a[1] = 2
b = [0]*256; b[0] = 3; b[1] = 4

# NTT of a and b
a_ntt, _ = ntt.ntt(dut_zetas, a)
b_ntt, _ = ntt.ntt(dut_zetas, b)

print(f"a_ntt[0..4] = {a_ntt[0:5]}")
print(f"b_ntt[0..4] = {b_ntt[0:5]}")

# Pointwise multiplication
c_ntt = [(a_ntt[i] * b_ntt[i]) % Q for i in range(256)]
print(f"c_ntt[0..4] = {c_ntt[0:5]}")

# INTT of pointwise product
c_raw, _ = ntt.invntt_raw(dut_zetas, c_ntt)
c_scaled = [ntt.fqmul(x, SCALE_K) for x in c_raw]
print(f"INTT(c_ntt)[0..4] = {c_scaled[0:5]}")

# Expected: negacyclic convolution * R mod q
c_school = schoolbook(a, b, Q)
print(f"Schoolbook conv[0..4] = {c_school[0:5]}")
print(f"Expected (conv*R)[0..4] = {[x * R % Q for x in c_school[0:5]]}")

# Also check: what does the DUT's INTT produce?
# DUT loads c_ntt as unsigned [0, q-1], then runs INTT
# The Python model's c_ntt is in [-q/2, q/2], need to convert to [0, q-1]
c_ntt_unsigned = [x % Q for x in c_ntt]
c_raw2, _ = ntt.invntt_raw(dut_zetas, c_ntt_unsigned)
c_scaled2 = [ntt.fqmul(x, SCALE_K) for x in c_raw2]
print(f"\nINTT with unsigned c_ntt[0..4] = {c_scaled2[0:5]}")

# Check: is the DUT's INTT output (3298605) related to 3*R = 393168?
print(f"\nDUT INTT output[0] = 3298605")
print(f"3 * R mod q = {3 * R % Q}")
print(f"3298605 / R mod q = {3298605 * Rinv % Q}")
