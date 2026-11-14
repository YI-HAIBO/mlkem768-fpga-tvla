import hashlib

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

# Rotation offsets r[row][col] (KeccakCodePackage convention: A[row][col], row fast)
#         col=0 col=1 col=2 col=3 col=4
# row=0:    0    1   62   28   27
# row=1:   36   44    6   55   20
# row=2:    3   10   25   39    8
# row=3:   41   45   15   21   14
# row=4:   18    2   61   56   47
R = [
    [0,  1,  62, 28, 27],
    [36, 44, 6,  55, 20],
    [3,  10, 25, 39, 8 ],
    [41, 45, 15, 21, 14],
    [18, 2,  61, 56, 47],
]

def permute(S):
    # S is 5x5, S[row][col]; linear lane = 5*row + col, col fast (FIPS byte layout)
    for rnd in range(24):
        # theta (C over columns, D indexed by row)
        C = [S[r][0]^S[r][1]^S[r][2]^S[r][3]^S[r][4] for r in range(5)]
        D = [C[(r+4)%5] ^ rol(C[(r+1)%5], 1) for r in range(5)]
        for r in range(5):
            for c in range(5):
                S[r][c] ^= D[r]
        # rho + pi  (KeccakCodePackage: B[(2*row+3*col)%5][col] = ROT(A[row][col], r[row][col]))
        B = [[0]*5 for _ in range(5)]
        for r in range(5):
            for c in range(5):
                B[(2*r+3*c)%5][c] = rol(S[r][c], R[r][c])
        # chi
        for r in range(5):
            for c in range(5):
                S[r][c] = B[r][c] ^ ((~B[(r+1)%5][c] & MASK64) & B[(r+2)%5][c])
        # iota
        S[0][0] ^= RC[rnd]
    return S

def lanes_to_bytes(S):
    out = bytearray(200)
    for r in range(5):
        for c in range(5):
            v = S[r][c] & MASK64
            out[8*(5*r+c):8*(5*r+c)+8] = v.to_bytes(8, 'little')
    return bytes(out)

def bytes_to_lanes(b):
    S = [[0]*5 for _ in range(5)]
    for r in range(5):
        for c in range(5):
            S[r][c] = int.from_bytes(b[8*(5*r+c):8*(5*r+c)+8], 'little')
    return S

def _sponge(msg, rate, typ):
    S = [[0]*5 for _ in range(5)]
    ml = len(msg)
    nb = ml // rate
    rem = ml - nb*rate
    for bblk in range(nb):
        blk = bytes_to_lanes(msg[bblk*rate:(bblk+1)*rate] + b'\x00'*(200 - rate))
        for r in range(5):
            for c in range(5):
                S[r][c] ^= blk[r][c]
        permute(S)
    last = bytearray(msg[nb*rate:nb*rate+rem])
    last += bytes([0x1F])
    while len(last) < rate:
        last += b'\x00'
    last[rate-1] ^= 0x80
    blk = bytes_to_lanes(bytes(last) + b'\x00'*(200 - rate))
    for r in range(5):
        for c in range(5):
            S[r][c] ^= blk[r][c]
    permute(S)
    out = bytearray()
    while len(out) < (lambda n: n)(1):  # placeholder, replaced below
        pass
    return S

def shake256(msg, out_len):
    rate = 136
    S = [[0]*5 for _ in range(5)]
    ml = len(msg); nb = ml // rate; rem = ml - nb*rate
    for bblk in range(nb):
        blk = bytes_to_lanes(msg[bblk*rate:(bblk+1)*rate] + b'\x00'*(200 - rate))
        for r in range(5):
            for c in range(5):
                S[r][c] ^= blk[r][c]
        permute(S)
    last = bytearray(msg[nb*rate:nb*rate+rem]); last += bytes([0x1F])
    while len(last) < rate: last += b'\x00'
    last[rate-1] ^= 0x80
    blk = bytes_to_lanes(bytes(last) + b'\x00'*(200 - rate))
    for r in range(5):
        for c in range(5):
            S[r][c] ^= blk[r][c]
    permute(S)
    out = bytearray()
    while len(out) < out_len:
        out += lanes_to_bytes(S)[:rate]
        if len(out) < out_len:
            permute(S)
    return bytes(out[:out_len])

def shake128(msg, out_len):
    rate = 168
    S = [[0]*5 for _ in range(5)]
    ml = len(msg); nb = ml // rate; rem = ml - nb*rate
    for bblk in range(nb):
        blk = bytes_to_lanes(msg[bblk*rate:(bblk+1)*rate] + b'\x00'*(200 - rate))
        for r in range(5):
            for c in range(5):
                S[r][c] ^= blk[r][c]
        permute(S)
    last = bytearray(msg[nb*rate:nb*rate+rem]); last += bytes([0x1F])
    while len(last) < rate: last += b'\x00'
    last[rate-1] ^= 0x80
    blk = bytes_to_lanes(bytes(last) + b'\x00'*(200 - rate))
    for r in range(5):
        for c in range(5):
            S[r][c] ^= blk[r][c]
    permute(S)
    out = bytearray()
    while len(out) < out_len:
        out += lanes_to_bytes(S)[:rate]
        if len(out) < out_len:
            permute(S)
    return bytes(out[:out_len])

if __name__ == "__main__":
    Z = [[0]*5 for _ in range(5)]
    permute(Z)
    zb = lanes_to_bytes(Z)
    print("permute(0) lane0 = %016x" % (Z[0][0] & MASK64))
    print("  expected (KeccakCodePackage) = F1258F7940E1DDE7")
    print("  first 16 bytes:", zb[:16].hex())
    print("  expected       : f1258f7940e1dde784d5ccf933c0478a")
    tests = [(b"",32,'256'),(b"abc",64,'256'),(bytes(range(200)),128,'256'),
             (b"",32,'128'),(b"abc",64,'128')]
    ok = True
    for msg,olen,typ in tests:
        got = shake256(msg,olen) if typ=='256' else shake128(msg,olen)
        exp = (hashlib.shake_256 if typ=='256' else hashlib.shake_128)(msg).digest(olen)
        same = got==exp; ok = ok and same
        print("SHAKE-%s msglen=%d olen=%d match=%s" % (typ,len(msg),olen,same))
        if not same:
            print("  got ", got[:8].hex()); print("  exp ", exp[:8].hex())
    print("ALL MATCH" if ok else "MISMATCH")
