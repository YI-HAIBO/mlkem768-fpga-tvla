"""Replace the wrong get_zeta function with correct standard Dilithium zetas."""
import os, re

FILE = os.path.join(
    r'c:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype',
    'rtl', 'core', 'dilithium_ntt.v'
)

with open(FILE, 'r', encoding='utf-8-sig', errors='replace') as f:
    content = f.read()

# The old function spans from "function [26:0] get_zeta;" to the matching "endfunction"
# Find the start
start_marker = 'function [26:0] get_zeta;'
start_idx = content.find(start_marker)
if start_idx < 0:
    print("ERROR: Could not find get_zeta function start")
    exit(1)

# Find the end (the endfunction that closes this function)
end_marker = 'endfunction'
end_idx = content.find(end_marker, start_idx)
if end_idx < 0:
    print("ERROR: Could not find endfunction")
    exit(1)
end_idx += len(end_marker)

# Read the new zeta table from the generated output
zetas_file = os.path.join(
    r'C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14',
    'zetas_out.txt'
)
with open(zetas_file, 'r', encoding='utf-8') as f:
    zetas_text = f.read()

# Extract the function body (from "function [26:0] get_zeta;" to "endfunction")
func_start = zetas_text.find('function [26:0] get_zeta;')
func_end = zetas_text.find('endfunction') + len('endfunction')
new_function = zetas_text[func_start:func_end]

# Also add a comment header
new_block = (
    '// =========================================================================\n'
    '// Zeta ROM function (256 entries, 27-bit unsigned, standard Dilithium)\n'
    '// Generated from PQ-Crystals reference: ref/ntt.c zetas[256]\n'
    '// Fixed 2026-10-23: old zetas were wrong (255/256 mismatches with\n'
    '// schoolbook convolution). These are the correct standard zetas.\n'
    '// =========================================================================\n'
    + new_function
)

# Replace the old function
old_block_start = content.rfind('// ===', 0, start_idx)
if old_block_start < 0:
    old_block_start = start_idx

old_block = content[old_block_start:end_idx]
content_new = content[:old_block_start] + new_block + content[end_idx:]

with open(FILE, 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(content_new)

print(f"SUCCESS: Replaced get_zeta function")
print(f"Old block: {len(old_block)} chars, New block: {len(new_block)} chars")
print(f"zeta[1] old=2357800, new=25847 (standard Dilithium)")
