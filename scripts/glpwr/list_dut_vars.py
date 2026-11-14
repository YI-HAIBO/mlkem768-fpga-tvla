# -*- coding: utf-8 -*-
"""List all VCD vars whose scope path ends with /dut, plus search for key nets."""
import sys, re

p = sys.argv[1]
with open(p, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
hdr = buf[:buf.find(b"$enddefinitions")].decode("ascii", errors="replace")

scope_stack = []
dut_vars = []
key_hits = []
KEYS = ("post_pass", "post_fail", "done", "busy", "test_led", "clk_slow", "ss_enc", "ss_valid", "ct_valid", "error_seen")
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
            if path.endswith("/dut"):
                dut_vars.append((width, vid, name))
            for k in KEYS:
                if k in name:
                    key_hits.append((path, width, vid, name))
                    break

print("=== DUT direct vars (%d) ===" % len(dut_vars))
for width, vid, name in dut_vars:
    print("width=%d id=%s name=%s" % (width, vid, name))
print("=== KEY net hits (%d) ===" % len(key_hits))
for path, width, vid, name in key_hits:
    print("scope=%s width=%d id=%s name=%s" % (path, width, vid, name))
