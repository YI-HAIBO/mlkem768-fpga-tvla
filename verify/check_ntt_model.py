"""Check if Python model's NTT matches RTL's NTT output for a=[1,2,0,...]."""
import sys
sys.path.insert(0, '.')
from ntt_model import RTLNTT, DILITHIUM_ZETAS

Q = 8380417
BW = 27
NL = 8
SCALE_K = 49145
BM = 33587228
SH = 48

# Extract DUT zetas from get_zeta function
import re
with open('rtl/core/dilithium_ntt.v', 'r', encoding='utf-8-sig', errors='replace') as f:
    content = f.read()
dut_zetas = []
for i in range(256):
    pattern = f"8'd{i}:\\s*get_zeta\\s*=\\s*27'sd\\s*(\\d+);"
    match = re.search(pattern, content)
    if match:
        dut_zetas.append(int(match.group(1)))
    else:
        dut_zetas.append(0)

# Convert DUT zetas (unsigned) to signed
dut_zetas_signed = []
for z in dut_zetas:
    if z >= (1 << 26):
        dut_zetas_signed.append(z - (1 << 27))
    else:
        dut_zetas_signed.append(z)

print(f"DUT zetas[0..4] = {dut_zetas_signed[:5]}")
print(f"Model zetas[0..4] = {DILITHIUM_ZETAS[:5]}")
print(f"DUT zetas[1] = {dut_zetas_signed[1]}, Model zetas[1] = {DILITHIUM_ZETAS[1]}")

# Create RTLNTT model
ntt = RTLNTT(Q, BW, NL, BM, SH, SCALE_K)

# Test with a=[1,2,0,...]
a = [0]*256
a[0] = 1
a[1] = 2

# Run NTT with DUT zetas
fwd, _ = ntt.ntt(dut_zetas_signed, a)
print(f"\nPython model NTT(a)[0..4] = {fwd[0:5]}")
print(f"Expected RTL output: [3507, -3505, -3870839, 3870841, 3061368]")

# Also try with standard DILITHIUM_ZETAS
fwd2, _ = ntt.ntt(DILITHIUM_ZETAS, a)
print(f"\nPython model NTT with standard zetas[0..4] = {fwd2[0:5]}")

# Check: is the DUT zeta table the Montgomery form of the standard zetas?
R = pow(2, BW, Q)
print(f"\nR = {R}")
for i in range(5):
    std_mont = (DILITHIUM_ZETAS[i] * R) % Q
    print(f"  zeta[{i}]: std={DILITHIUM_ZETAS[i]}, mont={std_mont}, dut={dut_zetas[i]}")
