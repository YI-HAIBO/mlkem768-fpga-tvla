"""Generate the correct get_zeta function with standard Dilithium zetas."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ntt_model import DILITHIUM_ZETAS

Q = 8380417
BW = 27

# DILITHIUM_ZETAS are signed values in [-q/2, q/2-1]
# We need to convert to 27-bit unsigned (two's complement)
def to_unsigned_27(v):
    """Convert signed value to 27-bit unsigned representation."""
    if v >= 0:
        return v
    else:
        return v + (1 << BW)

print("Corrected get_zeta function (standard Dilithium zetas):")
print("// =========================================================================")
print("// Zeta ROM function (256 entries, 27-bit unsigned, standard Dilithium)")
print("// Generated from PQ-Crystals reference: ref/ntt.c zetas[256]")
print("// =========================================================================")
print("function [26:0] get_zeta;")
print("    input [7:0] addr;")
print("    case (addr)")

for i, z in enumerate(DILITHIUM_ZETAS):
    u = to_unsigned_27(z)
    print(f"        8'd{i}:   get_zeta = 27'd{u};")

print("        default: get_zeta = 27'd0;")
print("    endcase")
print("endfunction")

# Also verify: zeta[1] should be 25847 (standard) not 2357800 (old DUT)
u1 = to_unsigned_27(DILITHIUM_ZETAS[1])
print(f"\nVerification: zeta[1] = {DILITHIUM_ZETAS[1]} (signed) = {u1} (unsigned 27-bit)")
print(f"Old DUT zeta[1] was 2357800 (WRONG)")
