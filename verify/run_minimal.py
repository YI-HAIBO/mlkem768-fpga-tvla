"""Minimal test: load wrapper's pointwise products into unified_ntt, run INTT, check."""
import os, subprocess, tempfile, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RTL_DIR = os.path.join(ROOT, 'rtl', 'core')

Q = 8380417
N = 256
R = 131056  # 2^27 mod q
R_INV = 4713473

# Wrapper's test vectors
a = [0]*N; a[0] = 1; a[1] = 2
b = [0]*N; b[0] = 3; b[1] = 4
c = [0]*N  # schoolbook negacyclic convolution
for k in range(N):
    s = 0
    for i in range(N):
        s += a[i] * b[(k-i) % N]
    c[k] = s % Q

print(f"Expected c[0..4] = {c[:5]}")

# Compute NTT of a and b using Python model to get pointwise products
# Using the same zetas as the wrapper (DUT zetas)
# For now, just use the values from the debug output
# a_ntt[0]=3507, a_ntt[1]=-3505, etc.
# b_ntt[0]=7015, b_ntt[1]=-7009, etc.
# pt[0] = 7840771, pt[1] = 7805711, etc.

# We need all 256 pointwise product values
# Let's compute them using the Python NTT model
# But we need the DUT zetas for that...
# For now, let's just use the first few values from the debug and pad with zeros

# Actually, let's compute the pointwise products using the same zetas as the wrapper
# The wrapper uses DUT zetas from gen_sign_params.py
# Let's import the zetas from the TB

# For this test, let's use a simpler approach:
# Just load the pt values from the debug output for the first 5 indices
# and zeros for the rest. This won't give the correct result, but it will
# tell us if the INTT produces the same wrong value.

# From debug: pt[0]=7840771, pt[1]=7805711, pt[2]=6344233, pt[3]=3150548, pt[4]=386587
pt_debug = [7840771, 7805711, 6344233, 3150548, 386587]

# Let's compute the full pointwise product using the Python model
# We need the zetas. Let's generate them.

