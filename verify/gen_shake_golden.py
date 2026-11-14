import hashlib, random, os
random.seed(20261007)

def wbytes(name, data):
    with open(name, 'w') as f:
        for b in data:
            f.write("%02X\n" % (b & 0xFF))

def case(algo, tag, msg, olen):
    fn = hashlib.shake_256 if algo == 's256' else hashlib.shake_128
    out = fn(msg).digest(olen)
    wbytes('sim/%s_msg.hex' % tag, msg)
    wbytes('sim/%s_out.hex' % tag, out)
    print("  %s msglen=%d outlen=%d first4=%s" % (tag, len(msg), olen, out[:4].hex()))
    return len(msg), olen

print("Generating SHAKE golden vectors:")
# SHAKE-256 (RATE=136)
case('s256', 's256a', b"", 32)
case('s256', 's256b', b"abc", 64)
case('s256', 's256c', bytes([i & 0xFF for i in range(200)]), 128)
case('s256', 's256d', bytes(random.randint(0,255) for _ in range(64)), 256)
# SHAKE-128 (RATE=168)
case('s128', 's128a', b"", 32)
case('s128', 's128b', b"abc", 64)
case('s128', 's128c', bytes([(i*7) & 0xFF for i in range(200)]), 168)
case('s128', 's128d', bytes(random.randint(0,255) for _ in range(80)), 256)
print("Done.")
