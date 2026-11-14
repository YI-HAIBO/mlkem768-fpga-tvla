"""Verify: pointwise NTT-domain multiplication + INTT gives schoolbook * R."""
import sys, os, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ntt_model import RTLNTT, DILITHIUM_ZETAS

Q = 8380417
N = 256
BW = 27
R = pow(2, BW, Q)
Rinv = pow(R, -1, Q)
SCALE_K = 49145
BM = 33587228
SH = 48
RINV_REF = pow(2, -32, Q)
Rm = R

zetas_m = []
for k in range(len(DILITHIUM_ZETAS)):
    zk = (DILITHIUM_ZETAS[k] % Q) * RINV_REF % Q
    zetas_m.append((zk * Rm) % Q)

ntt = RTLNTT(q=Q, bw=BW, layers=8, bm=BM, bsh=SH, scale_k=SCALE_K)

def schoolbook(a, b, q, n=256):
    c = [0] * (2 * n)
    for i in range(n):
        ai = a[i] % q
        if ai:
            for j in range(n):
                c[i + j] += ai * (b[j] % q)
    return [(c[k] - c[k + n]) % q for k in range(n)]

def to_u(v):
    return v % Q

print("=" * 60)
print("TEST: Pointwise NTT-domain multiplication")
print("=" * 60)

# Simple test
a = [0]*N; a[0] = 1; a[1] = 2
b = [0]*N; b[0] = 3; b[1] = 4
c_school = schoolbook(a, b, Q)

print(f"a = [1, 2, 0, ...]")
print(f"b = [3, 4, 0, ...]")
print(f"Schoolbook c[0..4] = {c_school[0:5]}")

# NTT
a_ntt, _ = ntt.ntt(zetas_m, a)
b_ntt, _ = ntt.ntt(zetas_m, b)

a_ntt_u = [to_u(v) for v in a_ntt]
b_ntt_u = [to_u(v) for v in b_ntt]

print(f"NTT(a)[0..3] = {a_ntt_u[0:4]}")
print(f"NTT(b)[0..3] = {b_ntt_u[0:4]}")

# Pointwise multiplication (standard, NOT fqmul)
c_ntt_u = [(a_ntt_u[i] * b_ntt_u[i]) % Q for i in range(N)]
c_ntt_signed = [v - Q if v >= Q // 2 else v for v in c_ntt_u]

# INTT
c_intt, _ = ntt.invntt(zetas_m, c_ntt_signed)

# INTT output is schoolbook * R (Montgomery form)
# To get schoolbook, multiply by R^{-1}
c_corrected = [(c_intt[i] * Rinv) % Q for i in range(N)]

matches = sum(1 for i in range(N) if c_corrected[i] == c_school[i])
print(f"\nINTT output vs schoolbook (raw):     {sum(1 for i in range(N) if c_intt[i] % Q == c_school[i])}/{N}")
print(f"INTT output * R^{-1} vs schoolbook:  {matches}/{N}")
print(f"Corrected c[0..4] = {c_corrected[0:5]}")
print(f"Schoolbook c[0..4] = {c_school[0:5]}")

if matches == N:
    print("\n>>> POINTWISE MULTIPLICATION CONFIRMED! <<<")
    print("Use standard multiplication (NOT fqmul) for NTT-domain product.")
    print("INTT output is in Montgomery form (schoolbook * R).")
    print(f"Apply R^{-1} = {Rinv} to get standard form.")
else:
    print("\n>>> POINTWISE MULTIPLICATION FAILED <<<")
    print("Need to investigate further.")

# Random verification
print("\n" + "=" * 60)
print("RANDOM VERIFICATION (10 trials)")
print("=" * 60)

random.seed(42)
all_pass = True
for trial in range(10):
    a_r = [random.randint(0, Q-1) for _ in range(N)]
    b_r = [random.randint(0, Q-1) for _ in range(N)]
    c_r_school = schoolbook(a_r, b_r, Q)
    
    a_ntt_r, _ = ntt.ntt(zetas_m, a_r)
    b_ntt_r, _ = ntt.ntt(zetas_m, b_r)
    a_ntt_ru = [to_u(v) for v in a_ntt_r]
    b_ntt_ru = [to_u(v) for v in b_ntt_r]
    
    # Pointwise multiplication
    c_r_ntt = [(a_ntt_ru[i] * b_ntt_ru[i]) % Q for i in range(N)]
    c_r_signed = [v - Q if v >= Q // 2 else v for v in c_r_ntt]
    
    c_intt_r, _ = ntt.invntt(zetas_m, c_r_signed)
    c_corrected_r = [(c_intt_r[i] * Rinv) % Q for i in range(N)]
    
    matches_r = sum(1 for i in range(N) if c_corrected_r[i] == c_r_school[i])
    status = "PASS" if matches_r == N else "FAIL"
    if matches_r != N:
        all_pass = False
    print(f"  Trial {trial}: {matches_r}/256 {status}")

print(f"\n  Overall: {'ALL PASS' if all_pass else 'SOME FAILED'}")
