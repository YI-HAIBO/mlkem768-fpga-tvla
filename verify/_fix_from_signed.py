"""Fix from_signed_23 function to use proper mod-q reduction."""
import os

FILE = os.path.join(
    r'c:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype',
    'rtl', 'core', 'dilithium_ntt.v'
)

with open(FILE, 'r', encoding='utf-8-sig', errors='replace') as f:
    content = f.read()

# Old from_signed_23 function
old_fn = """// Convert 27-bit signed to 23-bit unsigned [0, q-1]
function [22:0] from_signed_23;
    input signed [26:0] val;
    reg  signed [26:0] tmp;
    begin
        if (val >= 0)
            from_signed_23 = val[22:0];
        else begin
            tmp = val + 27'sd8380417;
            from_signed_23 = tmp[22:0];
        end
    end
endfunction"""

# New from_signed_23 function with proper mod-q reduction
new_fn = """// Convert 27-bit value to 23-bit unsigned [0, q-1] via signed mod-q reduction
// (matches TB's: ((($signed(v) % QD) + QD) % QD))
function [22:0] from_signed_23;
    input signed [26:0] val;
    reg signed [31:0] sv;
    reg signed [31:0] r;
    begin
        sv = $signed(val);
        r = sv % 32'sd8380417;
        if (r < 0) r = r + 32'sd8380417;
        from_signed_23 = r[22:0];
    end
endfunction"""

count = content.count(old_fn)
if count != 1:
    print(f"ERROR: Found {count} occurrences of old from_signed_23")
    exit(1)

content = content.replace(old_fn, new_fn)

with open(FILE, 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(content)

print("SUCCESS: Fixed from_signed_23 function")
print("Old: val[22:0] for positive values (mod 2^23, WRONG)")
print("New: signed mod-q reduction (matches TB's method)")
