import re, os, sys, time
p = r"C:/tmp/glpwr_1794120391/gl_board.vcd"
IDS = {"busy": "\\'", "done": "W'", "clk": "!", "test_led": "l", "post_fail": "A'"}

def probe():
    sz = os.path.getsize(p)
    with open(p, "rb") as f:
        f.seek(max(0, sz - 4_000_000))
        data = f.read()
    last_ts = 0
    vals = {}
    xc = 0
    for ln in data.split(b"\n"):
        ln = ln.rstrip(b"\r")
        if not ln:
            continue
        if ln[:1] == b"#":
            try:
                last_ts = int(ln[1:])
            except ValueError:
                pass
            continue
        if ln[:1] == b"b":
            sp = ln.split()
            if len(sp) >= 2:
                vals[sp[1]] = sp[0][1:]
        elif ln[:1] in (b"0", b"1", b"x", b"X"):
            vid = ln[1:].strip()
            vals[vid] = ln[:1]
            if ln[:1].lower() == b"x":
                xc += 1
    state = {}
    for nm, vid in IDS.items():
        state[nm] = vals.get(vid.encode(), "?")
    return sz, last_ts, state, xc

sz1, ts1, st1, x1 = probe()
print("t0: size_MB=%.1f last_ts_ps=%d cycles=%.0f busy=%s done=%s X=%d"
      % (sz1 / 1e6, ts1, ts1 / 10000, st1["busy"], st1["done"], x1))
time.sleep(60)
sz2, ts2, st2, x2 = probe()
print("t1: size_MB=%.1f last_ts_ps=%d cycles=%.0f busy=%s done=%s X=%d"
      % (sz2 / 1e6, ts2, ts2 / 10000, st2["busy"], st2["done"], x2))
dcyc = (ts2 - ts1) / 10000
print("rate_cycles_per_sec=%.2f  dcycles=%.0f  dB=%.1fMB" % (dcyc / 60, dcyc, (sz2 - sz1) / 1e6))
if ts2 > ts1:
    rem = 352627 - ts2 / 10000
    print("cycles_to_full_POST=%.0f  eta_hours=%.2f" % (rem, rem / max(dcyc / 60, 0.01) / 3600))
