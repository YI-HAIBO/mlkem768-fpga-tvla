# -*- coding: utf-8 -*-
"""Probe a live (growing) VCD: report last time, est cycles, X count, and
busy/done/post_pass transitions so far. Reads only the tail + a scan for the
key scalar ids (cheap, bounded)."""
import sys, re

p = sys.argv[1]
sz = 0
import os
if os.path.exists(p):
    sz = os.path.getsize(p)

# scan tail for latest time marker
last_time = None
x_tail = 0
with open(p, "rb") as f:
    f.seek(max(0, sz - 300000))
    tail = f.read().decode("ascii", errors="replace")
tm = re.findall(r"(?m)^#(\d+)", tail)
if tm:
    last_time = int(tm[-1])
x_tail = len(re.findall(r"(?m)^[xX]", tail))

# find busy/done/test_led ids (need header scan) — do a light pass reading
# only until $enddefinitions, then sample the value section for these ids.
# To keep it cheap we read the whole file ONCE but only track 3 ids.
ids = {}
with open(p, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
idx = buf.find(b"$enddefinitions")
if idx < 0:
    print("no enddefinitions yet")
    sys.exit(0)
hdr = buf[:idx].decode("ascii", errors="replace")
rest = buf[idx + len(b"$enddefinitions"):]
WANT = {"test_led": None, "busy": None, "done": None}
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
        m = re.match(r"\$var\s+\S+\s+(\d+)\s+(\S+)\s+(\S+)(\s+\[\d+:\d+\])?\s+\$end", s)
        if m:
            vid, name = m.group(2), m.group(3)
            path = "/".join(scope_stack)
            if path.endswith("/dut") and name in WANT and WANT[name] is None:
                WANT[name] = vid.encode()

# sample value section (bounded: just read all, count transitions for our ids)
time_now = 0
tl_last = None
busy_last = None
done_last = None
tl_first1 = None
busy_first1 = None
done_first1 = None
data = rest
f = open(p, "rb")
CH = 1 << 20
def proc(ln):
    global time_now, tl_last, busy_last, done_last, tl_first1, busy_first1, done_first1
    if not ln:
        return
    c = ln[:1]
    if c == b"#":
        time_now = int(ln[1:])
    elif c == b"1" or c == b"0":
        vid = ln[1:].strip()
        v = 1 if c == b"1" else 0
        if vid == WANT["test_led"]:
            tl_last = (time_now, v)
            if v == 1 and tl_first1 is None:
                tl_first1 = time_now
        elif vid == WANT["busy"]:
            busy_last = (time_now, v)
            if v == 1 and busy_first1 is None:
                busy_first1 = time_now
        elif vid == WANT["done"]:
            done_last = (time_now, v)
            if v == 1 and done_first1 is None:
                done_first1 = time_now
while True:
    lines = data.split(b"\n")
    tail2 = lines.pop() if lines else b""
    for ln in lines:
        proc(ln)
    chunk = f.read(CH)
    if not chunk:
        break
    data = tail2 + chunk
f.close()

print("size_MB=%.1f" % (sz / 1e6))
print("last_time_ps=%s  est_cycles=%s" % (last_time, (last_time // 10000) if last_time else "NA"))
print("X_in_tail=%d" % x_tail)
print("ids=%s" % {k: v.decode() for k, v in WANT.items()})
print("busy first1=%s last=%s" % (busy_first1, busy_last))
print("done first1=%s last=%s" % (done_first1, done_last))
print("test_led last=%s" % (tl_last,))
