"""Test kyber-py NTT multiplication directly"""
import sys
sys.path.insert(0, 'C:/Users/Yi/.workbuddy/binaries/python/envs/default/kyber-py')

from polynomials import PolynomialRing
from ntt_helper import NTTHelperKyber
import random

# Create polynomial ring with NTT helper
R = PolynomialRing(3329, 256, ntt_helper=NTTHelperKyber)

# Test NTT round-trip
random.seed(42)
for test in range(3):
    a = R.random_element()
    a_orig = a.coeffs[:]

    # to_ntt then from_ntt
    a_ntt = a.to_ntt()
    a_back = a_ntt.from_ntt()

    # from_ntt gives Montgomery domain, convert to regular
    a_regular = [NTTHelperKyber.ntt_mul(c, 1) for c in a_back.coeffs]

    match = all(a_regular[i] == a_orig[i] for i in range(256))
    print(f"Round-trip test {test}: {'PASS' if match else 'FAIL'}")
    if not match:
        mismatches = [(i, a_regular[i], a_orig[i]) for i in range(256) if a_regular[i] != a_orig[i]]
        print(f"  Mismatches: {len(mismatches)}, first: {mismatches[:5]}")

# Test NTT multiplication
print("\n=== NTT Multiplication Test ===")
for test in range(5):
    a = R.random_element()
    b = R.random_element()

    # Direct schoolbook multiplication (negacyclic)
    c_direct = a * b
    c_direct_reg = [x % 3329 for x in c_direct.coeffs]

    # NTT-based multiplication
    a_ntt = a.to_ntt()
    b_ntt = b.to_ntt()
    c_ntt_nttform = a_ntt * b_ntt  # calls ntt_multiplication
    c_ntt = c_ntt_nttform.from_ntt()

    # c_ntt is in Montgomery domain, convert to regular
    c_ntt_regular = [NTTHelperKyber.ntt_mul(x, 1) for x in c_ntt.coeffs]

    match = all(c_ntt_regular[i] == c_direct_reg[i] for i in range(256))
    print(f"NTT mul test {test}: {'PASS' if match else 'FAIL'}")
    if not match:
        mismatches = [(i, c_ntt_regular[i], c_direct_reg[i]) for i in range(256) if c_ntt_regular[i] != c_direct_reg[i]]
        print(f"  Mismatches: {len(mismatches)}, first: {mismatches[:5]}")
        print(f"  c_ntt[0:8]: {c_ntt_regular[:8]}")
        print(f"  c_direct[0:8]: {c_direct_reg[:8]}")