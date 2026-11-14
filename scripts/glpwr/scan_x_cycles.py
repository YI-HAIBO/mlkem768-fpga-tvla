import os, re, time
p = r"C:/tmp/glpwr_1794120391/gl_board.vcd"
sz = os.path.getsize(p)
print("snapshot_MB=%.1f" % (sz / 1e6), flush=True)
# forward stream; a timestamp line = starts with '#' then digits only (rest is \r\n)
# We track per-cycle X flag. Cycle = ts//10000.
ts = 0
cur_has_x = False
x_cycles = []
first_x_cycle = None
last_x_cycle = None
x_cycle_count = 0
# only store first/last few
with open(p, "rb") as f:
    # skip header
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
    prev_line_was_ts = False
    while True:
        chunk = f.read(32_000_000)
        if not chunk:
            break
        for ln in chunk.split(b"\n"):
            ln = ln.rstrip(b"\r")
            if not ln:
                continue
            c = ln[:1]
            if c == b"#":
                # possible timestamp
                digits = ln[1:]
                if digits.isdigit():
                    # finalize previous cycle
                    if cur_has_x:
                        x_cycle_count += 1
                        if first_x_cycle is None:
                            first_x_cycle = ts // 10000
                        last_x_cycle = ts // 10000
                    cur_has_x = False
                    ts = int(digits)
                continue
            if c == b"b":
                sp = ln.split()
                if len(sp) >= 2 and (b"x" in sp[0][1:].lower() or b"X" in sp[0][1:]):
                    cur_has_x = True
            elif c in (b"x", b"X"):
                cur_has_x = True
    # finalize last
    if cur_has_x:
        x_cycle_count += 1
        if first_x_cycle is None:
            first_x_cycle = ts // 10000
        last_x_cycle = ts // 10000

print("final_ts_ps=%d  cycles=%.0f" % (ts, ts / 10000))
print("cycles_with_X=%d" % x_cycle_count)
print("first_X_cycle=%s  last_X_cycle=%s" % (first_x_cycle, last_x_cycle))
print("clean_cycles_after_lastX=%s" % ("%.0f" % (ts / 10000 - last_x_cycle) if last_x_cycle is not None else "all"))
