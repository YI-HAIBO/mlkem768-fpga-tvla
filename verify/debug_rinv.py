"""Debug: verify R^{-1} correction for INTT output (Montgomery -> standard form).

Tests both zeta representations:
  A) Standard-form zetas (DILITHIUM_ZETAS) — what ntt_model.py uses internally
  B) Montgomery-form zetas (zetas_m) — what gen_sign_params.py generates for RTL
"""
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
PSI = 17
PSI_MONT = (PSI * R) % Q  # 2227952
RINV_REF = pow(2, -32, Q)  # 2^{-32} mod q (reference Montgomery inverse)
Rm = R  # 2^{27} mod q

print("=" * 70)
print("KEY CONSTANTS")
print("=" * 70)
print(f"Q = {Q}")
print(f"BW = {BW}, R = 2^{BW} mod Q = {R}")
print(f"Rinv = R^{-1} mod Q = {Rinv}")
print(f"SCALE_K = {SCALE_K}")
print(f"PSI_MONT = 17*R mod Q = {PSI_MONT}")
print(f"R^2 mod Q = {R*R % Q}")
print(f"R^18 mod Q = {pow(R, 18, Q)}")
print(f"R^17 mod Q = {pow(R, 17, Q)}")
print()

# ─── Generate Montgomery-form zetas (same as gen_sign_params.py) ───
zetas_m = []
for k in range(len(DILITHIUM_ZETAS)):
    zk = (DILITHIUM_ZETAS[k] % Q) * RINV_REF % Q  # true ring twiddle
    zetas_m.append((zk * Rm) % Q)

print("=" * 70)
print("ZETA COMPARISON (first 5)")
print("=" * 70)
print(f"DILITHIUM_ZETAS[0..4] (standard) = {DILITHIUM_ZETAS[0:5]}")
print(f"zetas_m[0..4]       (Montgomery)  = {zetas_m[0:5]}")
print()

# ─── Test 1: NTT/INTT round-trip with standard-form zetas ───
print("=" * 70)
print("TEST 1: NTT/INTT round-trip (standard zetas)")
print("=" * 70)
ntt_std = RTLNTT(q=Q, bw=BW, layers=8, bm=BM, bsh=SH, scale_k=SCALE_K)
random.seed(42)
f = [random.randint(0, Q-1) for _ in range(N)]
out_std, _ = ntt_std.ntt(DILITHIUM_ZETAS, f)
back_std, _ = ntt_std.invntt(DILITHIUM_ZETAS, out_std)

# Check if output is f * R (Montgomery form)
mont_ok = sum(1 for i in range(N) if back_std[i] % Q == (f[i] * R) % Q)
# Check if output is f (standard form)
std_ok = sum(1 for i in range(N) if back_std[i] % Q == f[i])
print(f"Round-trip output vs f*R (Montgomery): {mont_ok}/{N}")
print(f"Round-trip output vs f   (standard):   {std_ok}/{N}")
print()

# ─── Test 2: NTT/INTT round-trip with Montgomery-form zetas ───
print("=" * 70)
print("TEST 2: NTT/INTT round-trip (Montgomery zetas)")
print("=" * 70)
ntt_mont = RTLNTT(q=Q, bw=BW, layers=8, bm=BM, bsh=SH, scale_k=SCALE_K)
f2 = [random.randint(0, Q-1) for _ in range(N)]
out_m, _ = ntt_mont.ntt(zetas_m, f2)
back_m, _ = ntt_mont.invntt(zetas_m, out_m)

mont_ok2 = sum(1 for i in range(N) if back_m[i] % Q == (f2[i] * R) % Q)
std_ok2 = sum(1 for i in range(N) if back_m[i] % Q == f2[i])
print(f"Round-trip output vs f*R (Montgomery): {mont_ok2}/{N}")
print(f"Round-trip output vs f   (standard):   {std_ok2}/{N}")
print()

# ─── Test 3: Full NTT+basemul+INTT pipeline ───
print("=" * 70)
print("TEST 3: Full NTT+basemul+INTT (standard zetas)")
print("=" * 70)

def schoolbook(a, b, q, n=256):
    c = [0] * (2 * n)
    for i in range(n):
        ai = a[i] % q
        if ai:
            for j in range(n):
                c[i + j] += ai * (b[j] % q)
    return [(c[k] - c[k + n]) % q for k in range(n)]

