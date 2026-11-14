"""Standalone domain check: what exactly does from_ntt(to_ntt(f)) yield?"""
import sys, os
sys.path.insert(0, r"C:\Users\Yi\.workbuddy\binaries\python\envs\default\kyber-py")

from polynomials import PolynomialRing
from ntt_helper import NTTHelperKyber
import random

R = PolynomialRing(3329, 256, ntt_helper=NTTHelperKyber)
q = 3329
R_mod = 2285       # 2^16 mod q
R_inv = 169        # R^{-1} mod q
R2 = 1353          # R^2 mod q
f_val = 1441       # from kyber-py: f = 1441
inv128 = pow(128, -1, q)  # 128^{-1} mod q = 3303

# What is f * R^{-1} mod q?
f_times_Rinv = (f_val * R_inv) % q
print(f"f = {f_val}")
print(f"f * R^(-1) mod q = {f_times_Rinv}")
print(f"R * 128^(-1) mod q = {(R_mod * inv128) % q}")
print(f"128^(-1) mod q = {inv128}")
print()

# Check: is f_times_Rinv == R * 128^{-1}?
print(f"f * R^(-1) == R * 128^(-1): {f_times_Rinv == (R_mod * inv128) % q}")
print()

# Now test with actual polynomials
random.seed(42)
a = R.random_element()
a_orig = a.coeffs[:]

a_ntt = a.to_ntt()
a_back = a_ntt.from_ntt()

# Check various hypotheses
h1 = all((a_orig[i] * R_mod) % q == a_back.coeffs[i] for i in range(256))
h2 = all((a_orig[i] * f_times_Rinv) % q == a_back.coeffs[i] for i in range(256))
h3 = all((a_orig[i] * R_mod * inv128) % q == a_back.coeffs[i] for i in range(256))
h4 = all((a_orig[i] * 512) % q == a_back.coeffs[i] for i in range(256))

print(f"from_ntt(to_ntt(f)) = f * R mod q:               {h1}")
print(f"from_ntt(to_ntt(f)) = f * (f*R^{-1}) mod q:      {h2}")
print(f"from_ntt(to_ntt(f)) = f * R * 128^{-1} mod q:   {h3}")
print(f"from_ntt(to_ntt(f)) = f * 512 mod q:             {h4}")

# Print first few coefficients for manual comparison
print(f"\nFirst 5 coeffs: orig={a_orig[:5]}")
print(f"  back={a_back.coeffs[:5]}")
print(f"  orig*R mod q={[(a_orig[i]*R_mod)%q for i in range(5)]}")
print(f"  orig*512 mod q={[(a_orig[i]*512)%q for i in range(5)]}")
print(f"  orig*R*inv128 mod q={[(a_orig[i]*R_mod*inv128)%q for i in range(5)]}")

# Now test the full multiplication chain
print("\n--- Full multiplication chain ---")
b = R.random_element()
b_orig = b.coeffs[:]

# Schoolbook
c_direct = a.schoolbook_multiplication(b)
c_direct = [x % q for x in c_direct]

# NTT chain: to_ntt -> ntt_multiplication -> from_ntt -> from_montgomery
a_ntt2 = a.to_ntt()
b_ntt2 = b.to_ntt()
c_ntt = a_ntt2.ntt_multiplication(b_ntt2)
c_back2 = c_ntt.from_ntt()

# from_montgomery: multiply by R^{-1}
c_from_mont = [NTTHelperKyber.ntt_mul(x, 1) for x in c_back2.coeffs]
# ntt_mul(x, 1) = montgomery_reduce(x * 1) = x * R^{-1} mod q

match_direct = all(c_from_mont[i] == c_direct[i] for i in range(256))
print(f"from_mont(from_ntt(ntt_mul(to_ntt(a), to_ntt(b)))) == a*b: {match_direct}")

if not match_direct:
    mismatches = [(i, c_from_mont[i], c_direct[i]) for i in range(256) if c_from_mont[i] != c_direct[i]]
    print(f"  Mismatches: {len(mismatches)}, first 5: {mismatches[:5]}")

# Also check: does from_ntt output need 128^{-1} correction?
# c_back2 should equal c_direct * R * 128^{-1} mod q (if my analysis is right)
# Or c_direct * R mod q (if the test was right)
c_expected_R = [(c_direct[i] * R_mod) % q for i in range(256)]
c_expected_R_inv128 = [(c_direct[i] * R_mod * inv128) % q for i in range(256)]
c_expected_512 = [(c_direct[i] * 512) % q for i in range(256)]

match_R = all(c_back2.coeffs[i] == c_expected_R[i] for i in range(256))
match_R_inv128 = all(c_back2.coeffs[i] == c_expected_R_inv128[i] for i in range(256))
match_512 = all(c_back2.coeffs[i] == c_expected_512[i] for i in range(256))

print(f"\nfrom_ntt(basemul) == (a*b) * R mod q:           {match_R}")
print(f"from_ntt(basemul) == (a*b) * R * 128^{-1} mod q: {match_R_inv128}")
print(f"from_ntt(basemul) == (a*b) * 512 mod q:          {match_512}")

# Print first few for manual check
print(f"\nFirst 5 coeffs of from_ntt(basemul): {c_back2.coeffs[:5]}")
print(f"  (a*b)*R mod q:                     {c_expected_R[:5]}")
print(f"  (a*b)*R*128^(-1) mod q:            {c_expected_R_inv128[:5]}")
print(f"  (a*b)*512 mod q:                   {c_expected_512[:5]}")