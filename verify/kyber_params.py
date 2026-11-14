"""Compute exact Kyber parameters for RTL"""
q = 3329

# QINV = q^{-1} mod 2^16
qinv = pow(q, -1, 65536)
print(f"QINV (unsigned) = {qinv}")
print(f"QINV (signed)   = {qinv - 65536 if qinv >= 32768 else qinv}")

# Verify: q * QINV mod 2^16 should be 1
print(f"q * QINV mod 2^16 = {(q * qinv) % 65536}")

# R = 2^16 mod q
R = 65536 % q
print(f"\nR = 2^16 mod q = {R}")

# R^{-1} mod q
R_inv = pow(R, -1, q)
print(f"R^(-1) mod q = {R_inv}")

# R^2 mod q
R2 = (R * R) % q
print(f"R^2 mod q = {R2}")

# f = 1441 for INTT scaling
f = 1441
print(f"\nf = 1441 (INTT scaling)")
print(f"f * R^(-1) mod q = {(f * R_inv) % q}")
print(f"R * 128^(-1) mod q = {(R * pow(128, -1, q)) % q}")

# Verify: f = R^2 * 128^{-1} mod q
f_check = (R2 * pow(128, -1, q)) % q
print(f"R^2 * 128^(-1) mod q = {f_check} (should be 1441)")

# Montgomery reduce check
def montgomery_reduce(a):
    """Software Montgomery reduction"""
    t = (a & 0xFFFF) * qinv & 0xFFFF
    return (a - t * q) >> 16

# Test
a, b = 100, 200
prod = a * b
mr = montgomery_reduce(prod)
# mr should equal a * b * R^{-1} mod q
expected = (a * b * R_inv) % q
print(f"\nMontgomery reduce test: a={a}, b={b}")
print(f"  a*b = {prod}")
print(f"  montgomery_reduce(a*b) = {mr}")
print(f"  a*b*R^(-1) mod q = {expected}")
print(f"  match: {mr == expected}")

# fqmul test
def fqmul(a, b):
    return montgomery_reduce(a * b)

# Test with zeta
zeta_mont = 2285  # zetas[0] in Montgomery form
zeta_true = (zeta_mont * R_inv) % q
print(f"\nzeta[0] Montgomery form = {zeta_mont}")
print(f"zeta[0] true value = {zeta_true}")
print(f"fqmul(zeta[0], x) = zeta[0] * x * R^(-1) mod q = true_zeta * x")
x = 100
result = fqmul(zeta_mont, x)
expected2 = (zeta_true * x) % q
print(f"  fqmul({zeta_mont}, {x}) = {result}")
print(f"  true_zeta * x mod q = {expected2}")
print(f"  match: {result == expected2}")

# Barrett reduce
def barrett_reduce(a):
    v = 20159  # ((1<<26) + q/2)/q
    t = (v * a + (1 << 25)) >> 26
    return a - t * q

# Test barrett
a_test = 5000
br = barrett_reduce(a_test)
print(f"\nBarrett reduce: {a_test} -> {br} (should be {a_test % q} or {a_test % q - q})")
print(f"  a mod q = {a_test % q}")
print(f"  a mod q - q = {a_test % q - q}")

# Print all 128 zetas in both signed and unsigned
print("\n=== Zetas (128 entries) ===")
# Reference signed zetas
ZETAS_SIGNED = [
    -1044, -758, -359, -1517, 1493, 1422, 287, 202,
    3158, 622, 1577, 182, 962, 2127, 1855, 1468,
    573, 2004, 264, 383, 2500, 1458, 1727, 3199,
    2648, 1017, 732, 608, 1787, 411, 3124, 1758,
    1223, 652, 2777, 1015, 2036, 1491, 3047, 1785,
    516, 3321, 3009, 2663, 1711, 2167, 126, 1469,
    2476, 3239, 3058, 830, 107, 1908, 3082, 2378,
    2931, 961, 1821, 2604, 448, 2264, 677, 2054,
    2226, 430, 555, 843, 2078, 871, 1550, 105,
    422, 587, 177, 3094, 3038, 2869, 1574, 1653,
    3083, 778, 1159, 3182, 2552, 1483, 2727, 1119,
    1739, 644, 2457, 349, 418, 329, 3173, 3254,
    817, 1097, 603, 610, 1322, 2044, 1864, 384,
    2114, 3193, 1218, 1994, 2455, 220, 2142, 1670,
    2144, 1799, 2051, 794, 1819, 2475, 2459, 478,
    3221, 3021, 996, 991, 958, 1869, 1522, 1628,
]

ZETAS_UNSIGNED = [x if x >= 0 else x + q for x in ZETAS_SIGNED]
print(f"Signed (first 8): {ZETAS_SIGNED[:8]}")
print(f"Unsigned (first 8): {ZETAS_UNSIGNED[:8]}")
print(f"Count: {len(ZETAS_UNSIGNED)}")

# For Verilog: 12-bit unsigned values
print("\n=== Verilog 12-bit unsigned ZETAS ===")
for i in range(0, 128, 16):
    vals = ", ".join(f"12'd{ZETAS_UNSIGNED[i+j]}" for j in range(min(16, 128-i)))
    print(f"    {vals},")