def to_unsigned(v, q=Q):
    return v % q

def fq(a, b):
    """Montgomery multiplication: a * b * R^{-1} mod Q"""
    return (a * b * Rinv) % Q

random.seed(42)
a = [random.randint(0, Q-1) for _ in range(N)]
b = [random.randint(0, Q-1) for _ in range(N)]
c_school = schoolbook(a, b, Q)

print(f"Schoolbook c[0..4] = {c_school[0:5]}")

# NTT
a_ntt, _ = ntt_std.ntt(DILITHIUM_ZETAS, a)
b_ntt, _ = ntt_std.ntt(DILITHIUM_ZETAS, b)

# Basemul using Montgomery multiplication
a_ntt_u = [to_unsigned(v) for v in a_ntt]
b_ntt_u = [to_unsigned(v) for v in b_ntt]

c_ntt_u = [0] * N
for i in range(128):
    ae, ao = a_ntt_u[2*i], a_ntt_u[2*i+1]
    be, bo = b_ntt_u[2*i], b_ntt_u[2*i+1]
    
    p1 = fq(ae, be)
    p2 = fq(ao, bo)
    psi_s = fq(p2, PSI_MONT)
    p3 = fq(ae, bo)
    p4 = fq(ao, be)
    
    c_ntt_u[2*i] = (p1 - psi_s) % Q
    c_ntt_u[2*i+1] = (p3 + p4) % Q

