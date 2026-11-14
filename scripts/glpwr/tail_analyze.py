"""Analyze the tail of a growing VCD: build header id->name map, then scan tail
for value transitions of key signals and X distribution per id."""
import re, os, sys, collections

VCD = sys.argv[1] if len(sys.argv) > 1 else r"C:/tmp/glpwr_1794120391/gl_board.vcd"
TAIL = int(sys.argv[2]) if len(sys.argv) > 2 else 12_000_000

sz = os.path.getsize(VCD)
print("total_size_MB=%.1f" % (sz / 1e6))

# --- build header map: read until $enddefinitions ---
hdr = b""
with open(VCD, "rb") as f:
    while True:
        chunk = f.read(8_000_000)
        if not chunk:
            break
        hdr += chunk
        j = hdr.find(b"$enddefinitions")
        if j >= 0:
            hdr = hdr[:j]
            break
print("header_size_MB=%.2f" % (len(hdr) / 1e6))

vids = {}
for m in re.finditer(rb"\$var\s+\S+\s+(\d+)\s+(\S+)\s+(\S+)", hdr):
    vid = m.group(2).decode("latin1")
    nm = m.group(3).decode("latin1")
    w = int(m.group(1))
    vids[vid] = (nm, w)

WANT = ["test_led", "busy", "done", "post_pass_reg_n_0", "post_fail_reg_n_0",
        "clk", "ss_valid", "ct_valid", "test_led0"]
idmap = {}
for vid, (nm, w) in vids.items():
    if nm in WANT:
        idmap[nm] = vid
print("idmap=", idmap)

# --- scan tail ---
with open(VCD, "rb") as f:
    f.seek(max(0, sz - TAIL))
    data = f.read()

per_sig = collections.defaultdict(lambda: [0, 0])
last_ts = 0
x_per_id = collections.Counter()
cur = {}
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
            val = sp[0][1:]
            vid = sp[1]
            cur[vid] = val
            if b"x" in val.lower():
                x_per_id[vid] += 1
    elif ln[:1] in (b"0", b"1", b"x", b"X"):
        vid = ln[1:].strip()
        val = ln[:1]
        cur[vid] = val
        if val.lower() == b"x":
            x_per_id[vid] += 1

print("tail_last_ts_ps=%d  (cycles at 10ns=%.0f)" % (last_ts, last_ts / 10000))
print("X per id (top 15):")
for vid, n in x_per_id.most_common(15):
    nm, w = vids.get(vid, ("?", 0))
    print("  id=%-8r name=%-30s w=%-3d X=%d" % (vid, nm, w, n))
print("--- key signals in tail ---")
for k in WANT:
    if k in idmap:
        vid = idmap[k]
        print("  %-20s id=%-4s last=%s" % (k, vid, cur.get(vid, "?")))
