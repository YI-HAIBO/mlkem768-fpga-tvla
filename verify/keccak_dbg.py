MASK64 = (1 << 64) - 1

def rol(x, n):
    n %= 64
    if n == 0:
        return x & MASK64
    return ((x << n) | (x >> (64 - n))) & MASK64

RC = [0x0000000000000001,0x0000000000008082,0x800000000000808A,0x8000000080008000,
      0x000000000000808B,0x0000000080000001,0x8000000080008081,0x8000000000008009,
      0x000000000000008A,0x0000000000000088,0x0000000080008009,0x000000008000000A,
      0x000000008000808B,0x800000000000008B,0x8000000000008089,0x8000000000008003,
      0x8000000000008002,0x8000000000000080,0x800000008000800A,0x800000008000000A,
      0x8000000080008081,0x8000000080008009,0x000000000000008B,0x800000000000808B]

R = [
    [0,  36, 3,  41, 18],
    [1,  44, 10, 45, 2],
    [62, 6,  25, 15, 61],
    [28, 55, 39, 21, 14],
    [18, 2,  61, 56, 47],
]

def show(S, tag):
    print(tag, "lane0=%016x lane1=%016x" % (S[0][0] & MASK64, S[1][0] & MASK64))

def permute_debug(S):
    for rnd in range(24):
        C = [S[x][0]^S[x][1]^S[x][2]^S[x][3]^S[x][4] for x in range(5)]
        D = [C[(x+4)%5] ^ rol(C[(x+1)%5], 1) for x in range(5)]
        for x in range(5):
            for y in range(5):
                S[x][y] ^= D[x]
        if rnd == 0:
            show(S, "after-theta r0")
        B = [[0]*5 for _ in range(5)]
        for x in range(5):
            for y in range(5):
                B[(2*x+3*y)%5][y] = rol(S[x][y], R[x][y])
        if rnd == 0:
            show(B, "after-rho+pi r0")
        for x in range(5):
            for y in range(5):
                S[x][y] = B[x][y] ^ ((~B[(x+1)%5][y] & MASK64) & B[(x+2)%5][y])
        if rnd == 0:
            show(S, "after-chi r0")
        S[0][0] ^= RC[rnd]
        if rnd == 0:
            show(S, "after-iota r0")
    return S

Z = [[0]*5 for _ in range(5)]
permute_debug(Z)
print("final lane0=%016x" % (Z[0][0] & MASK64))
print("expected      290abe210988bce3...")
