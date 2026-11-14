"""Direct test of unified_ntt with Dilithium params.
Tests NTT output for a=[1,2,0,...] to verify if NTT produces correct values.
Expected: NTT(a)[0] = sum(a) = 3
"""
import os, sys, subprocess, tempfile, shutil, re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RTL_DIR = os.path.join(ROOT, 'rtl', 'core')

Q = 8380417
N = 256
BW = 27
R_MOD = 131056

tmp = tempfile.mkdtemp(prefix='ntt_direct_')
print(f"[tmp] {tmp}")

a = [0]*N; a[0] = 1; a[1] = 2

# Extract zetas from dilithium_ntt.v
with open(os.path.join(RTL_DIR, 'dilithium_ntt.v'), 'r') as f:
    content = f.read()
zetas = []
for i in range(256):
    pattern = f"8'd{i}:\\s*get_zeta\\s*=\\s*27'sd\\s*(\\d+);"
    match = re.search(pattern, content)
    if match:
        zetas.append(int(match.group(1)))
    else:
        zetas.append(0)

print(f"[info] zetas[0..4] = {zetas[:5]}")

def gen_vector(name, data):
    lines = [f"    reg [22:0] {name} [0:255];"]
    lines.append("    initial begin")
    for i, v in enumerate(data):
        lines.append(f"        {name}[{i}] = 23'd{v};")
    lines.append("    end")
    return "\n".join(lines)

vec_a = gen_vector("a_vec", a)

# Generate zeta assignments
zeta_lines = []
for i in range(256):
    zeta_lines.append(f"        zeta_vals[{i}] = 27'd{zetas[i]};")
zeta_block = "\n".join(zeta_lines)

