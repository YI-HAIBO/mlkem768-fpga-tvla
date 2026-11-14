"""
Generate golden vectors for the kyber_poly / kyber_sampler RTL testbenches.
Expected values come from the proven reference (kyber_ref_exact.py mirrors
pq-crystals/kyber; its poly_mul == schoolbook mod q, verified earlier).
Writes signed 16-bit coefficients as 4-digit two's-complement hex for $readmemh.
"""
import random, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from kyber_ref_exact import poly_mul, barrett_reduce

Q = 3329
def s16(x):
    x &= 0xFFFF
    return x - 65536 if x >= 32768 else x

def to_hex(v):
    v = s16(v) & 0xFFFF
    return "%04X" % v

random.seed(20261007)
a = [random.randint(0, Q-1) for _ in range(256)]
b = [random.randint(0, Q-1) for _ in range(256)]

# poly_add / poly_sub expected (RTL uses barrett_reduce(a +/- b))
add_exp = [barrett_reduce(a[i] + b[i]) for i in range(256)]
sub_exp = [barrett_reduce(a[i] - b[i]) for i in range(256)]

# poly_mul expected (full NTT -> basemul -> INTT chain == schoolbook mod q)
mul_exp = poly_mul(a, b)

# Sampler: 128 random bytes; CBD eta=2 => a=bit0+bit1, b=bit2+bit3, c=a-b
sbytes = [random.randint(0, 255) for _ in range(128)]
samp_exp = []
for i in range(256):
    byte = sbytes[i // 2]
    nib = (byte & 0x0F) if (i % 2 == 0) else (byte >> 4)
    a_sum = (nib & 1) + ((nib >> 1) & 1)
    b_sum = ((nib >> 2) & 1) + ((nib >> 3) & 1)
    samp_exp.append(a_sum - b_sum)

SIM_DIR = os.path.join(PROJECT, "sim")
os.makedirs(SIM_DIR, exist_ok=True)

def w(name, vals):
    with open(os.path.join(SIM_DIR, name), 'w') as f:
        for v in vals:
            f.write(to_hex(v) + "\n")

w('gold_a.hex', a)
w('gold_b.hex', b)
w('gold_add.hex', add_exp)
w('gold_sub.hex', sub_exp)
w('gold_mul.hex', mul_exp)
with open(os.path.join(SIM_DIR, 'gold_sbytes.hex'), 'w') as f:
    for v in sbytes:
        f.write("%02X\n" % v)
w('gold_samp.hex', samp_exp)

print("Generated golden vectors:")
print("  a[0:3]=", a[:3], "b[0:3]=", b[:3])
print("  add_exp[0:3]=", add_exp[:3])
print("  sub_exp[0:3]=", sub_exp[:3])
print("  mul_exp[0:3]=", mul_exp[:3], "mod q:", [(x % Q) for x in mul_exp[:3]])
print("  sbytes[0]=%02X samp_exp[0:3]=%s" % (sbytes[0], samp_exp[:3]))
# sanity: mul_exp mod q == schoolbook mod q (checked in kyber_ref_exact already)
