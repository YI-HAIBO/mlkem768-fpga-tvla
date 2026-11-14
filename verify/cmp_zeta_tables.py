"""Compare the TB's sign_zeta table with dilithium_ntt.v's get_zeta table."""
import os, re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# --- TB sign_zeta ---
with open(os.path.join(BASE, 'sim', 'tb_unified_ntt_sign.v'),
          'r', encoding='utf-8-sig', errors='replace') as f:
    tb = f.read()
sign_zeta = {}
for m in re.finditer(r"sign_zeta\[(\d+)\]\s*=\s*27'd(\d+)", tb):
    sign_zeta[int(m.group(1))] = int(m.group(2))

# --- wrapper get_zeta ---
with open(os.path.join(BASE, 'rtl', 'core', 'dilithium_ntt.v'),
          'r', encoding='utf-8-sig', errors='replace') as f:
    dut = f.read()
get_zeta = {}
for m in re.finditer(r"8'd(\d+):\s*get_zeta\s*=\s*27'sd\s*(\d+)", dut):
    get_zeta[int(m.group(1))] = int(m.group(2))

print('sign_zeta entries found: %d' % len(sign_zeta))
print('get_zeta entries found : %d' % len(get_zeta))

common = set(sign_zeta) & set(get_zeta)
diff = [(i, sign_zeta[i], get_zeta[i]) for i in sorted(common)
        if sign_zeta[i] != get_zeta[i]]
print('differing entries: %d' % len(diff))
for i, s, g in diff[:10]:
    print('  [%d] sign_zeta=%d get_zeta=%d' % (i, s, g))
only_tb = sorted(set(sign_zeta) - set(get_zeta))
only_dut = sorted(set(get_zeta) - set(sign_zeta))
print('indices only in sign_zeta: %s' % only_tb[:10])
print('indices only in get_zeta : %s' % only_dut[:10])
