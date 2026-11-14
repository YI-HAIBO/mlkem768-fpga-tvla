# Round-by-round: compare RTL-model intermediate state vs reference intermediate state.
import importlib.util
spec = importlib.util.spec_from_file_location("cf", "compact_fips202.py")
cf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cf)

def ROL64(a, n):
    return ((a >> (64-(n%64))) + (a << (n%64))) % (1<<64)

ROT = [0,1,62,28,27, 36,44,6,55,20, 3,10,25,39,8, 41,45,15,21,14, 18,2,61,56,47]
RC = [0x0000000000000001,0x0000000000008082,0x800000000000808a,0x8000000080008000,
      0x000000000000808b,0x0000000080000001,0x8000000080008081,0x8000000000008009,
      0x000000000000008a,0x0000000000000088,0x0000000080008009,0x000000008000000a,
      0x000000008000808b,0x800000000000008b,0x8000000000008089,0x8000000000008003,
      0x8000000000008002,0x8000000000000080,0x000000000000800a,0x800000008000000a,
      0x8000000080008081,0x8000000000008080,0x0000000080000001,0x8000000080008008]

def rtl_round(A, rnd):
    C = [A[x]^A[x+5]^A[x+10]^A[x+15]^A[x+20] for x in range(5)]
    D = [C[(x+4)%5]^ROL64(C[(x+1)%5],1) for x in range(5)]
    tA = [A[i]^D[i%5] for i in range(25)]
    B = [0]*25
    for x in range(5):
        for y in range(5):
            src = x+5*y
            dst = y+5*((2*x+3*y)%5)
            B[dst] = ROL64(tA[src], ROT[src])
    nA = [0]*25
    for x in range(5):
        for y in range(5):
            dst = x+5*y
            nA[dst] = B[dst] ^ ((~B[((x+1)%5)+5*y]) & B[((x+2)%5)+5*y])
    nA[0] ^= RC[rnd]
    return nA

# reference rounds -> flat 25-lists
lanes = [[0]*5 for _ in range(5)]
ref_states = [[lanes[x][y] for x in range(5) for y in range(5)]]  # dummy, will rebuild
ref_flat = []
flat = [lanes[x][y] for x in range(5) for y in range(5)]
ref_flat.append(flat[:])
R = 1
for round in range(24):
    C = [lanes[x][0]^lanes[x][1]^lanes[x][2]^lanes[x][3]^lanes[x][4] for x in range(5)]
    D = [C[(x+4)%5]^cf.ROL64(C[(x+1)%5],1) for x in range(5)]
    lanes = [[lanes[x][y]^D[x] for y in range(5)] for x in range(5)]
    (x,y) = (1,0); current = lanes[x][y]
    for t in range(24):
        (x,y) = (y,(2*x+3*y)%5)
        (current, lanes[x][y]) = (lanes[x][y], cf.ROL64(current,(t+1)*(t+2)//2))
    for y in range(5):
        T = [lanes[x][y] for x in range(5)]
        for x in range(5):
            lanes[x][y] = T[x]^((~T[(x+1)%5])&T[(x+2)%5])
    for j in range(7):
        R = ((R<<1)^((R>>7)*0x71))%256
        if (R&2):
            lanes[0][0] ^= (1<<((1<<j)-1))
    flat = [lanes[x][y] for x in range(5) for y in range(5)]
    ref_flat.append(flat[:])

# RTL-model rounds
A = [0]*25
rtl_flat = [A[:]]
for rnd in range(24):
    A = rtl_round(A, rnd)
    rtl_flat.append(A[:])

print("round  ref_lane0               rtl_lane0               #diff")
for rnd in range(25):
    d = sum(1 for i in range(25) if ref_flat[rnd][i]!=rtl_flat[rnd][i])
    print("  %2d   %016x  %016x  %d" % (rnd, ref_flat[rnd][0], rtl_flat[rnd][0], d))