def gen_zetas(N):
    """Generate Dilithium zetas (Montgomery form) for NTT."""
    q = 8380417
    R = 131056  # 2^27 mod q
    
    # Primitive 2N-th root of unity
    # For Dilithium: zeta = g^((q-1)/(2N)) where g is a generator
    # g = 7 (primitive root mod q)
    g = 7
    zeta = pow(g, (q-1)//(2*N), q)
    
    # Montgomery form: zeta_mont = zeta * R mod q
    zeta_mont = zeta * R % q
    
    # Generate all zetas
    zetas = [0] * N
    for i in range(N):
        # zetas[i] = zeta_mont^(2^i) mod q
        # But actually, Dilithium uses a specific ordering
        # Let's use the standard formula
        pass
    
    return zetas

# Actually, let's use the zetas from the TB file
# The TB has sign_zeta values
print("Need to extract zetas from TB file...")

# For now, let's create a minimal test that just loads some values and runs INTT
tmp = tempfile.mkdtemp(prefix='ntt_minimal_')

# Extract zetas from TB
tb_path = os.path.join(ROOT, 'sim', 'tb_unified_ntt_sign.v')
with open(tb_path, 'r', encoding='utf-8') as f:
    tb_content = f.read()

# Find sign_zeta values
import re
# Pattern: sign_zeta[i] = 27'dXXX;
pattern = r"sign_zeta\[(\d+)\]\s*=\s*27'd(\d+);"
matches = re.findall(pattern, tb_content)
zetas = {}
for m in matches:
    zetas[int(m[0])] = int(m[1])
print(f"Found {len(zetas)} zeta values")

# Generate vector for pt_buf
def gen_vector(name, data):
    lines = []
    lines.append("    reg [22:0] %s [0:255];" % name)
    lines.append("    initial begin")
    for i, v in enumerate(data):
        lines.append("        %s[%d] = 23'd%d;" % (name, i, v))
    lines.append("    end")
    return "\n".join(lines)

# We need all 256 pt values
# Let's compute them using the zetas
def ntt_signed(f, zetas, N=256):
    """Compute signed NTT using the given zetas."""
    q = 8380417
    # f is in signed representation [-q/2, q/2-1]
    # Convert to unsigned
    f_u = [x % q for x in f]
    
    # Standard NTT with Montgomery zetas
    # This is the standard 8-layer NTT
    a = list(f_u)
    n = N
    L = 8
    for l in range(L):
        # Each layer processes n/2^l butterflies
        step = 1 << (L - l)
        # Get zeta for this layer
        # The zeta index depends on the layer
        # For layer l, the zeta is zetas[l * (n >> l)]  (approximately)
        # Actually, let's use the standard Dilithium NTT structure
        # Each layer l uses zeta[l] for the first butterfly, etc.
        # This is complex - let's use the simplified approach
        pass
    return a

# This is getting too complex. Let's just use the debug values and pad with zeros
# for the first 5 indices, and compute the rest as 0.
# This won't give the correct result, but it will tell us if the INTT
# produces the same wrong value for the first coefficient.

pt = [0] * N
for i in range(min(5, len(pt_debug))):
    pt[i] = pt_debug[i]

print(f"pt[0..4] = {pt[:5]}")
print(f"pt[5..] = 0 (placeholder)")

# Generate TB
BS = chr(96)  # backtick
vec_pt = gen_vector("pt_vec", pt)
vec_zeta = ""
for i in range(256):
    if i in zetas:
        vec_zeta += "    zeta_vec[%d] = 27'd%d;\n" % (i, zetas[i])
    else:
        vec_zeta += "    zeta_vec[%d] = 27'd0;\n" % (i, i)

tb_code = BS + "timescale 1ns/1ps\n"
tb_code += "module tb_ntt_minimal;\n"
tb_code += "    reg clk = 0, rst_n = 0;\n"
tb_code += "    reg start = 0, inverse = 0, load = 0;\n"
tb_code += "    reg [7:0] load_addr, read_addr;\n"
tb_code += "    reg [26:0] load_data, zeta_data;\n"
tb_code += "    reg [7:0] zeta_addr;\n"
tb_code += "    wire [26:0] read_data;\n"
tb_code += "    wire busy, done;\n"
tb_code += "    reg [26:0] zeta_vec [0:255];\n"
tb_code += "    reg [26:0] out_buf [0:255];\n"
tb_code += "    integer i, errors = 0;\n"
tb_code += "    unified_ntt #(\n"
tb_code += "        .N(256), .N_LAYERS(8), .BW(27),\n"
tb_code += "        .Q(8380417), .QINV(58728449), .R_MOD(131056),\n"
tb_code += "        .SCALE_K(49145), .BARRETT_M(33587228), .BARRETT_SH(48)\n"
tb_code += "    ) u_ntt (\n"
tb_code += "        .clk(clk), .rst_n(rst_n),\n"
tb_code += "        .start(start), .inverse(inverse), .busy(busy), .done(done),\n"
tb_code += "        .load(load), .load_addr(load_addr), .load_data(load_data),\n"
tb_code += "        .read_addr(read_addr), .read_data(read_data),\n"
tb_code += "        .zeta_load(1'b1), .zeta_addr(zeta_addr), .zeta_data(zeta_data)\n"
tb_code += "    );\n"
tb_code += "    always #5 clk = ~clk;\n"
tb_code += "\n"
tb_code += vec_pt + "\n"
tb_code += "\n"
tb_code += "    initial begin\n"
tb_code += "        rst_n = 0; start = 0; inverse = 0; load = 0;\n"
tb_code += "        repeat (4) @(negedge clk);\n"
tb_code += "        rst_n = 1;\n"
tb_code += "        repeat (2) @(negedge clk);\n"
tb_code += "\n"
tb_code += "        // Load zetas\n"
tb_code += "        for (i = 0; i < 256; i = i + 1) begin\n"
tb_code += "            zeta_addr = i[7:0];\n"
tb_code += "            zeta_data = zeta_vec[i];\n"
tb_code += "            @(posedge clk);\n"
tb_code += "        end\n"
tb_code += "\n"
tb_code += "        // Load pointwise products\n"
tb_code += "        for (i = 0; i < 256; i = i + 1) begin\n"
tb_code += "            load_addr = i[7:0];\n"
tb_code += "            load_data = {4'b0, pt_vec[i]};\n"
tb_code += "            load = 1;\n"
tb_code += "            @(posedge clk);\n"
tb_code += "        end\n"
tb_code += "        load = 0;\n"
tb_code += "\n"
tb_code += "        // Run INTT\n"
tb_code += "        start = 1; inverse = 1;\n"
tb_code += "        @(posedge clk);\n"
tb_code += "        start = 0;\n"
tb_code += "        while (!done) @(posedge clk);\n"
tb_code += "\n"
tb_code += "        // Read output\n"
tb_code += "        for (i = 0; i < 256; i = i + 1) begin\n"
tb_code += "            read_addr = i[7:0];\n"
tb_code += "            @(posedge clk);\n"
tb_code += "            out_buf[i] = read_data;\n"
tb_code += "        end\n"
tb_code += "\n"
tb_code += "        // Check first 5 coefficients\n"
tb_code += "        // Expected: a*b*R (Montgomery form of schoolbook convolution)\n"
tb_code += "        $display(\"DBG out_buf[0]=%0d exp_mont=%0d\", out_buf[0], 3*%d %% %d);\n"
tb_code += "        $display(\"DBG out_buf[1]=%0d exp_mont=%0d\", out_buf[1], 10*%d %% %d);\n"
tb_code += "        $display(\"DBG out_buf[2]=%0d exp_mont=%0d\", out_buf[2], 8*%d %% %d);\n"
tb_code += "        $finish;\n"
tb_code += "    end\n"
tb_code += "endmodule\n"

# Fix the format strings (can't use Python % in Verilog)
tb_code = tb_code.replace("3*%d %% %d", str(3 * R % Q))
tb_code = tb_code.replace("10*%d %% %d", str(10 * R % Q))
tb_code = tb_code.replace("8*%d %% %d", str(8 * R % Q))

tb_path = os.path.join(tmp, 'tb.v')
with open(tb_path, 'w', encoding='utf-8') as f:
    f.write(tb_code)

for fname in ['unified_ntt.v']:
    shutil.copy2(os.path.join(RTL_DIR, fname), os.path.join(tmp, fname))

iverilog = r'C:\iverilog\bin\iverilog.exe'
vvp = r'C:\iverilog\bin\vvp.exe'
vvp_out = os.path.join(tmp, 'tb.vvp')
cmd = [iverilog, '-g2012', '-o', vvp_out,
       os.path.join(tmp, 'tb.v'),
       os.path.join(tmp, 'unified_ntt.v')]
r = subprocess.run(cmd, capture_output=True, text=True, cwd=tmp)
if r.returncode != 0:
    print("[FAIL]", r.stderr)
else:
    r = subprocess.run([vvp, vvp_out], capture_output=True, text=True, cwd=tmp, timeout=60)
    print(r.stdout[-2000:] if len(r.stdout) > 2000 else r.stdout)

shutil.rmtree(tmp, ignore_errors=True)
print("[done]")
