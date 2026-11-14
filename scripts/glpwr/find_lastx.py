import os
p = r"C:/tmp/glpwr_1794120391/gl_board.vcd"
sz = os.path.getsize(p)
print("snapshot_MB=%.1f" % (sz / 1e6))
# reverse scan for last X occurrence
BLK = 20_000_000
lastx_off = -1
ts_of_lastx = None
end = sz
with open(p, "rb") as f:
    while end > 0 and lastx_off < 0:
        start = max(0, end - BLK)
        f.seek(start)
        d = f.read(end - start)
        # find last X
        for pat in (b"x", b"X"):
            ix = d.rfind(pat)
            if ix >= 0 and ix > lastx_off:
                lastx_off = start + ix
        if lastx_off >= 0:
            # find preceding timestamp '#' followed by digits
            pos = lastx_off - start
            while pos > 0:
                j = d.rfind(b"#", 0, pos)
                if j < 0:
                    break
                k = j + 1
                while k < len(d) and d[k:k+1].isdigit():
                    k += 1
                if k > j + 1:
                    ts_of_lastx = int(d[j+1:k])
                    break
                pos = j - 1
        end = start
print("last_X_off=%d  ts_of_lastX_ps=%s  cyc_of_lastX=%s"
      % (lastx_off, ts_of_lastx,
         ("%.0f" % (ts_of_lastx / 10000)) if ts_of_lastx is not None else "None"))
