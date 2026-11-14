# -*- coding: utf-8 -*-
"""Print VCD ids for a focused set of key nets (dut scope + any scope)."""
import sys, re

p = sys.argv[1]
KEYS = ("test_led", "post_pass", "post_fail", "done", "busy", "clk_slow", "ss_enc", "ss_valid", "ct_valid", "error_seen")
with open(p, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
hdr = buf[:buf.find(b"$enddefinitions")].decode("ascii", errors="replace")

scope_stack = []
found = []
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
        m = re.match(r"\$var\s+(\S+)\s+(\d+)\s+(\S+)\s+(\S+)\s+\$end", s)
        if m:
            typ, width, vid, name = m.group(1), int(m.group(2)), m.group(3), m.group(4)
            path = "/".join(scope_stack)
            for k in KEYS:
                if k in name:
                    found.append((path, width, vid, name))
                    break

print("found=%d" % len(found))
for path, width, vid, name in found:
    print("scope=%-55s w=%d id=%-3s name=%s" % (path, width, vid, name))
