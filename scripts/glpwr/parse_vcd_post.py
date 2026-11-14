# -*- coding: utf-8 -*-
"""Parse gate-level VCD: confirm POST via test_led[15:0] + diagnose X-propagation.

Handles VCD var lines with optional range suffix:
    "$var wire 16 l test_led [15:0] $end"  (vector)
    "$var wire 1 z% post_pass_reg_n_0 $end"  (scalar)
Tracks 16-bit test_led port (id l) value history + X presence, and scalar
post_pass/post_fail/done/busy/ct_valid/ss_valid. Counts total X value lines.
Usage: python parse_vcd_post.py <vcd>
"""
import sys, re

vcd = sys.argv[1]
TARGET = 0x4401
WANT = ["test_led", "post_pass_reg_n_0", "post_fail_reg_n_0", "done", "busy", "ct_valid", "ss_valid", "clk"]

with open(vcd, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
idx = buf.find(b"$enddefinitions")
if idx < 0:
    print("NO_ENDDEFINITIONS")
    sys.exit(1)
rest = buf[idx + len(b"$enddefinitions"):]
hdr = buf[:idx].decode("ascii", errors="replace")

# regex: optional range suffix WITH its leading space
VRE = re.compile(r"\$var\s+\S+\s+(\d+)\s+(\S+)\s+(\S+)(\s+\[\d+:\d+\])?\s+\$end")
ids = {}
scope_stack = []
for line in hdr.splitlines():
    s = line.strip()
    if s.startswith("$scope"):
        parts = s.split()
        if len(parts) >= 3:
            scope_stack.append(parts[2])
    elif s.startswith("$upscope"):
        if scope_stack:
            scope_stack.pop()
    elif s.startswith("$var"):
        m = VRE.match(s)
        if m:
            width, vid, name = int(m.group(1)), m.group(2), m.group(3)
            path = "/".join(scope_stack)
            if path.endswith("/dut"):
                for w in WANT:
                    if name == w and w not in ids:
                        ids[w] = (vid.encode(), width)
                        print("found %-18s id=%s width=%d" % (w, vid, width))

missing = [w for w in WANT if w not in ids]
if missing:
    print("MISSING: %s" % ",".join(missing))
if "test_led" not in ids:
    print("NO_TEST_LED")
    sys.exit(1)

# stream value section
data = rest
time_now = 0
tl_final = None
tl_first_pass = None
tl_pass_count = 0
tl_ever_x = False
tl_trans = 0
x_count = 0
scalar_first = {}
scalar_last = {}
max_time = 0
tl_id = ids["test_led"][0]
scalar_ids = {w: ids[w][0] for w in WANT if w != "test_led" and w in ids}

def parse_vec(vb):
    """Return (value, has_x). Treat x/z bit as 0 but flag."""
    has_x = False
    v = 0
    for ch in vb:
        v <<= 1
        if ch == 49:  # '1'
            v |= 1
        elif ch == 120 or ch == 122:  # x/z
            has_x = True
    return v, has_x

def proc(ln):
    global time_now, tl_final, tl_first_pass, tl_pass_count, tl_ever_x, tl_trans, x_count, max_time
    if not ln:
        return
    c = ln[:1]
    if c == b"#":
        time_now = int(ln[1:])
        if time_now > max_time:
            max_time = time_now
    elif c == b"b":
        sp = ln.find(b" ")
        if sp != -1:
            vb, vid = ln[1:sp], ln[sp + 1:].strip()
            if vid == tl_id:
                v, hx = parse_vec(vb)
                if hx:
                    tl_ever_x = True
                    x_count += 1
                tl_trans += 1
                tl_final = v
                if not hx and v == TARGET:
                    tl_pass_count += 1
                    if tl_first_pass is None:
                        tl_first_pass = time_now
    elif c == b"1" or c == b"0":
        vid = ln[1:].strip()
        v = 1 if c == b"1" else 0
        for w, wid in scalar_ids.items():
            if vid == wid:
                if w not in scalar_first:
                    scalar_first[w] = (time_now, v)
                scalar_last[w] = (time_now, v)
    elif c == b"x" or c == b"X":
        x_count += 1

f = open(vcd, "rb")
CHUNK = 1 << 20
while True:
    lines = data.split(b"\n")
    tail = lines.pop() if lines else b""
    for ln in lines:
        proc(ln)
    chunk = f.read(CHUNK)
    if not chunk:
        break
    data = tail + chunk
f.close()
if data.strip():
    for ln in data.split(b"\n"):
        proc(ln)

print("\n=== RESULTS ===")
print("max_time_ns=%d (cyc %d)" % (max_time, max_time // 10))
print("test_led transitions=%d  final=0x%04X  ever_X=%s  X_lines=%d  pass_count=%d"
      % (tl_trans, tl_final if tl_final is not None else -1,
         tl_ever_x, x_count, tl_pass_count))
print("test_led first pass @ %s ns" % (tl_first_pass if tl_first_pass is not None else "NEVER"))
print("--- scalar signals (first / last) ---")
for w in sorted(scalar_ids):
    fr = scalar_first.get(w)
    lr = scalar_last.get(w)
    print("  %-18s first=%s  last=%s" % (
        w,
        ("t=%dns v=%d" % fr) if fr else "NONE",
        ("t=%dns v=%d" % lr) if lr else "NONE"))
if tl_final == TARGET and tl_pass_count > 0:
    print("VERDICT: POST_PASS (test_led==0x4401)")
else:
    print("VERDICT: POST_NOT_CONFIRMED (test_led=0x%04X)" % (tl_final if tl_final is not None else -1))
