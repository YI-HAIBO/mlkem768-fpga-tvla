"""Debug: compute NTT+basemul+INTT using Python model, compare with schoolbook."""
import sys, os
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

ntt = RTLNTT(q=Q, bw=BW, layers=8, bm=BM, bsh=SH, scale_k=SCALE_K)

# Simple test: a = [1,2,0,...], b = [3,4,0,...]
a = [0]*N; a[0] = 1; a[1] = 2
b = [0]*N; b[0] = 3; b[1] = 4

# Schoolbook negacyclic convolution
c_school = [0]*N
for k in range(N):
    s = 0
    for i in range(N):
        s += a[i] * b[(k-i) % N]
    c_school[k] = s % Q

print(f"Schoolbook: c[0]={c_school[0]}, c[1]={c_school[1]}, c[2]={c_school[2]}")

# NTT
a_ntt, _ = ntt.ntt(DILITHIUM_ZETAS, a)
b_ntt, _ = ntt.ntt(DILITHIUM_ZETAS, b)

print(f"NTT(a): a_ntt[0]={a_ntt[0]}, a_ntt[1]={a_ntt[1]}")
print(f"NTT(b): b_ntt[0]={b_ntt[0]}, b_ntt[1]={b_ntt[1]}")

# Convert to unsigned [0, q-1] for basemul
def to_unsigned(v):
    if v < 0:
        return v + Q
    return v

a_ntt_u = [to_unsigned(v) for v in a_ntt]
b_ntt_u = [to_unsigned(v) for v in b_ntt]

# Basemul using fq (Montgomery multiplication)
def fq(a, b):
    return (a * b * Rinv) % Q

c_ntt_u = [0]*N
for i in range(128):
    ae = a_ntt_u[2*i]
    ao = a_ntt_u[2*i+1]
    be = b_ntt_u[2*i]
    bo = b_ntt_u[2*i+1]
    
    p1 = fq(ae, be)
    p2 = fq(ao, bo)
    p3 = fq(ae, bo)
    p4 = fq(ao, be)
    psi_s = fq(p2, PSI_MONT)
    
    c_ntt_u[2*i] = (p1 - psi_s) % Q
    c_ntt_u[2*i+1] = (p3 + p4) % Q

# Convert back to signed for INTT
c_ntt_signed = []
for v in c_ntt_u:
    if v >= Q // 2:
        c_ntt_signed.append(v - Q)
    else:
        c_ntt_signed.append(v)

# INTT
c_intt, _ = ntt.invntt(DILITHIUM_ZETAS, c_ntt_signed)

print(f"INTT result: c[0]={c_intt[0]}, c[1]={c_intt[1]}, c[2]={c_intt[2]}")
print(f"Schoolbook:  c[0]={c_school[0]}, c[1]={c_school[1]}, c[2]={c_school[2]}")

# Compare
matches = sum(1 for i in range(N) if c_intt[i] % Q == c_school[i])
print(f"Matches: {matches}/{N}")

# Check if the issue is R factor
print(f"\nR = {R}, Rinv = {Rinv}")
print(f"SCALE_K = {SCALE_K}")
print(f"SCALE_K * R = {SCALE_K * R % Q}")
print(f"SCALE_K * Rinv = {SCALE_K * Rinv % Q}")

# Try without fq (standard mul)
c_ntt_std = [0]*N
for i in range(128):
    ae = a_ntt_u[2*i]
    ao = a_ntt_u[2*i+1]
    be = b_ntt_u[2*i]
    bo = b_ntt_u[2*i+1]
    
    p1 = (ae * be) % Q
    p2 = (ao * bo) % Q
    p3 = (ae * bo) % Q
    p4 = (ao * be) % Q
    psi_s = (p2 * PSI) % Q  # standard psi, not psi_mont
    
    c_ntt_std[2*i] = (p1 - psi_s) % Q
    c_ntt_std[2*i+1] = (p3 + p4) % Q

c_ntt_std_signed = []
for v in c_ntt_std:
    if v >= Q // 2:
        c_ntt_std_signed.append(v - Q)
    else:
        c_ntt_std_signed.append(v)

c_intt_std, _ = ntt.invntt(DILITHIUM_ZETAS, c_ntt_std_signed)
matches_std = sum(1 for i in range(N) if c_intt_std[i] % Q == c_school[i])
print(f"\nStandard mul basemul matches: {matches_std}/{N}")
