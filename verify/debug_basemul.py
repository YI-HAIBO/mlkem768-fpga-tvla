"""Debug: verify basemul formula and PSI constant.

Key questions:
  1. What is the correct PSI constant? (psi^2 = -1 mod q)
  2. Should basemul use standard or Montgomery multiplication?
  3. What form is the NTT output in?
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
RINV_REF = pow(2, -32, Q)
Rm = R

# ─── Generate Montgomery-form zetas ───
zetas_m = []
for k in range(len(DILITHIUM_ZETAS)):
    zk = (DILITHIUM_ZETAS[k] % Q) * RINV_REF % Q
    zetas_m.append((zk * Rm) % Q)

print("=" * 70)
print("1. FIND CORRECT PSI (sqrt(-1) mod Q)")
print("=" * 70)
# Find psi such that psi^2 = -1 mod Q
for candidate in range(1, Q):
    if (candidate * candidate) % Q == Q - 1:
        print(f"  psi = {candidate}  (psi^2 = -1 mod Q)")
        # Check if 17 is related
        print(f"  17^2 mod Q = {17*17 % Q}")
        print(f"  {candidate} * 17 mod Q = {candidate * 17 % Q}")
        break
else:
    print("  No square root of -1 found!")

# Also check common Dilithium constants
print(f"\n  Common Dilithium constants:")
print(f"  Q - 3250049 = {Q - 3250049}")
print(f"  (Q-3250049)^2 mod Q = {(Q-3250049)**2 % Q}")

# ─── Check what zeta[128] is ───
print(f"\n  zeta[128] (standard) = {DILITHIUM_ZETAS[128]}")
print(f"  zeta[128] (Montgomery) = {zetas_m[128]}")
print(f"  zeta[128]^2 mod Q = {DILITHIUM_ZETAS[128]**2 % Q}")

# ─── The NTT-domain relationship ───
print(f"\n  In NTT: zeta[k] = omega^(k * 2^(L-1)) where omega is primitive 2N-th root")
print(f"  zeta[1] = omega^128 (for N=256, L=8)")
print(f"  omega^256 = 1, omega^128 = -1")
print(f"  zeta[1]^2 = omega^256 = 1")
print(f"  Check: zeta[1]^2 mod Q = {DILITHIUM_ZETAS[1]**2 % Q}")

# Actually, let me check the relationship differently
# zeta[1] should be the primitive 256th root of unity raised to some power
# In the reference NTT, zeta[1] = 41978 (Kyber) or the Dilithium equivalent
# Let me check: omega = zeta[1] (for the first layer)
# omega^2 = zeta[2]? Let me check
print(f"\n  zeta[1] = {DILITHIUM_ZETAS[1]}")
print(f"  zeta[1]^2 mod Q = {DILITHIUM_ZETAS[1]**2 % Q}")
print(f"  zeta[2] = {DILITHIUM_ZETAS[2]}")
print(f"  zeta[1]^2 == zeta[2]? {DILITHIUM_ZETAS[1]**2 % Q == DILITHIUM_ZETAS[2] % Q}")

# Check: zeta[k] = zeta[1]^(2^i * (k - offset)) ?
# Actually, let me check the pattern
print(f"\n  Checking zeta pattern:")
omega = DILITHIUM_ZETAS[1]  # First zeta (should be primitive root)
print(f"  omega = zeta[1] = {omega}")
for k in range(2, 10):
    expected = pow(omega, 2**k, Q) if k < 20 else None
    # Actually, the pattern is more complex. Let me just check powers
    pass

# ─── Test 2: Simple polynomial basemul ───
print("\n" + "=" * 70)
print("2. SIMPLE POLYNOMIAL BASEMUL TEST")
print("=" * 70)

a = [0]*N; a[0] = 1; a[1] = 2
b = [0]*N; b[0] = 3; b[1] = 4

def schoolbook(a, b, q, n=256):
    c = [0] * (2 * n)
    for i in range(n):
        ai = a[i] % q
        if ai:
            for j in range(n):
                c[i + j] += ai * (b[j] % q)
    return [(c[k] - c[k + n]) % q for k in range(n)]

c_school = schoolbook(a, b, Q)
print(f"a = [1, 2, 0, ...]")
print(f"b = [3, 4, 0, ...]")
print(f"Schoolbook c[0..4] = {c_school[0:5]}")

# ─── Compute NTT with Montgomery zetas ───
ntt = RTLNTT(q=Q, bw=BW, layers=8, bm=BM, bsh=SH, scale_k=SCALE_K)

a_ntt, _ = ntt.ntt(zetas_m, a)
b_ntt, _ = ntt.ntt(zetas_m, b)

# Convert to unsigned
def to_u(v):
    return v % Q

a_ntt_u = [to_u(v) for v in a_ntt]
b_ntt_u = [to_u(v) for v in b_ntt]

print(f"\nNTT(a)[0..3] = {a_ntt_u[0:4]}")
print(f"NTT(b)[0..3] = {b_ntt_u[0:4]}")

# ─── Try different PSI values ───
print(f"\n  Testing different PSI values...")

# Find correct psi
psi_candidates = []
for x in range(1, Q):
    if (x * x) % Q == Q - 1:
        psi_candidates.append(x)
        break

# Also try: psi = omega^(N/2) where omega is the primitive root
# omega = zeta[1], N/2 = 128
omega_val = DILITHIUM_ZETAS[1]
psi_from_omega = pow(omega_val, 128, Q)
print(f"  psi from omega^128 = {psi_from_omega}")
print(f"  psi from sqrt(-1)  = {psi_candidates[0] if psi_candidates else 'N/A'}")

# Try all candidate PSI values
for psi in [17, psi_candidates[0], psi_from_omega, (Q-1)] + ([psi_candidates[1]] if len(psi_candidates) > 1 else []):
    if psi is None or psi >= Q:
        continue
    
    # Standard multiplication basemul
    c_std = [0]*N
    for i in range(128):
        ae, ao = a_ntt_u[2*i], a_ntt_u[2*i+1]
        be, bo = b_ntt_u[2*i], b_ntt_u[2*i+1]
        
        p1 = (ae * be) % Q
        p2 = (ao * bo) % Q
        psi_s = (psi * p2) % Q
        p3 = (ae * bo) % Q
        p4 = (ao * be) % Q
        
        c_std[2*i] = (p1 - psi_s) % Q
        c_std[2*i+1] = (p3 + p4) % Q
    
    # INTT
    c_std_signed = [v - Q if v >= Q // 2 else v for v in c_std]
    c_intt, _ = ntt.invntt(zetas_m, c_std_signed)
    
    # INTT output is in Montgomery form (c * R), need R^{-1}
    c_corrected = [(c_intt[i] * Rinv) % Q for i in range(N)]
    
    matches = sum(1 for i in range(N) if c_corrected[i] == c_school[i])
    
    # Also try without R^{-1} (if INTT already gives standard form)
    c_raw_matches = sum(1 for i in range(N) if c_intt[i] % Q == c_school[i])
    
    print(f"  PSI={psi:>10d}: Rinv-corrected={matches}/256, raw={c_raw_matches}/256", end="")
    if matches == N or c_raw_matches == N:
        print(f" *** MATCH! ***")
        if matches == N:
            print(f"    -> INTT output is Montgomery form, needs R^{-1}")
        else:
            print(f"    -> INTT output is standard form, no R^{-1} needed")
    else:
        print()

print()

# ─── Test with Montgomery multiplication basemul ───
print("=" * 70)
print("3. MONTGOMERY MULTIPLICATION BASEMUL TEST")
print("=" * 70)

def fq(a, b):
    """Montgomery multiplication: a * b * R^{-1} mod Q"""
    return (a * b * Rinv) % Q

for psi_val in [17, psi_candidates[0], psi_from_omega]:
    if psi_val is None or psi_val >= Q:
        continue
    
    psi_mont = (psi_val * R) % Q
    
    c_mont = [0]*N
    for i in range(128):
        ae, ao = a_ntt_u[2*i], a_ntt_u[2*i+1]
        be, bo = b_ntt_u[2*i], b_ntt_u[2*i+1]
        
        p1 = fq(ae, be)
        p2 = fq(ao, bo)
        psi_s = fq(p2, psi_mont)
        p3 = fq(ae, bo)
        p4 = fq(ao, be)
        
        c_mont[2*i] = (p1 - psi_s) % Q
        c_mont[2*i+1] = (p3 + p4) % Q
    
    c_mont_signed = [v - Q if v >= Q // 2 else v for v in c_mont]
    c_intt, _ = ntt.invntt(zetas_m, c_mont_signed)
    
    c_corrected = [(c_intt[i] * Rinv) % Q for i in range(N)]
    c_raw = [c_intt[i] % Q for i in range(N)]
    
    matches = sum(1 for i in range(N) if c_corrected[i] == c_school[i])
    raw_matches = sum(1 for i in range(N) if c_raw[i] == c_school[i])
    
    print(f"  psi={psi_val:>10d} (mont={psi_mont}): Rinv-corrected={matches}/256, raw={raw_matches}/256", end="")
    if matches == N or raw_matches == N:
        print(f" *** MATCH! ***")
    else:
        print()

print()

# ─── Detailed trace for the correct PSI ───
print("=" * 70)
print("4. DETAILED TRACE (simple polynomial, correct PSI)")
print("=" * 70)

psi = psi_candidates[0]
print(f"Using PSI = {psi}")
print(f"PSI * R mod Q = {psi * R % Q} (Montgomery form)")

# Standard multiplication basemul
c_std = [0]*N
for i in range(4):  # Just show first 4 pairs
    ae, ao = a_ntt_u[2*i], a_ntt_u[2*i+1]
    be, bo = b_ntt_u[2*i], b_ntt_u[2*i+1]
    
    p1 = (ae * be) % Q
    p2 = (ao * bo) % Q
    psi_s = (psi * p2) % Q
    p3 = (ae * bo) % Q
    p4 = (ao * be) % Q
    
    c_even = (p1 - psi_s) % Q
    c_odd = (p3 + p4) % Q
    
    c_std[2*i] = c_even
    c_std[2*i+1] = c_odd
    
    print(f"  Pair {i}: ae={ae}, ao={ao}, be={be}, bo={bo}")
    print(f"    p1=ae*be={p1}, p2=ao*bo={p2}, psi*p2={psi_s}")
    print(f"    p3=ae*bo={p3}, p4=ao*be={p4}")
    print(f"    c_even={c_even}, c_odd={c_odd}")

# Complete basemul
for i in range(128):
    ae, ao = a_ntt_u[2*i], a_ntt_u[2*i+1]
    be, bo = b_ntt_u[2*i], b_ntt_u[2*i+1]
    p1 = (ae * be) % Q
    p2 = (ao * bo) % Q
    psi_s = (psi * p2) % Q
    p3 = (ae * bo) % Q
    p4 = (ao * be) % Q
    c_std[2*i] = (p1 - psi_s) % Q
    c_std[2*i+1] = (p3 + p4) % Q

c_std_signed = [v - Q if v >= Q // 2 else v for v in c_std]
c_intt, _ = ntt.invntt(zetas_m, c_std_signed)
c_corrected = [(c_intt[i] * Rinv) % Q for i in range(N)]

print(f"\n  Schoolbook c[0..4] = {c_school[0:5]}")
print(f"  INTT raw   c[0..4] = {[c_intt[i] % Q for i in range(5)]}")
print(f"  INTT*Rinv  c[0..4] = {c_corrected[0:5]}")

matches = sum(1 for i in range(N) if c_corrected[i] == c_school[i])
print(f"  Matches (Rinv-corrected): {matches}/256")

# ─── Final: verify with random polynomials ───
print("\n" + "=" * 70)
print("5. RANDOM POLYNOMIAL VERIFICATION")
print("=" * 70)

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
    
    c_r = [0]*N
    for i in range(128):
        ae, ao = a_ntt_ru[2*i], a_ntt_ru[2*i+1]
        be, bo = b_ntt_ru[2*i], b_ntt_ru[2*i+1]
        p1 = (ae * be) % Q
        p2 = (ao * bo) % Q
        psi_s = (psi * p2) % Q
        p3 = (ae * bo) % Q
        p4 = (ao * be) % Q
        c_r[2*i] = (p1 - psi_s) % Q
        c_r[2*i+1] = (p3 + p4) % Q
    
    c_r_signed = [v - Q if v >= Q // 2 else v for v in c_r]
    c_intt_r, _ = ntt.invntt(zetas_m, c_r_signed)
    c_corrected_r = [(c_intt_r[i] * Rinv) % Q for i in range(N)]
    
    matches_r = sum(1 for i in range(N) if c_corrected_r[i] == c_r_school[i])
    status = "PASS" if matches_r == N else "FAIL"
    if matches_r != N:
        all_pass = False
    print(f"  Trial {trial}: {matches_r}/256 {status}")

print(f"\n  Overall: {'ALL PASS' if all_pass else 'SOME FAILED'}")
