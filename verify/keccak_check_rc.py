# Instrument compact_fips202.py's exact KeccakF1600onLanes to print the RC it XORs each round.
import importlib.util, sys
spec = importlib.util.spec_from_file_location("cf", "compact_fips202.py")
cf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cf)

# Monkey-patch: wrap KeccakF1600onLanes to capture RC per round.
orig = cf.KeccakF1600onLanes
captured = []
def wrapped(lanes):
    R = 1
    for round in range(24):
        # theta
        C = [lanes[x][0] ^ lanes[x][1] ^ lanes[x][2] ^ lanes[x][3] ^ lanes[x][4] for x in range(5)]
        D = [C[(x+4)%5] ^ cf.ROL64(C[(x+1)%5], 1) for x in range(5)]
        lanes = [[lanes[x][y]^D[x] for y in range(5)] for x in range(5)]
        # rho and pi
        (x, y) = (1, 0)
        current = lanes[x][y]
        for t in range(24):
            (x, y) = (y, (2*x+3*y)%5)
            (current, lanes[x][y]) = (lanes[x][y], cf.ROL64(current, (t+1)*(t+2)//2))
        # chi
        for y in range(5):
            T = [lanes[x][y] for x in range(5)]
            for x in range(5):
                lanes[x][y] = T[x] ^((~T[(x+1)%5]) & T[(x+2)%5])
        # iota - capture RC
        rc = 0
        for j in range(7):
            R = ((R << 1) ^ ((R >> 7)*0x71)) % 256
            if (R & 2):
                rc ^= (1 << ((1<<j)-1))
        captured.append(rc)
        lanes[0][0] = lanes[0][0] ^ rc
    return lanes

cf.KeccakF1600onLanes = wrapped
# Run a SHAKE256 to exercise it
got = bytes(cf.SHAKE256(b"", 32))
import hashlib
exp = hashlib.shake_256(b"").digest(32)
print("SHAKE256('') match:", got == exp)
print("RC values used by compact_fips202.py:")
for i, rc in enumerate(captured):
    print("  round %2d: 0x%016x" % (i, rc))