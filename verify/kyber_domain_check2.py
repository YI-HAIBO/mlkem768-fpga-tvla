"""Direct domain check: compare basemul output vs to_ntt output"""
import sys
sys.path.insert(0, r"C:\Users\Yi\.workbuddy\binaries\python\envs\default\kyber-py")

from polynomials import PolynomialRing
from ntt_helper import NTTHelperKyber
import random

R = PolynomialRing(3329, 256, ntt_helper=NTTHelperKyber)
q = 3329
R_mod = 2285       # 2^16 mod q = R
R_inv = 169        # R^{-1} mod q

random.seed(42)
a = R.random_element()
a_orig = a.coeffs[:]

# to_ntt output
a_ntt = a.to_ntt()
print("=== Domain of to_ntt output ===")
# If a_ntt is in regular domain: from_ntt(a_ntt) = a_orig * R (adds R factor)
# If a_ntt is in Montgomery domain (a_orig * R): from_ntt(a_ntt) = a_orig * R^2 * 128^{-1} or similar
a_back = a_ntt.from_ntt()
check_reg = all((a_orig[i] * R_mod) % q == a_back.coeffs[i] for i in range(256))
check_mont = all((a_orig[i] * R_mod * R_mod) % q == a_back.coeffs[i] for i in range(256))
print(f"  to_ntt output in REGULAR domain (from_ntt gives orig*R): {check_reg}")
print(f"  to_ntt output in MONTGOMERY domain (from_ntt gives orig*R^2): {check_mont}")
print(f"  First 3: a_orig={a_orig[:3]}, a_ntt={a_ntt.coeffs[:3]}, a_back={a_back.coeffs[:3]}")

# Now check basemul output domain
print("\n=== Domain of basemul output ===")
b = R.random_element()
b_orig = b.coeffs[:]

a_ntt2 = a.to_ntt()
b_ntt2 = b.to_ntt()
c_ntt = a_ntt2.ntt_multiplication(b_ntt2)

# Direct schoolbook
c_direct = a.schoolbook_multiplication(b)
c_direct = [x % q for x in c_direct]

# What we know: from_ntt(c_ntt) = c_direct (exact, from previous test)
c_back = c_ntt.from_ntt()
check_exact = all(c_back.coeffs[i] == c_direct[i] for i in range(256))
print(f"  from_ntt(basemul) == schoolbook(a,b): {check_exact}")

# If from_ntt(c_ntt) = c_direct, and from_ntt adds R factor to regular domain input,
# then c_ntt must be in a domain that from_ntt converts to c_direct.
# from_ntt of regular domain input gives input * R.
# So if c_ntt were in regular domain, from_ntt would give c_ntt * R = c_direct, meaning c_ntt = c_direct * R^{-1}.
# Let's check: is c_ntt = c_direct * R^{-1} mod q?
check_inv = all((c_direct[i] * R_inv) % q == c_ntt.coeffs[i] for i in range(256))
print(f"  basemul output = schoolbook * R^(-1): {check_inv}")

# Or is c_ntt = c_direct * R mod q?
check_mont2 = all((c_direct[i] * R_mod) % q == c_ntt.coeffs[i] for i in range(256))
print(f"  basemul output = schoolbook * R: {check_mont2}")

# Or is c_ntt in regular domain = c_direct?
check_reg2 = all(c_ntt.coeffs[i] == c_direct[i] for i in range(256))
print(f"  basemul output = schoolbook (regular): {check_reg2}")

# Let's also check: is c_ntt = NTT(c_direct) in some domain?
# NTT(c_direct) in regular domain would give the NTT of c_direct
c_direct_ntt = R(c_direct).to_ntt()
check_ntt = all(c_ntt.coeffs[i] == c_direct_ntt.coeffs[i] for i in range(256))
print(f"  basemul output = NTT(schoolbook) (regular): {check_ntt}")

# What about NTT(c_direct) * R^{-1}?
c_direct_ntt_inv = [(c_direct_ntt.coeffs[i] * R_inv) % q for i in range(256)]
check_ntt_inv = all(c_ntt.coeffs[i] == c_direct_ntt_inv[i] for i in range(256))
print(f"  basemul output = NTT(schoolbook) * R^(-1): {check_ntt_inv}")

# What about NTT(c_direct) * R?
c_direct_ntt_mont = [(c_direct_ntt.coeffs[i] * R_mod) % q for i in range(256)]
check_ntt_mont = all(c_ntt.coeffs[i] == c_direct_ntt_mont[i] for i in range(256))
print(f"  basemul output = NTT(schoolbook) * R: {check_ntt_mont}")

print(f"\n  First 3: c_ntt={c_ntt.coeffs[:3]}")
print(f"  c_direct={c_direct[:3]}")
print(f"  c_direct*R^{-1}={[(c_direct[i]*R_inv)%q for i in range(3)]}")
print(f"  c_direct*R={[(c_direct[i]*R_mod)%q for i in range(3)]}")
print(f"  NTT(c_direct)={c_direct_ntt.coeffs[:3]}")