# -*- coding: utf-8 -*-
"""Find specific VCD var declarations (test_led / clk) and their scope path.

Writes matches to out file. Usage:
  python find_vcd_var.py <vcd> <outfile>
"""
import sys, re

p, out = sys.argv[1], sys.argv[2]
with open(p, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
hdr = buf[:buf.find(b"$enddefinitions")].decode("ascii", errors="replace")

# track scope path as we scan var lines
scope_stack = []
results = []
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
            if name in ("test_led", "clk") or "test_led" in name:
                path = "/".join(scope_stack)
                results.append((path, typ, width, vid, name))

with open(out, "w", encoding="utf-8") as f:
    for r in results:
        f.write("scope=%s type=%s width=%d id=%s name=%s\n" % r)
print("found %d matches -> %s" % (len(results), out))
