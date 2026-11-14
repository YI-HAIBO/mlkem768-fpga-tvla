"""Test what from_ntt actually returns - Montgomery or regular domain?"""
import sys
sys.path.insert(0, 'C:/Users/Yi/.workbuddy/binaries/python/envs/default/kyber-py')

from polynomials import PolynomialRing
from ntt_helper import NTTHelperKyber
import random

R = PolynomialRing(3329, 256, ntt_helper=NTTHelperKyber)

random.seed(42)

# Test: does from_ntt give regular or Montgomery domain?
a = R.random_element()
a_orig = a.coeffs[:]

a_ntt = a.to_ntt()
a_back = a_ntt.from_ntt()

# Check if a_back is in regular domain (matches a_orig)
match_regular = all(a_back.coeffs[i] == a_orig[i] for i in range(256))
print(f"from_ntt gives regular domain: {match_regular}")

# Check if a_back is in Montgomery domain (needs conversion)
a_from_mont = [NTTHelperKyber.ntt_mul(c, 1) for c in a_back.coeffs]
match_mont = all(a_from_mont[i] == a_orig[i] for i in range(256))
print(f"from_ntt gives Montgomery domain (after conversion): {match_mont}")

# Let's also check: what is the relationship?
# If from_ntt gives f * R, then a_back[i] = a_orig[i] * R mod q
# R mod q = 2285
R_mod_q = 2285
match_R = all((a_orig[i] * R_mod_q) % 3329 == a_back.coeffs[i] for i in range(256))
print(f"from_ntt gives f * R mod q: {match_R}")

# Maybe from_ntt gives f * 512 mod q? (since f=1441, and 1441*169 mod q = 512)
f_val = 1441
scale = (f_val * 169) % 3329
print(f"Effective scale of f: {scale} (f*RINV mod q)")
match_scale = all((a_orig[i] * scale) % 3329 == a_back.coeffs[i] for i in range(256))
print(f"from_ntt gives f * {scale} mod q: {match_scale}")

# Let's print some actual values
print(f"\na_orig[0:5]: {a_orig[:5]}")
print(f"a_back[0:5]: {a_back.coeffs[:5]}")
print(f"a_orig[0]*R mod q: {(a_orig[0]*R_mod_q)%3329}")
print(f"a_orig[0]*scale mod q: {(a_orig[0]*scale)%3329}")