# Convert to signed for INTT
c_ntt_signed = [v - Q if v >= Q // 2 else v for v in c_ntt_u]

# INTT
c_intt, _ = ntt_std.invntt(DILITHIUM_ZETAS, c_ntt_signed)

# Compare raw INTT output (Montgomery form) vs schoolbook
raw_matches = sum(1 for i in range(N) if c_intt[i] % Q == c_school[i])
print(f"INTT output vs schoolbook (raw):     {raw_matches}/{N}")

# Apply R^{-1} correction
c_corrected = [(c_intt[i] * Rinv) % Q for i in range(N)]
rinv_matches = sum(1 for i in range(N) if c_corrected[i] == c_school[i])
print(f"INTT output * R^{-1} vs schoolbook:  {rinv_matches}/{N}")
print(f"Corrected c[0..4] = {c_corrected[0:5]}")

if raw_matches < N and rinv_matches == N:
    print(">>> R^{-1} CORRECTION CONFIRMED: INTT output is in Montgomery form <<<")
print()

# ─── Test 4: Same with Montgomery-form zetas ───
print("=" * 70)
print("TEST 4: Full NTT+basemul+INTT (Montgomery zetas)")
print("=" * 70)

a_ntt_m, _ = ntt_mont.ntt(zetas_m, a)
b_ntt_m, _ = ntt_mont.ntt(zetas_m, b)

a_ntt_m_u = [to_unsigned(v) for v in a_ntt_m]
b_ntt_m_u = [to_unsigned(v) for v in b_ntt_m]

c_ntt_m_u = [0] * N
for i in range(128):
    ae, ao = a_ntt_m_u[2*i], a_ntt_m_u[2*i+1]
    be, bo = b_ntt_m_u[2*i], b_ntt_m_u[2*i+1]
    
    p1 = fq(ae, be)
    p2 = fq(ao, bo)
    psi_s = fq(p2, PSI_MONT)
    p3 = fq(ae, bo)
    p4 = fq(ao, be)
    
    c_ntt_m_u[2*i] = (p1 - psi_s) % Q
    c_ntt_m_u[2*i+1] = (p3 + p4) % Q

c_ntt_m_signed = [v - Q if v >= Q // 2 else v for v in c_ntt_m_u]

c_intt_m, _ = ntt_mont.invntt(zetas_m, c_ntt_m_signed)

raw_matches_m = sum(1 for i in range(N) if c_intt_m[i] % Q == c_school[i])
print(f"INTT output vs schoolbook (raw):     {raw_matches_m}/{N}")

c_corrected_m = [(c_intt_m[i] * Rinv) % Q for i in range(N)]
rinv_matches_m = sum(1 for i in range(N) if c_corrected_m[i] == c_school[i])
print(f"INTT output * R^{-1} vs schoolbook:  {rinv_matches_m}/{N}")
print(f"Corrected c[0..4] = {c_corrected_m[0:5]}")

if raw_matches_m < N and rinv_matches_m == N:
    print(">>> R^{-1} CORRECTION CONFIRMED (Montgomery zetas too) <<<")
print()

# ─── Test 5: Verify basemul semantics ───
print("=" * 70)
print("TEST 5: Verify basemul with simple polynomials")
print("=" * 70)

a_simple = [0]*N; a_simple[0] = 1; a_simple[1] = 2
b_simple = [0]*N; b_simple[0] = 3; b_simple[1] = 4
c_simple = schoolbook(a_simple, b_simple, Q)
print(f"a = [1, 2, 0, ...]")
print(f"b = [3, 4, 0, ...]")
print(f"Schoolbook c[0..4] = {c_simple[0:5]}")
# Expected: c[0] = 1*3 + 2*(-4) [wrap] = 3 - 8 = -5 mod Q = Q-5
# Actually negacyclic: c[k] = sum a[i]*b[(k-i) mod N]
# c[0] = a[0]*b[0] + a[1]*b[N-1] + ... = 1*3 = 3 (since b[N-1]=0)
# c[1] = a[0]*b[1] + a[1]*b[0] = 1*4 + 2*3 = 10
# c[2] = a[0]*b[2] + a[1]*b[1] = 0 + 2*4 = 8
# c[255] = a[0]*b[255] + a[1]*b[254] + a[255]*b[0] + a[254]*b[1] = 0 + 0 + 0 + 0 = 0

# Actually let me check negacyclic properly
# c[k] = sum_{i=0}^{255} a[i] * b[(k-i) mod 256]
# For k=0: a[0]*b[0] + a[1]*b[255] + a[255]*b[1] + ...
# = 1*3 + 2*0 + 0*4 + ... = 3
# For k=1: a[0]*b[1] + a[1]*b[0] = 1*4 + 2*3 = 10
# For k=2: a[0]*b[2] + a[1]*b[1] = 0 + 2*4 = 8
# For k=255: a[1]*b[254] + a[254]*b[1] + a[255]*b[0] = 0 + 0 + 0 = 0

print(f"Expected: c[0]=3, c[1]=10, c[2]=8")

# Full pipeline
a_ntt_s, _ = ntt_std.ntt(DILITHIUM_ZETAS, a_simple)
b_ntt_s, _ = ntt_std.ntt(DILITHIUM_ZETAS, b_simple)

a_ntt_su = [to_unsigned(v) for v in a_ntt_s]
b_ntt_su = [to_unsigned(v) for v in b_ntt_s]

c_ntt_su = [0] * N
for i in range(128):
    ae, ao = a_ntt_su[2*i], a_ntt_su[2*i+1]
    be, bo = b_ntt_su[2*i], b_ntt_su[2*i+1]
    
    p1 = fq(ae, be)
    p2 = fq(ao, bo)
    psi_s = fq(p2, PSI_MONT)
    p3 = fq(ae, bo)
    p4 = fq(ao, be)
    
    c_ntt_su[2*i] = (p1 - psi_s) % Q
    c_ntt_su[2*i+1] = (p3 + p4) % Q

c_ntt_ss = [v - Q if v >= Q // 2 else v for v in c_ntt_su]
c_intt_s, _ = ntt_std.invntt(DILITHIUM_ZETAS, c_ntt_ss)

raw_s = sum(1 for i in range(N) if c_intt_s[i] % Q == c_simple[i])
rinv_s = [(c_intt_s[i] * Rinv) % Q for i in range(N)]
rinv_s_ok = sum(1 for i in range(N) if rinv_s[i] == c_simple[i])
print(f"Raw INTT vs schoolbook:     {raw_s}/{N}")
print(f"INTT*R^{-1} vs schoolbook:  {rinv_s_ok}/{N}")
print(f"Corrected c[0..4] = {rinv_s[0:5]}")

print()
print("=" * 70)
print("CONCLUSION")
print("=" * 70)
print("The INTT output is in Montgomery form (c * R mod Q).")
print(f"To convert to standard form, multiply by R^{-1} = {Rinv}.")
print("This correction must be added to dilithium_ntt.v S_READ_OUT state.")
