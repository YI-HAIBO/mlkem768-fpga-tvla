# -*- coding: utf-8 -*-
"""Extract transition timeline for key board signals from gate-level VCD.

Prints compact (time,value) transitions for: test_led0, post_pass_reg,
post_fail_reg, done, busy, ct_valid, ss_valid, clk.
Usage: python timeline.py <vcd>
"""
import sys, re

vcd = sys.argv[1]
# ids from header discovery (dut scope)
WANT = {
    "test_led0": "k",
    "post_pass_reg": "z%",
    "post_fail_reg": "}%",
    "done": "W'",
    "busy": "\\'",
    "ct_valid": "Y'",
    "ss_valid": "#\"",
    "clk": "!",
}
# discover ids from header to be safe (overrides above)
with open(vcd, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
idx = buf.find(b"$enddefinitions")
rest = buf[idx + len(b"$enddefinitions"):]
hdr = buf[:idx].decode("ascii", errors="replace")
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
        m = re.match(r"\$var\s+\S+\s+(\d+)\s+(\S+)\s+(\S+)\s+\$end", s)
        if m:
            vid, name = m.group(2), m.group(3)
            path = "/".join(scope_stack)
            if path.endswith("/dut"):
                if name in WANT and name not in ids:
                    ids[name] = vid.encode()
                # also match post_pass_reg_n_0 style
                if name == "post_pass_reg_n_0" and "post_pass_reg" not in ids:
                    ids["post_pass_reg"] = vid.encode()
                if name == "post_fail_reg_n_0" and "post_fail_reg" not in ids:
                    ids["post_fail_reg"] = vid.encode()
                if name == "done" and "done" not in ids:
                    ids["done"] = vid.encode()
                if name == "busy" and "busy" not in ids:
                    ids["busy"] = vid.encode()
                if name == "ct_valid" and "ct_valid" not in ids:
                    ids["ct_valid"] = vid.encode()
                if name == "ss_valid" and "ss_valid" not in ids:
                    ids["ss_valid"] = vid.encode()

id2name = {v: k for k, v in ids.items()}
print("ids=%s" % {k: v.decode() for k, v in ids.items()})

# stream value section, record transitions
trans = {k: [] for k in WANT}  # name -> list[(time,val)]
time_now = 0
data = rest
f = open(vcd, "rb")
CHUNK = 1 << 20

def proc(ln):
    global time_now
    if not ln:
        return
    c = ln[:1]
    if c == b"#":
        time_now = int(ln[1:])
    elif c == b"1" or c == b"0":
        vid = ln[1:].strip()
        nm = id2name.get(vid)
        if nm:
            v = 1 if c == b"1" else 0
            lst = trans[nm]
            if not lst or lst[-1][1] != v:
                lst.append((time_now, v))

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

for nm in WANT:
    lst = trans[nm]
    print("\n=== %s (%d transitions) ===" % (nm, len(lst)))
    # print first 3, last 6, and any 0->1/1->0 around key times
    if not lst:
        print("  (no transitions)")
        continue
    def fmt(t):
        return "%d ns (cyc %d)" % (t, t // 10)
    # first transitions
    for t, v in lst[:3]:
        print("  first: t=%s val=%d" % (fmt(t), v))
    # transitions in window 0..1ms, 3..4ms (POST window), and last
    for t, v in lst:
        if t < 200000:  # 0..200us window
            print("    t=%s val=%d" % (fmt(t), v))
    print("  ...")
    for t, v in lst[-6:]:
        print("  last: t=%s val=%d" % (fmt(t), v))
