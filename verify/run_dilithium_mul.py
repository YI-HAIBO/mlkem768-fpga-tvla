"""Randomized regression for dilithium_ntt.v (Task 75).

Runs K trials of full 256-coefficient polynomial multiplication
a*b in Z_q[x]/(x^256+1) through the RTL wrapper and compares against
an independent Python schoolbook negacyclic convolution.
"""
import os, subprocess, tempfile, shutil, random

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RTL_DIR = os.path.join(ROOT, 'rtl', 'core')

Q = 8380417
N = 256
TRIALS = 6
SEED = 20261024

random.seed(SEED)


def schoolbook(a, b):
    c = [0] * (2 * N)
    for i in range(N):
        ai = a[i] % Q
        if ai:
            for j in range(N):
                c[i + j] += ai * (b[j] % Q)
    return [(c[k] - c[k + N]) % Q for k in range(N)]


def gen_case(num):
    """Each trial: random dense vectors, plus one corner case."""
    if num == 0:
        a = [0] * N; a[0] = 1; a[1] = 2
        b = [0] * N; b[0] = 3; b[1] = 4
    elif num == 1:
        a = [0] * N
        b = [0] * N
        b[0] = 1                      # multiply by 1 -> identity
    elif num == 2:
        a = [0] * N; a[3] = 5
        b = [0] * N; b[200] = 7       # two deltas, wrap-around subtraction
    else:
        a = [random.randrange(0, 1 << 23) for _ in range(N)]
        b = [random.randrange(0, 1 << 23) for _ in range(N)]
    return a, b


cases = []
for t in range(TRIALS):
    a, b = gen_case(t)
    cases.append((a, b, schoolbook(a, b)))

# ---- build one TB that runs all trials sequentially ----------------------
def emit_vec(name, data):
    out = ["    reg [22:0] %s [0:255];" % name, "    initial begin"]
    out += ["        %s[%d] = 23'd%d;" % (name, i, v) for i, v in enumerate(data)]
    out.append("    end")
    return "\n".join(out)

decl = []
init = []
for t, (a, b, c) in enumerate(cases):
    decl.append(emit_vec("a%d" % t, a))
    decl.append(emit_vec("b%d" % t, b))
    decl.append(emit_vec("c%d" % t, c))

BS = chr(96)
tb = []
tb.append(BS + "timescale 1ns/1ps")
tb.append("module tb_dilithium_mul;")
tb.append("    reg clk = 0, rst_n = 0, start = 0;")
tb.append("    reg [7:0] a_addr, b_addr;")
tb.append("    reg [22:0] a_data, b_data;")
tb.append("    reg a_wr = 0, b_wr = 0;")
tb.append("    wire [7:0] c_addr;")
tb.append("    wire [22:0] c_data;")
tb.append("    wire busy, done;")
tb.append("    reg [1:0] mode = 2'd2;")
tb.append("    reg [22:0] cbuf [0:255];")
tb.append("    integer i, t, errors;")
tb.append("    dilithium_ntt u_dut (")
tb.append("        .clk(clk), .rst_n(rst_n), .start(start), .busy(busy), .done(done),")
tb.append("        .a_addr(a_addr), .a_data(a_data), .a_wr(a_wr),")
tb.append("        .b_addr(b_addr), .b_data(b_data), .b_wr(b_wr),")
tb.append("        .c_addr(c_addr), .c_data(c_data),")
tb.append("        .mode(mode), .omega_k(23'd0)")
tb.append("    );")
tb.append("    always #5 clk = ~clk;")
tb.append("    always @(negedge clk) if (busy && !done) cbuf[c_addr] <= c_data;")
tb.append("\n".join(decl))
tb.append("    initial begin")
tb.append("        errors = 0;")
tb.append("        rst_n = 0; repeat (6) @(negedge clk); rst_n = 1; repeat (4) @(negedge clk);")
for t in range(len(cases)):
    tb.append("        // ---- trial %d ----" % t)
    tb.append("        for (i = 0; i < 256; i = i + 1) begin")
    tb.append("            @(negedge clk); a_addr = i[7:0]; a_data = a%d[i]; a_wr = 1;" % t)
    tb.append("            @(posedge clk); @(negedge clk); a_wr = 0;")
    tb.append("        end")
    tb.append("        for (i = 0; i < 256; i = i + 1) begin")
    tb.append("            @(negedge clk); b_addr = i[7:0]; b_data = b%d[i]; b_wr = 1;" % t)
    tb.append("            @(posedge clk); @(negedge clk); b_wr = 0;")
    tb.append("        end")
    tb.append("        @(negedge clk); start = 1; @(posedge clk); @(negedge clk); start = 0;")
    tb.append("        while (!done) @(negedge clk);")
    tb.append("        @(posedge clk); repeat (3) @(negedge clk);")
    tb.append("        for (i = 0; i < 256; i = i + 1) begin")
    tb.append("            if (cbuf[i] !== c%d[i]) begin" % t)
    disp = ('                if (errors < 10) $display("T' + str(t) +
            ' MISMATCH i=%0d got=%0d exp=%0d", i, cbuf[i], c' + str(t) + '[i]);')
    tb.append(disp)
    tb.append("                errors = errors + 1;")
    tb.append("            end")
    tb.append("        end")
tb.append('        if (errors == 0) $display("POLY_MUL_ALL_PASS ' + str(len(cases)) + ' trials");')
tb.append('        else $display("POLY_MUL_FAIL %0d errors", errors);')
tb.append('        $display("DONE errors=%0d", errors);')
tb.append("        $finish;")
tb.append("    end")
tb.append("endmodule")

tb_path = os.path.join(tempfile.gettempdir(), 'tb_dilithium_mul.v')
with open(tb_path, 'w', encoding='utf-8') as f:
    f.write("\n".join(tb))

tmp = tempfile.mkdtemp(prefix='dil_mul_')
shutil.copy2(tb_path, os.path.join(tmp, 'tb.v'))
for fname in ['dilithium_ntt.v', 'unified_ntt.v']:
    shutil.copy2(os.path.join(RTL_DIR, fname), os.path.join(tmp, fname))

iverilog = r'C:\iverilog\bin\iverilog.exe'
vvp = r'C:\iverilog\bin\vvp.exe'
vvp_out = os.path.join(tmp, 'tb.vvp')
r = subprocess.run([iverilog, '-g2012', '-o', vvp_out,
                    os.path.join(tmp, 'tb.v'),
                    os.path.join(tmp, 'dilithium_ntt.v'),
                    os.path.join(tmp, 'unified_ntt.v')],
                   capture_output=True, text=True, cwd=tmp)
if r.returncode != 0:
    print('[COMPILE FAIL]', r.stderr)
else:
    r = subprocess.run([vvp, vvp_out], capture_output=True, text=True,
                       cwd=tmp, timeout=900)
    for line in r.stdout.split('\n'):
        s = line.strip()
        if any(k in s for k in ('MISMATCH', 'PASS', 'FAIL', 'DONE')):
            print(s)
    if 'POLY_MUL_ALL_PASS' in r.stdout:
        print('RESULT: ALL PASS (%d trials x 256 coefficients, seed=%d)' % (len(cases), SEED))
    else:
        print('RESULT: FAIL')
shutil.rmtree(tmp, ignore_errors=True)
