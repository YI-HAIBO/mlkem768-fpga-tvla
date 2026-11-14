# Python model that mirrors the RTL keccak_perm.v EXACTLY (post-fix).
# Compare against the verified compact_fips202.py reference, round by round.
import importlib.util
spec = importlib.util.spec_from_file_location("cf", "compact_fips202.py")
cf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cf)

def ROL64(a, n):
    return ((a >> (64-(n%64))) + (a << (n%64))) % (1<<64)

# RTL get_rot table (indexed by lane = x+5*y)
ROT = [0,1,62,28,27, 36,44,6,55,20, 3,10,43,25,39, 41,45,15,21,8, 18,2,61,56,14]
# RTL get_rc table (LFSR-correct, as now in keccak_perm.v)
RC = [0x0000000000000001,0x0000000000008082,0x800000000000808a,0x8000000080008000,
      0x000000000000808b,0x0000000080000001,0x8000000080008081,0x8000000000008009,
      0x000000000000008a,0x0000000000000088,0x0000000080008009,0x000000008000000a,
      0x000000008000808b,0x800000000000008b,0x8000000000008089,0x8000000000008003,
      0x8000000000008002,0x8000000000000080,0x000000000000800a,0x800000008000000a,
      0x8000000080008081,0x8000000000008080,0x0000000080000001,0x8000000080008008]

def rtl_round(A, rnd):
    # theta
    C = [A[x]^A[x+5]^A[x+10]^A[x+15]^A[x+20] for x in range(5)]
    D = [C[(x+4)%5] ^ ROL64(C[(x+1)%5],1) for x in range(5)]
    tA = [A[i]^D[i%5] for i in range(25)]
    # rho+pi
    B = [0]*25
    for x in range(5):
        for y in range(5):
            src = x + 5*y
            dst = y + 5*((2*x+3*y)%5)
            B[dst] = ROL64(tA[src], ROT[src])
    # chi
    nA = [0]*25
    for x in range(5):
        for y in range(5):
            dst = x+5*y
            nA[dst] = B[dst] ^ ((~B[((x+1)%5)+5*y]) & B[((x+2)%5)+5*y])
    # iota
    nA[0] ^= RC[rnd]
    return nA

def rtl_permute(state):
    A = [state[i] for i in range(25)]
    for rnd in range(24):
        A = rtl_round(A, rnd)
    return A

# reference permute(0)
Z = bytearray(200)
Pref = cf.KeccakF1600(Z)
ref = [sum((Pref[i] << (8*i)) for i in range(8*ln, 8*ln+8)) for ln in range(25)]

# RTL-model permute(0)
A = [0]*25
for rnd in range(24):
    A = rtl_round(A, rnd)
got = A

print("lane  ref                  rtl_model             match")
allmatch = True
for ln in range(25):
    m = ref[ln]==got[ln]
    allmatch = allmatch and m
    print("  %2d  %016x  %016x  %s" % (ln, ref[ln], got[ln], "OK" if m else "DIFF"))
print("ALL MATCH" if allmatch else "MISMATCH")