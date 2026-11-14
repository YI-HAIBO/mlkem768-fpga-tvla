"""Fix dilithium_ntt.v's get_zeta table.

Root cause: the get_zeta table drifted from the calibrated table
(dilithium_sign_params.vh == TB sign_zeta, verified 0 diffs) at indices
131..255 (124 wrong entries).  The wrong table breaks the NTT ring
homomorphism so INTT(NTT(a)*NTT(b)) != schoolbook conv*R.

This script rebuilds get_zeta from dilithium_sign_params.vh and asserts the
result matches the TB's sign_zeta bit-for-bit.
"""
import os, re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILE = os.path.join(BASE, 'rtl', 'core', 'dilithium_ntt.v')

# --- read the calibrated zeta table ---
with open(os.path.join(BASE, 'verify', 'dilithium_sign_params.vh'),
          'r', encoding='utf-8-sig', errors='replace') as f:
    txt = f.read()
zetas = {}
for m in re.finditer(r"sign_zeta\[(\d+)\]\s*=\s*27'sd\s+(-?\d+)", txt):
    zetas[int(m.group(1))] = int(m.group(2)) % (1 << 27)   # normalize signed->27b
assert len(zetas) == 256, 'expected 256 zetas, got %d' % len(zetas)

# --- cross-check vs the TB's sign_zeta ---
with open(os.path.join(BASE, 'sim', 'tb_unified_ntt_sign.v'),
          'r', encoding='utf-8-sig', errors='replace') as f:
    tb = f.read()
tb_z = {}
for m in re.finditer(r"sign_zeta\[(\d+)\]\s*=\s*27'd(\d+)", tb):
    tb_z[int(m.group(1))] = int(m.group(2))
bad = [i for i in range(256) if zetas[i] != tb_z[i]]
assert not bad, 'table mismatch vs TB at %s' % bad[:8]
print('zeta table verified: matches TB sign_zeta 256/256')

# --- replace the get_zeta function in dilithium_ntt.v ---
with open(FILE, 'r', encoding='utf-8-sig', errors='replace') as f:
    content = f.read()

start_marker = 'function [26:0] get_zeta;'
start_idx = content.find(start_marker)
assert start_idx >= 0, 'get_zeta function not found'
end_idx = content.find('endfunction', start_idx)
assert end_idx >= 0
end_idx += len('endfunction')

# include the comment header block above the function (=== framed)
old_block_start = content.rfind('// ===', 0, start_idx)
if old_block_start < 0:
    old_block_start = start_idx

lines = []
lines.append('// =========================================================================')
lines.append('// Zeta ROM function (256 entries, 27-bit, Dilithium SIGN mode)')
lines.append('//   Restored 2026-10-24 from verify/dilithium_sign_params.vh, which is')
lines.append('//   bit-identical to the TB sign_zeta table calibrated against')
lines.append('//   unified_ntt (SCALE_K=49145).  DO NOT hand-edit: regenerate from the .vh.')
lines.append('// =========================================================================')
lines.append('function [26:0] get_zeta;')
lines.append('    input [7:0] addr;')
lines.append('    case (addr)')
for i in range(256):
    lines.append("        8'd%d:   get_zeta = 27'sd %d;" % (i, zetas[i]))
lines.append("        default: get_zeta = 27'sd 0;")
lines.append('    endcase')
lines.append('endfunction')
new_block = '\n'.join(lines)

content = content[:old_block_start] + new_block + content[end_idx:]
with open(FILE, 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(content)

# --- verify the written file parses back to the same table ---
with open(FILE, 'r', encoding='utf-8-sig', errors='replace') as f:
    chk = f.read()
got = {}
for m in re.finditer(r"8'd(\d+):\s*get_zeta\s*=\s*27'sd\s*(\d+)", chk):
    got[int(m.group(1))] = int(m.group(2))
assert len(got) == 256, 'wrote %d entries' % len(got)
bad = [i for i in range(256) if got[i] != tb_z[i]]
assert not bad, 'written table mismatch at %s' % bad[:8]
print('dilithium_ntt.v get_zeta restored: 256/256 correct')
print('zeta[1] = %d, zeta[131] = %d (was wrong), zeta[255] = %d'
      % (zetas[1], zetas[131], zetas[255]))
