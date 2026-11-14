"""Debug: run dilithium test showing all DBG lines."""
import os, subprocess, tempfile, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RTL_DIR = os.path.join(ROOT, 'rtl', 'core')

Q = 8380417
N = 256

tmp = tempfile.mkdtemp(prefix='dil_debug_')
print(f"[tmp] {tmp}")

a = [0]*N; a[0] = 1; a[1] = 2
b = [0]*N; b[0] = 3; b[1] = 4
c = [0]*N
for k in range(N):
    s = 0
    for i in range(N):
        s += a[i] * b[(k-i) % N]
    c[k] = s % Q

def gen_vector(name, data):
    lines = []
    lines.append("    reg [22:0] %s [0:255];" % name)
    lines.append("    initial begin")
    for i, v in enumerate(data):
        lines.append("        %s[%d] = 23'd%d;" % (name, i, v))
    lines.append("    end")
    return "\n".join(lines)

vec_a = gen_vector("a_vec", a)
vec_b = gen_vector("b_vec", b)
vec_c = gen_vector("c_vec", c)

BS = chr(96)
tb_code = BS + "timescale 1ns/1ps\n"
tb_code += "module tb_dilithium_ntt;\n"
tb_code += "    reg clk = 0, rst_n = 0;\n"
tb_code += "    reg start = 0;\n"
tb_code += "    reg [1:0] mode = 2;\n"
tb_code += "    reg [7:0] a_addr, b_addr;\n"
tb_code += "    reg [22:0] a_data, b_data;\n"
tb_code += "    reg a_wr = 0, b_wr = 0;\n"
tb_code += "    wire [7:0] c_addr;\n"
tb_code += "    wire [22:0] c_data;\n"
tb_code += "    wire busy, done;\n"
tb_code += "    reg [22:0] c_buf [0:255];\n"
tb_code += "    integer c_count;\n"
tb_code += "    dilithium_ntt u_dut (\n"
tb_code += "        .clk(clk), .rst_n(rst_n), .start(start), .busy(busy), .done(done),\n"
tb_code += "        .a_addr(a_addr), .a_data(a_data), .a_wr(a_wr),\n"
tb_code += "        .b_addr(b_addr), .b_data(b_data), .b_wr(b_wr),\n"
tb_code += "        .c_addr(c_addr), .c_data(c_data),\n"
tb_code += "        .mode(mode), .omega_k(23'd0)\n"
tb_code += "    );\n"
tb_code += "    always #5 clk = ~clk;\n"
tb_code += "    always @(negedge clk) begin\n"
tb_code += "        if (busy && !done) begin\n"
tb_code += "            c_buf[c_addr] <= c_data;\n"
tb_code += "            c_count = c_count + 1;\n"
tb_code += "        end\n"
tb_code += "    end\n"
tb_code += vec_a + "\n"
tb_code += vec_b + "\n"
tb_code += vec_c + "\n"
tb_code += "    integer i;\n"
tb_code += "    integer errors = 0;\n"
tb_code += "    initial begin\n"
tb_code += "        c_count = 0;\n"
tb_code += "        rst_n = 0; start = 0; a_wr = 0; b_wr = 0;\n"
tb_code += "        repeat (4) @(negedge clk);\n"
tb_code += "        rst_n = 1;\n"
tb_code += "        repeat (2) @(negedge clk);\n"
tb_code += "        for (i = 0; i < 256; i = i + 1) begin\n"
tb_code += "            @(negedge clk);\n"
tb_code += "            a_addr = i[7:0]; a_data = a_vec[i]; a_wr = 1;\n"
tb_code += "            @(posedge clk); @(negedge clk); a_wr = 0;\n"
tb_code += "        end\n"
tb_code += "        for (i = 0; i < 256; i = i + 1) begin\n"
tb_code += "            @(negedge clk);\n"
tb_code += "            b_addr = i[7:0]; b_data = b_vec[i]; b_wr = 1;\n"
tb_code += "            @(posedge clk); @(negedge clk); b_wr = 0;\n"
tb_code += "        end\n"
tb_code += "        repeat (4) @(negedge clk);\n"
tb_code += "        mode = 2;\n"
tb_code += "        @(negedge clk); start = 1; @(posedge clk); @(negedge clk); start = 0;\n"
tb_code += "        while (!done) @(negedge clk);\n"
tb_code += "        @(posedge clk); repeat (4) @(negedge clk);\n"
tb_code += "        for (i = 0; i < 256; i = i + 1) begin\n"
tb_code += "            if (c_buf[i] !== c_vec[i]) begin\n"
tb_code += "                if (errors < 5) $display(\"MISMATCH i=%0d: got=%0d exp=%0d\", i, c_buf[i], c_vec[i]);\n"
tb_code += "                errors = errors + 1;\n"
tb_code += "            end\n"
tb_code += "        end\n"
tb_code += "        if (errors == 0) $display(\"ALL PASS\");\n"
tb_code += "        else $display(\"FAIL: %0d mismatches\", errors);\n"
tb_code += "        $display(\"ERRORS=%0d\", errors);\n"
tb_code += "        $finish;\n"
tb_code += "    end\n"
tb_code += "endmodule\n"

tb_path = os.path.join(tmp, 'tb.v')
with open(tb_path, 'w', encoding='utf-8') as f:
    f.write(tb_code)
# Print first 3 lines for debugging
with open(tb_path, 'r', encoding='utf-8') as f:
    for i, line in enumerate(f):
        if i >= 3: break
        print(f"  L{i+1}: {repr(line)}")

for fname in ['dilithium_ntt.v', 'unified_ntt.v']:
    shutil.copy2(os.path.join(RTL_DIR, fname), os.path.join(tmp, fname))

iverilog = r'C:\iverilog\bin\iverilog.exe'
vvp = r'C:\iverilog\bin\vvp.exe'
vvp_out = os.path.join(tmp, 'tb.vvp')
cmd = [iverilog, '-g2012', '-o', vvp_out,
       os.path.join(tmp, 'tb.v'),
       os.path.join(tmp, 'dilithium_ntt.v'),
       os.path.join(tmp, 'unified_ntt.v')]
r = subprocess.run(cmd, capture_output=True, text=True, cwd=tmp)
if r.returncode != 0:
    print("[FAIL]", r.stderr)
else:
    r = subprocess.run([vvp, vvp_out], capture_output=True, text=True, cwd=tmp, timeout=120)
    for line in r.stdout.split('\n'):
        if 'DBG' in line or 'MISMATCH' in line or 'PASS' in line or 'FAIL' in line or 'ERRORS' in line:
            print(line)
    if r.stderr:
        print("STDERR:", r.stderr[-500:])

shutil.rmtree(tmp, ignore_errors=True)
print("[done]")
