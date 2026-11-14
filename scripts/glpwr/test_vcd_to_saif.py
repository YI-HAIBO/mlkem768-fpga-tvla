"""Synthetic VCD -> SAIF correctness test for vcd_to_saif.py."""
import os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
_CONV = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "vcd_to_saif.py")
spec = importlib.util.spec_from_file_location("v2s", _CONV)
v2s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v2s)

# Build a tiny VCD with CRLF endings, vector [15:0] name, ids with # and \
vcd = (
    "$timescale 1ps $end\r\n"
    "$scope module tb $end\r\n"
    "$scope module dut $end\r\n"
    "$var wire 1 ! clk $end\r\n"
    "$var wire 16 l test_led [15:0] $end\r\n"
    "$var wire 1 \\' busy $end\r\n"
    "$var wire 1 #\" flag $end\r\n"
    "$upscope $end\r\n"
    "$upscope $end\r\n"
    "$enddefinitions $end\r\n"
    "$dumpvars\r\n"
    "0!\r\n"          # clk=0 at t=0
    "b0000000000000000 l\r\n"   # test_led=0
    "0\\'\r\n"        # busy=0
    "0#\"\r\n"        # flag=0
    "$end\r\n"
    "#5000\r\n"       # t=5000ps
    "1!\r\n"          # clk=1
    "#10000\r\n"
    "0!\r\n"          # clk=0
    "1\\'\r\n"        # busy=1
    "b0000000000000001 l\r\n"   # test_led=1
    "#15000\r\n"
    "1!\r\n"
    "0\\'\r\n"        # busy=0
    "#20000\r\n"
    "0!\r\n"
    "1#\"\r\n"        # flag=1
    "#25000\r\n"
    "1!\r\n"
    "b1111111111111111 l\r\n"   # test_led=all-ones
    "#30000\r\n"
    "0!\r\n"
)

tmp = tempfile.mkdtemp()
vcd_p = os.path.join(tmp, "t.vcd")
saif_p = os.path.join(tmp, "t.saif")
with open(vcd_p, "w") as f:
    f.write(vcd)

idmap, hdr_end = v2s.build_id_map(vcd_p, dut_scope="dut")
print("idmap:", idmap)
print("header_end:", hdr_end)
stats, max_time = v2s.stream_stats(vcd_p, idmap, hdr_end)
print("max_time_ps:", max_time)
# clk: toggles 0->1->0->1->0->1->0 over 0..30000ps; DURATION=30000ps=30ns
# expected clk: T0 + T1 = 30000 ps, TC = 6
print("stats:")
for k, v in sorted(stats.items()):
    t0, t1, tx, tc = v
    print("  %-12s t0=%d t1=%d tx=%d tc=%d  (sum=%d)" % (
        k, t0, t1, tx, tc, t0 + t1 + tx))
# checks
assert max_time == 30000, max_time
clk = stats["clk"]
assert clk[3] == 6, clk          # 6 toggles
assert abs((clk[0] + clk[1] + clk[2]) - 30000) <= 1, clk  # all time accounted
busy = stats["busy"]
assert busy[3] == 2, busy        # 0->1->0
flag = stats["flag"]
assert flag[3] == 1, flag        # 0->1
# test_led: 0 -> 1 -> all-ones : 2 toggles, classify 0,1,1
tl = stats["test_led"]
assert tl[3] == 2, tl
assert "test_led" in idmap.values()
print("ALL ASSERTIONS PASSED")
