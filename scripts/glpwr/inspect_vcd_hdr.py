# -*- coding: utf-8 -*-
"""Inspect VCD header: scope structure + var declarations matching keywords."""
import sys, re

p = sys.argv[1]
kws = sys.argv[2].split(",") if len(sys.argv) > 2 else ["test", "led", "clk", "ss", "post", "valid"]

with open(p, "rb") as f:
    buf = b""
    while b"$enddefinitions" not in buf:
        c = f.read(1 << 20)
        if not c:
            break
        buf += c

hdr = buf[:buf.find(b"$enddefinitions")].decode("ascii", errors="replace")
print("header len=%d" % len(hdr))

print("--- SCOPES ---")
# scope declarations
for m in re.finditer(r"(\$scope\s+\w+\s+(\S+))\s+\$end", hdr):
    print(m.group(2))

print("--- MATCHING VARS ---")
for m in re.finditer(r"(\$var\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+\$end)", hdr):
    nm = m.group(3)
    if any(k in nm for k in kws):
        print(m.group(1))

print("--- VAR COUNT ---")
print(len(re.findall(r"\$var\s", hdr)))
