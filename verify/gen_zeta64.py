import sys
sys.path.insert(0, '.')
from kyber_ref_exact import ZETAS

z = ZETAS[64:128]  # basemul twiddles: zetas[64..127]

def uhex(v):
    return str(v & 0xFFFF)

lines = []
lines.append('    // Correct basemul twiddles: zetas[64..127] (pq-crystals/kyber ref/ntt.c).')
lines.append('    // Values are signed int16_t constants; fqmul ignores the sign, but')
lines.append('    // the INDICES must be 64..127 (the file previously had an offset-16 bug).')
lines.append('    function [BW-1:0] get_zeta64;')
lines.append('        input [5:0] zidx;')
lines.append('        begin')
for i, val in enumerate(z):
    pad = '            '
    lines.append(pad + "6'd%d: get_zeta64 = 16'd%s;" % (i, uhex(val)))
lines.append('            default: get_zeta64 = 16\'d0;')
lines.append('        end')
lines.append('    endfunction')

open('verify/zeta64_func.txt', 'w').write("\n".join(lines))
print("Generated get_zeta64 with", len(z), "entries")
print("first 4 (zetas[64..67]):", z[:4], "->", [uhex(v) for v in z[:4]])