# Build TB as a plain string (not f-string) to avoid brace issues
tb_parts = []
tb_parts.append("`timescale 1ns/1ps")
tb_parts.append("")
tb_parts.append("module tb_ntt_direct;")
tb_parts.append("")
tb_parts.append("    reg clk = 0, rst_n = 0;")
tb_parts.append("    reg start = 0;")
tb_parts.append("    reg inverse = 0;")
tb_parts.append("    wire busy, done;")
tb_parts.append("")
tb_parts.append("    reg load = 0;")
tb_parts.append("    reg [7:0] load_addr;")
tb_parts.append("    reg [26:0] load_data;")
tb_parts.append("")
tb_parts.append("    reg [7:0] read_addr;")
tb_parts.append("    wire [26:0] read_data;")
tb_parts.append("")
tb_parts.append("    reg zeta_load = 0;")
tb_parts.append("    reg [7:0] zeta_addr;")
tb_parts.append("    reg [26:0] zeta_data;")
tb_parts.append("")
tb_parts.append("    unified_ntt #(")
tb_parts.append("        .N(256), .N_LAYERS(8), .BW(27), .Q(8380417),")
tb_parts.append("        .QINV(58728449), .R_MOD(131056), .SCALE_K(49145),")
tb_parts.append("        .BARRETT_M(33587228), .BARRETT_SH(48)")
tb_parts.append("    ) u_ntt (")
tb_parts.append("        .clk(clk), .rst_n(rst_n), .start(start), .inverse(inverse),")
tb_parts.append("        .busy(busy), .done(done),")
tb_parts.append("        .load(load), .load_addr(load_addr), .load_data(load_data),")
tb_parts.append("        .read_addr(read_addr), .read_data(read_data),")
tb_parts.append("        .zeta_load(zeta_load), .zeta_addr(zeta_addr), .zeta_data(zeta_data)")
tb_parts.append("    );")
tb_parts.append("")
tb_parts.append("    always #5 clk = ~clk;")
tb_parts.append("")
tb_parts.append(vec_a)
tb_parts.append("")
tb_parts.append("    reg [26:0] zeta_vals [0:255];")
tb_parts.append("    initial begin")
tb_parts.append(zeta_block)
tb_parts.append("    end")
tb_parts.append("")
tb_parts.append("    integer i;")
tb_parts.append("")
tb_parts.append("    initial begin")
tb_parts.append("        rst_n = 0; start = 0; load = 0; zeta_load = 0;")
tb_parts.append("        repeat (4) @(negedge clk);")
tb_parts.append("        rst_n = 1;")
tb_parts.append("        repeat (2) @(negedge clk);")
tb_parts.append("")
tb_parts.append("        // Load zetas")
tb_parts.append("        for (i = 0; i < 256; i = i + 1) begin")
tb_parts.append("            @(negedge clk);")
tb_parts.append("            zeta_addr = i[7:0];")
tb_parts.append("            zeta_data = zeta_vals[i];")
tb_parts.append("            zeta_load = 1;")
tb_parts.append("            @(posedge clk);")
tb_parts.append("            @(negedge clk);")
tb_parts.append("            zeta_load = 0;")
tb_parts.append("        end")
tb_parts.append("")
tb_parts.append("        // Load polynomial a")
tb_parts.append("        for (i = 0; i < 256; i = i + 1) begin")
tb_parts.append("            @(negedge clk);")
tb_parts.append("            load_addr = i[7:0];")
tb_parts.append("            load_data = {4'b0, a_vec[i]};")
tb_parts.append("            load = 1;")
tb_parts.append("            @(posedge clk);")
tb_parts.append("            @(negedge clk);")
tb_parts.append("            load = 0;")
tb_parts.append("        end")
tb_parts.append("")
tb_parts.append("        repeat (4) @(negedge clk);")
tb_parts.append("")
tb_parts.append("        // Start forward NTT")
tb_parts.append("        inverse = 0;")
tb_parts.append("        @(negedge clk);")
tb_parts.append("        start = 1;")
tb_parts.append("        @(posedge clk);")
tb_parts.append("        @(negedge clk);")
tb_parts.append("        start = 0;")
tb_parts.append("")
tb_parts.append("        while (!done) @(negedge clk);")
tb_parts.append("        @(posedge clk);")
tb_parts.append("        repeat (4) @(negedge clk);")
tb_parts.append("")
tb_parts.append("        $display(\"NTT output (first 5):\");")
tb_parts.append("        for (i = 0; i < 5; i = i + 1) begin")
tb_parts.append("            read_addr = i[7:0];")
tb_parts.append("            @(negedge clk);")
tb_parts.append("            $display(\"  ntt[%0d] = %0d (0x%0x)\", i, $signed(read_data), read_data);")
tb_parts.append("            @(posedge clk);")
tb_parts.append("        end")
tb_parts.append("")
tb_parts.append("        $display(\"Expected: ntt[0] = 3 (sum of a)\");")
tb_parts.append("        $display(\"Expected: 3 * R mod q = %0d\", (3 * 131056) % 8380417);")
tb_parts.append("        $finish;")
tb_parts.append("    end")
tb_parts.append("")
tb_parts.append("endmodule")

tb_code = "\n".join(tb_parts)

tb_path = os.path.join(tmp, 'tb_ntt_direct.v')
with open(tb_path, 'w', encoding='utf-8') as f:
    f.write(tb_code)

print(f"[tb] {tb_path}")

shutil.copy2(os.path.join(RTL_DIR, 'unified_ntt.v'), os.path.join(tmp, 'unified_ntt.v'))

iverilog = r'C:\iverilog\bin\iverilog.exe'
vvp = r'C:\iverilog\bin\vvp.exe'

vvp_out = os.path.join(tmp, 'tb_ntt_direct.vvp')
cmd = [iverilog, '-g2012', '-o', vvp_out,
       os.path.join(tmp, 'tb_ntt_direct.v'),
       os.path.join(tmp, 'unified_ntt.v')]
result = subprocess.run(cmd, capture_output=True, text=True, cwd=tmp)
if result.returncode != 0:
    print(f"[FAIL] iverilog: {result.stderr}")
    sys.exit(1)
print("[compile] OK")

result = subprocess.run([vvp, vvp_out], capture_output=True, text=True, cwd=tmp, timeout=120)
print(result.stdout[-3000:] if len(result.stdout) > 3000 else result.stdout)
if result.stderr:
    print("STDERR:", result.stderr[-2000:])

shutil.rmtree(tmp, ignore_errors=True)
print("[done]")
