import re, os, sys
p = r"C:/tmp/glpwr_1794120391/gl_board.vcd"
# ids: busy=\'  done=W'  clk=!  test_led=l  post_fail=A'  test_led0=k  ct_valid=Y'  ss_valid=#"
ID = {"busy": b"\\'", "done": b"W'", "test_led": b"l", "post_fail": b"A'",
      "test_led0": b"k", "ct_valid": b"Y'", "ss_valid": b'#"'}
cur = {}
first1 = {}
last1 = {}
xcount = 0
nlines = 0
ts = 0
# find value section start (skip header)
sz = os.path.getsize(p)
with open(p, "rb") as f:
    # skip header
    f.seek(0)
    buf = b""
    j = -1
    while True:
        chunk = f.read(8_000_000)
        if not chunk:
            break
        buf += chunk
        j = buf.find(b"$enddefinitions")
        if j >= 0:
            break
    # value section starts right after "$enddefinitions" at absolute offset j
    f.seek(j + len(b"$enddefinitions"))
    # stream parse
    while True:
        chunk = f.read(64_000_000)
        if not chunk:
            break
        for ln in chunk.split(b"\n"):
            ln = ln.rstrip(b"\r")
            if not ln:
                continue
            if ln[:1] == b"#":
                try:
                    ts = int(ln[1:])
                except ValueError:
                    pass
                continue
            if ln[:1] == b"b":
                sp = ln.split()
                if len(sp) >= 2:
                    val = sp[0][1:]
                    vid = sp[1]
                    cur[vid] = val
                    if b"x" in val.lower():
                        xcount += 1
                    for nm, bvid in ID.items():
                        if bvid == vid:
                            if val != b"0" * len(val):
                                first1.setdefault(nm, ts)
                                last1[nm] = ts
            elif ln[:1] in (b"0", b"1", b"x", b"X"):
                vid = ln[1:].strip()
                val = ln[:1]
                cur[vid] = val
                if val.lower() == b"x":
                    xcount += 1
                for nm, bvid in ID.items():
                    if bvid == vid:
                        if val != b"0":
                            first1.setdefault(nm, ts)
                            last1[nm] = ts
print("total_cycles=%.0f  X_lines=%d" % (ts / 10000, xcount))
for nm in ID:
    f1 = first1.get(nm)
    l1 = last1.get(nm)
    print("%-12s first1=%s last1=%s" % (nm,
          ("%.0f" % (f1 / 10000)) if f1 else "None",
          ("%.0f" % (l1 / 10000)) if l1 else "None"))
