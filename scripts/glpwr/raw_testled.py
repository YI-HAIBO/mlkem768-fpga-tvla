# -*- coding: utf-8 -*-
"""Raw substring search of VCD header for 'test_led' and 'OBUF' lines."""
import sys

p = sys.argv[1]
with open(p, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c
hdr = buf[:buf.find(b"$enddefinitions")].decode("ascii", errors="replace")
lines = hdr.splitlines()
scope_stack = []
for line in lines:
    s = line.strip()
    if s.startswith("$scope"):
        parts = s.split()
        if len(parts) >= 3:
            scope_stack.append(parts[2])
    elif s.startswith("$upscope"):
        if scope_stack:
            scope_stack.pop()
    elif s.startswith("$var") and "test_led" in s:
        print("scope=%s :: %s" % ("/".join(scope_stack), s))
