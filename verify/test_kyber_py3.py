"""Test what domain to_ntt maps to"""
import sys
sys.path.insert(0, 'C:/Users/Yi/.workbuddy/binaries/python/envs/default/kyber-py')

from polynomials import PolynomialRing
from ntt_helper import NTTHelperKyber
import random

R = PolynomialRing(3329, 256, ntt_helper=NTTHelperKyber)
R_mod = 2285  # R mod q

random.seed(42)
a = R.random_element()
a_orig = a.coeffs[:]

# After to_ntt
a_ntt = a.to_ntt()

# Check if a_ntt is in regular domain (matches a_orig after inverse NTT)
# Or in Montgomery domain (a_orig * R after inverse NTT)

# If to_ntt maps to regular domain, then from_ntt should give a_orig * R
# If to_ntt maps to Montgomery domain, then from_ntt should give a_orig * R^2

a_back = a_ntt.from_ntt()

# Check: a_back = a_orig * R mod q?
match_R = all((a_orig[i] * R_mod) % 3329 == a_back.coeffs[i] for i in range(256))
print(f"from_ntt(to_ntt(f)) = f * R mod q: {match_R}")

# Check: a_back = a_orig * R^2 mod q?
R2_mod = (R_mod * R_mod) % 3329
match_R2 = all((a_orig[i] * R2_mod) % 3329 == a_back.coeffs[i] for i in range(256))
print(f"from_ntt(to_ntt(f)) = f * R^2 mod q: {match_R2}")
print(f"R^2 mod q = {R2_mod}")

# Now check: is a_ntt in regular or Montgomery domain?
# If a_ntt is in regular domain, then ntt_mul(a_ntt[i], 1) = a_ntt[i] * R^{-1} should be the "true" value
# If a_ntt is in Montgomery domain, then a_ntt[i] should equal true_value * R

# We can check by doing: from_ntt(to_ntt(f)) = f * R
# If to_ntt maps to regular domain: from_ntt adds R factor → f * R ✓
# If to_ntt maps to Montgomery domain: from_ntt should remove R factor → f
# But we see f * R, so to_ntt maps to regular domain!

print("\nConclusion: to_ntt maps to REGULAR domain (not Montgomery)")
print("from_ntt adds Montgomery factor R")

# Now test: what does ntt_multiplication give?
b = R.random_element()
b_ntt = b.to_ntt()

# Multiply in NTT form
c_ntt_form = a_ntt * b_ntt  # ntt_multiplication

# Check domain of c_ntt_form
# If ntt_multiplication preserves regular domain, then from_ntt should give (a*b) * R
c_back = c_ntt_form.from_ntt()

# Direct multiplication
c_direct = a * b
c_direct_reg = [x % 3329 for x in c_direct.coeffs]

# Check: c_back = c_direct * R mod q?
match_c_R = all((c_direct_reg[i] * R_mod) % 3329 == c_back.coeffs[i] for i in range(256))
print(f"\nfrom_ntt(a_ntt * b_ntt) = (a*b) * R mod q: {match_c_R}")

# If yes, then c_ntt_form is in regular domain, and from_ntt adds R
# To get regular domain result: from_montgomery(c_back) = c_back * R^{-1} = c_direct

c_regular = [NTTHelperKyber.ntt_mul(x, 1) for x in c_back.coeffs]
match_final = all(c_regular[i] == c_direct_reg[i] for i in range(256))
print(f"from_montgomery(from_ntt(a_ntt * b_ntt)) = a*b: {match_final}")

if not match_final:
    mismatches = [(i, c_regular[i], c_direct_reg[i]) for i in range(256) if c_regular[i] != c_direct_reg[i]]
    print(f"  Mismatches: {len(mismatches)}, first: {mismatches[:5]}")