import os
p = r"C:/tmp/glpwr_1794120391/gl_board.vcd"
sz = os.path.getsize(p)
# ids: busy=\'  done=W'  clk=!  test_led=l
PAT = {b"\\'": "busy", b"W'": "done", b"!": "clk", b"l": "test_led"}
# stream from value section
ts = 0
seen = {}
# We'll collect transitions (ts, value) per signal, capped
trans = {}
with open(p, "rb") as f:
    # skip to enddefinitions
    buf = b""
    j = -1
    while True:
        ch = f.read(8_000_000)
        if not ch:
            break
        buf += ch
        j = buf.find(b"$enddefinitions")
        if j >= 0:
            break
    f.seek(j + len(b"$enddefinitions"))
    prev = {}
    lastval = {}
    while True:
        chunk = f.read(32_000_000)
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
                    vid = sp[1]
                    val = sp[0][1:]
                    nm = PAT.get(vid)
                    if nm:
                        # normalize to 0/1/2 (X)
                        if b"x" in val.lower():
                            v = 2
                        elif val == b"0" * len(val):
                            v = 0
                        elif val == b"1" * len(val):
                            v = 1
                        else:
                            v = 2
                        if prev.get(nm) != v:
                            prev[nm] = v
                            trans.setdefault(nm, []).append((ts, v))
            elif ln[:1] in (b"0", b"1", b"x", b"X"):
                vid = ln[1:].strip()
                val = ln[:1]
                nm = PAT.get(vid)
                if nm:
                    v = 2 if val.lower() == b"x" else (1 if val == b"1" else 0)
                    if prev.get(nm) != v:
                        prev[nm] = v
                        trans.setdefault(nm, []).append((ts, v))

for nm in ["busy", "done", "clk", "test_led"]:
    lst = trans.get(nm, [])
    print("=== %s: %d transitions, first=%s last=%s" % (
        nm, len(lst),
        lst[0] if lst else None, lst[-1] if lst else None))
    # print up to 12 transitions (first 6 + last 6)
    if lst:
        show = lst[:6] + (lst[-6:] if len(lst) > 12 else [])
        for t, v in show:
            print("   ts=%d (cyc=%.0f) val=%s" % (t, t / 10000, {0: "0", 1: "1", 2: "X"}[v]))
