import hashlib, itertools

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

# standard rho offsets r[x][y], x=col, y=row (FIPS 202)
RSTD = [
    [0,  36, 3,  41, 18],
    [1,  44, 10, 45, 2],
    [62, 6,  25, 15, 61],
    [28, 55, 39, 21, 14],
    [27, 20, 8,  14, 47],
]
# transposed: r[y][x]
RTR = list(map(list, zip(*RSTD)))

def permute(S, pi, R):
    for rnd in range(24):
        C = [S[x][0]^S[x][1]^S[x][2]^S[x][3]^S[x][4] for x in range(5)]
        D = [C[(x+4)%5] ^ rol(C[(x+1)%5], 1) for x in range(5)]
        for x in range(5):
            for y in range(5):
                S[x][y] ^= D[x]
        B = [[0]*5 for _ in range(5)]
        for x in range(5):
            for y in range(5):
                dx, dy = pi(x, y)
                B[dx][dy] = rol(S[x][y], R[x][y])
        for x in range(5):
            for y in range(5):
                S[x][y] = B[x][y] ^ ((~B[(x+1)%5][y] & MASK64) & B[(x+2)%5][y])
        S[0][0] ^= RC[rnd]
    return S

def lanes_to_bytes(S):
    out = bytearray(200)
    for x in range(5):
        for y in range(5):
            v = S[x][y] & MASK64
            out[8*(x+5*y):8*(x+5*y)+8] = v.to_bytes(8, 'little')
    return bytes(out)

def bytes_to_lanes(b):
    S = [[0]*5 for _ in range(5)]
    for x in range(5):
        for y in range(5):
            S[x][y] = int.from_bytes(b[8*(x+5*y):8*(x+5*y)+8], 'little')
    return S

def shake(msg, rate, pi, R):
    S = [[0]*5 for _ in range(5)]
    ml = len(msg); nb = ml // rate; rem = ml - nb*rate
    for bblk in range(nb):
        blk = bytes_to_lanes(msg[bblk*rate:(bblk+1)*rate] + b'\x00'*(200-rate))
        for x in range(5):
            for y in range(5):
                S[x][y] ^= blk[x][y]
        permute(S, pi, R)
    last = bytearray(msg[nb*rate:nb*rate+rem]); last += bytes([0x1F])
    while len(last) < rate: last += b'\x00'
    last[rate-1] ^= 0x80
    blk = bytes_to_lanes(bytes(last) + b'\x00'*(200-rate))
    for x in range(5):
        for y in range(5):
            S[x][y] ^= blk[x][y]
    permute(S, pi, R)
    out = bytearray()
    while len(out) < 32:
        out += lanes_to_bytes(S)[:rate]
        if len(out) < 32:
            permute(S, pi, R)
    return bytes(out[:32])

# pi destination candidates: source (x=col, y=row) -> (dx, dy)
PI = {
    'FIPS_B[y,2x+3y]': lambda x,y: (y, (2*x+3*y)%5),          # B[col=y][row=2x+3y]
    'B[2x+3y][y]':      lambda x,y: ((2*x+3*y)%5, y),        # B[col=2x+3y][row=y]
    'B[y][(2x+3y)]':    lambda x,y: (y, (2*x+3*y)%5),        # same as FIPS
    'B[2x+3y][y]_swap': lambda x,y: ((2*y+3*x)%5, y),
    'B[y][2x+3y]_swap': lambda x,y: (y, (2*y+3*x)%5),
}

exp = hashlib.shake_256(b"").digest(32)
print("target SHAKE-256('')[:8] =", exp[:8].hex())
for pname, pi in PI.items():
    for rname, R in [('RSTD', RSTD), ('RTR', RTR)]:
        got = shake(b"", 136, pi, R)
        same = got == exp
        print("  pi=%-18s R=%-4s -> %s  %s" % (pname, rname, got[:8].hex(), "MATCH" if same else ""))