"""Clean domain check with proper coefficient copying"""
import sys, copy
sys.path.insert(0, r"C:\Users\Yi\.workbuddy\binaries\python\envs\default\kyber-py")

from polynomials import PolynomialRing
from ntt_helper import NTTHelperKyber
import random

R = PolynomialRing(3329, 256, ntt_helper=NTTHelperKyber)
q = 3329
R_mod = 2285       # 2^16 mod q = R
R_inv = 169        # R^{-1} mod q
f_val = 1441       # INTT scaling factor

random.seed(42)

# Create fresh polynomials and COPY their coefficients
a = R.random_element()
a_orig = a.coeffs[:]  # copy before any in-place modification

b = R.random_element()
b_orig = b.coeffs[:]

# === Test 1: to_ntt / from_ntt round-trip ===
# Use a fresh polynomial for to_ntt
a_fresh = R(a_orig[:])  # new polynomial with same coeffs
a_ntt = a_fresh.to_ntt()  # in-place! a_fresh.coeffs is now NTT
a_ntt_coeffs = a_fresh.coeffs[:]  # copy NTT output

# from_ntt on a fresh copy of the NTT
a_back_fresh = R(a_ntt_coeffs[:], is_ntt=True)
a_back_fresh.from_ntt()  # in-place
a_back_coeffs = a_back_fresh.coeffs[:]

# Check: from_ntt(to_ntt(f)) = f * R mod q?
check_R = all((a_orig[i] * R_mod) % q == a_back_coeffs[i] for i in range(256))
print(f"from_ntt(to_ntt(f)) = f * R mod q: {check_R}")
print(f"  First 3: orig={a_orig[:3]}, back={a_back_coeffs[:3]}, orig*R={[(a_orig[i]*R_mod)%q for i in range(3)]}")

# === Test 2: Full multiplication chain ===
# Create fresh copies for the multiplication
a_fresh2 = R(a_orig[:])
b_fresh2 = R(b_orig[:])

# to_ntt both
a_fresh2.to_ntt()  # in-place, now in NTT form
b_fresh2.to_ntt()  # in-place, now in NTT form

# ntt_multiplication (both in NTT form)
c_ntt_poly = a_fresh2.ntt_multiplication(b_fresh2)
c_ntt_coeffs = c_ntt_poly.coeffs[:]  # basemul output

# from_ntt
c_ntt_poly.from_ntt()  # in-place
c_back_coeffs = c_ntt_poly.coeffs[:]

# Schoolbook for comparison
c_direct = a.schoolbook_multiplication(b)
c_direct_mod = [x % q for x in c_direct]

# Check: from_ntt(basemul(to_ntt(a), to_ntt(b))) == schoolbook(a,b) mod q?
check_exact = all(c_back_coeffs[i] == c_direct_mod[i] for i in range(256))
print(f"\nfrom_ntt(basemul(to_ntt(a),to_ntt(b))) == schoolbook(a,b) mod q: {check_exact}")

if not check_exact:
    mismatches = [(i, c_back_coeffs[i], c_direct_mod[i]) for i in range(256) if c_back_coeffs[i] != c_direct_mod[i]]
    print(f"  Mismatches: {len(mismatches)}, first 5: {mismatches[:5]}")

# Check various domain hypotheses for basemul output
print(f"\n=== Basemul output domain ===")
print(f"  c_ntt first 3: {c_ntt_coeffs[:3]}")
print(f"  c_direct_mod first 3: {c_direct_mod[:3]}")

# Is basemul output = NTT(schoolbook) in regular domain?
c_direct_poly = R(c_direct_mod[:])
c_direct_poly.to_ntt()
c_direct_ntt = c_direct_poly.coeffs[:]
check_ntt = all(c_ntt_coeffs[i] == c_direct_ntt[i] for i in range(256))
print(f"  basemul = NTT(schoolbook mod q) [regular]: {check_ntt}")

# Is basemul output = NTT(schoolbook) * R^{-1}?
c_direct_ntt_inv = [(c_direct_ntt[i] * R_inv) % q for i in range(256)]
check_ntt_inv = all(c_ntt_coeffs[i] == c_direct_ntt_inv[i] for i in range(256))
print(f"  basemul = NTT(schoolbook) * R^(-1): {check_ntt_inv}")

# Is basemul output = NTT(schoolbook) * R?
c_direct_ntt_mont = [(c_direct_ntt[i] * R_mod) % q for i in range(256)]
check_ntt_mont = all(c_ntt_coeffs[i] == c_direct_ntt_mont[i] for i in range(256))
print(f"  basemul = NTT(schoolbook) * R: {check_ntt_mont}")

# Is basemul output = NTT(a) * NTT(b) pointwise (regular domain)?
# Compute NTT(a) and NTT(b) separately
a_ntt_sep = R(a_orig[:])
a_ntt_sep.to_ntt()
b_ntt_sep = R(b_orig[:])
b_ntt_sep.to_ntt()

# Pointwise regular multiply
pw_reg = [(a_ntt_sep.coeffs[i] * b_ntt_sep.coeffs[i]) % q for i in range(256)]
check_pw = all(c_ntt_coeffs[i] == pw_reg[i] for i in range(256))
print(f"  basemul = NTT(a) * NTT(b) pointwise [regular]: {check_pw}")

# Pointwise Montgomery multiply: ntt_mul(NTT(a)[i], NTT(b)[i])
from ntt_helper import NTTHelperKyber as H
pw_mont = [H.ntt_mul(a_ntt_sep.coeffs[i], b_ntt_sep.coeffs[i]) for i in range(256)]
check_pw_mont = all(c_ntt_coeffs[i] == pw_mont[i] for i in range(256))
print(f"  basemul = ntt_mul(NTT(a), NTT(b)) pointwise: {check_pw_mont}")

# Print comparison
print(f"\n  NTT(a) first 3: {a_ntt_sep.coeffs[:3]}")
print(f"  NTT(b) first 3: {b_ntt_sep.coeffs[:3]}")
print(f"  basemul first 3: {c_ntt_coeffs[:3]}")
print(f"  NTT(a)*NTT(b) mod q: {pw_reg[:3]}")
print(f"  ntt_mul(NTT(a),NTT(b)): {pw_mont[:3]}")
print(f"  NTT(schoolbook) first 3: {c_direct_ntt[:3]}")