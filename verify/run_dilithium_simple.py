"""
Simple test case for dilithium_ntt.v.
Tests with a=[1,2,0..], b=[3,4,0..] to isolate pipeline issues.
"""
import os, sys, subprocess, tempfile, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RTL_DIR = os.path.join(ROOT, 'rtl', 'core')

Q = 8380417
N = 256

tmp = tempfile.mkdtemp(prefix='dil_simple_')
print(f"[tmp] {tmp}")

# Simple test: a=[1,2,0..], b=[3,4,0..]
a = [0]*N; a[0] = 1; a[1] = 2
b = [0]*N; b[0] = 3; b[1] = 4
c = [0]*N
for k in range(N):
    s = 0
    for i in range(N):
        s += a[i] * b[(k-i) % N]
    c[k] = s % Q

print(f"[info] a={a[:5]}, b={b[:5]}")
print(f"[info] c[0]={c[0]}, c[1]={c[1]}, c[2]={c[2]}, rest=0")

# Generate testbench
def gen_vector(name, data):
    lines = [f"    reg [22:0] {name} [0:255];"]
    lines.append("    initial begin")
    for i, v in enumerate(data):
        lines.append(f"        {name}[{i}] = 23'd{v};")
    lines.append("    end")
    return "\n".join(lines)

vec_a = gen_vector("a_vec", a)
vec_b = gen_vector("b_vec", b)
vec_c = gen_vector("c_vec", c)

tb_code = f"""`timescale 1ns/1ps

module tb_dilithium_ntt;

    reg clk = 0, rst_n = 0;
    reg start = 0;
    reg [1:0] mode = 2;

    reg [7:0] a_addr;
    reg [22:0] a_data;
    reg a_wr = 0;
    reg [7:0] b_addr;
    reg [22:0] b_data;
    reg b_wr = 0;

    wire [7:0] c_addr;
    wire [22:0] c_data;
    wire busy, done;

    reg [22:0] c_buf [0:255];
    integer c_count;

    dilithium_ntt u_dut (
        .clk(clk), .rst_n(rst_n), .start(start), .busy(busy), .done(done),
        .a_addr(a_addr), .a_data(a_data), .a_wr(a_wr),
        .b_addr(b_addr), .b_data(b_data), .b_wr(b_wr),
        .c_addr(c_addr), .c_data(c_data),
        .mode(mode), .omega_k(23'd0)
    );

    always #5 clk = ~clk;

    // Capture DUT output on each negedge
    always @(negedge clk) begin
        if (busy && !done) begin
            c_buf[c_addr] <= c_data;
            c_count = c_count + 1;
        end
    end

{vec_a}
{vec_b}
{vec_c}

    integer i;
    integer errors = 0;

    initial begin
        c_count = 0;
        rst_n = 0;
        start = 0;
        a_wr = 0;
        b_wr = 0;
        repeat (4) @(negedge clk);
        rst_n = 1;
        repeat (2) @(negedge clk);

        // Load polynomial a
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge clk);
            a_addr = i[7:0];
            a_data = a_vec[i];
            a_wr = 1;
            @(posedge clk);
            @(negedge clk);
            a_wr = 0;
        end

        // Load polynomial b
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge clk);
            b_addr = i[7:0];
            b_data = b_vec[i];
            b_wr = 1;
            @(posedge clk);
            @(negedge clk);
            b_wr = 0;
        end

        repeat (4) @(negedge clk);

        // Start multiplication (mode=2)
        mode = 2;
        @(negedge clk);
        start = 1;
        @(posedge clk);
        @(negedge clk);
        start = 0;

        // Wait for done
        while (!done) @(negedge clk);
        @(posedge clk);
        repeat (4) @(negedge clk);

        $display("DEBUG: c_count=%0d", c_count);
        $display("DEBUG: c_buf[0]=%0d exp=%0d", c_buf[0], c_vec[0]);
        $display("DEBUG: c_buf[1]=%0d exp=%0d", c_buf[1], c_vec[1]);
        $display("DEBUG: c_buf[2]=%0d exp=%0d", c_buf[2], c_vec[2]);
        $display("DEBUG: c_buf[3]=%0d exp=%0d", c_buf[3], c_vec[3]);

        for (i = 0; i < 256; i = i + 1) begin
            if (c_buf[i] !== c_vec[i]) begin
                if (errors < 20)
                    $display("MISMATCH i=%0d: got=%0d exp=%0d", i, c_buf[i], c_vec[i]);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("ALL PASS: 256/256 coefficients match");
        else
            $display("FAIL: %0d mismatches", errors);
        $display("ERRORS=%0d", errors);
        $finish;
    end

endmodule
"""

tb_path = os.path.join(tmp, 'tb_dilithium_ntt.v')
with open(tb_path, 'w', encoding='utf-8') as f:
    f.write(tb_code)

print(f"[tb] {tb_path}")

for fname in ['dilithium_ntt.v', 'unified_ntt.v']:
    shutil.copy2(os.path.join(RTL_DIR, fname), os.path.join(tmp, fname))

iverilog = r'C:\iverilog\bin\iverilog.exe'
vvp = r'C:\iverilog\bin\vvp.exe'

vvp_out = os.path.join(tmp, 'tb_dil_simple.vvp')
cmd = [iverilog, '-g2012', '-o', vvp_out,
       os.path.join(tmp, 'tb_dilithium_ntt.v'),
       os.path.join(tmp, 'dilithium_ntt.v'),
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
