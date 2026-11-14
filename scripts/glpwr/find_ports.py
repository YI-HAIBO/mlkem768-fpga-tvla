import re, os
p = r"C:/tmp/glpwr_1794120391/gl_board.vcd"
with open(p, "rb") as f:
    hdr = f.read(46_000_000)
i = hdr.find(b"$enddefinitions")
hdr = hdr[:i] if i >= 0 else hdr
print("header_len=%.2fMB enddef_off=%d" % (len(hdr) / 1e6, i))
targets = {"test_led", "busy", "done", "clk", "ss_valid", "ct_valid",
           "post_pass", "post_fail", "test_led0", "test_led_OBUF"}
found = {}
for m in re.finditer(rb"\$var\s+(\S+)\s+(\d+)\s+(\S+)\s+([^\r\n$]+)\s+\$end", hdr):
    nm = m.group(4).decode("latin1").strip()
    if nm in targets:
        found.setdefault(nm, []).append((m.group(2).decode(), m.group(3).decode("latin1")))
for nm in sorted(found):
    lst = found[nm]
    print("%-14s  count=%d  first=%s  last=%s" % (nm, len(lst), lst[0], lst[-1]))
