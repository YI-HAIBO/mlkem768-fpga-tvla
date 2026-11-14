#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Attribute kyber_ntt's 28,668 LUTs by DIFFING RTL variants.

Why variants and not get_cells
-----------------------------
On Vivado 2026.1 `get_cells -hierarchical` returns an EMPTY list right
after `synth_design` (WARNING: No cells matched 'get_cells -hierarchical
-filter is_leaf_cell') in BOTH batch and project flow, so per-cell
NUM_LUTS queries are unavailable.  Instead:

  * report_utilization -hierarchical  -> top-level totals
  * the synth log's own "Report Cell Usage" + "DSP Final Report" +
    "ROM: Preliminary Mapping Report" tables -> primitive census, DSP
    enumeration, ROM-inference LUT cost
  * `write_verilog -force`            -> full netlist, which we parse in
    Python to bucket LUT/FF cells by source-name substring

Variants (all standalone, xc7a100tcsg324-1, directive RuntimeOptimized):

  V0 baseline      kyber_ntt.v as-is                               -> 28,668
  V1 no_read_mux   `assign read_data = 16'd0;`
                   kills the external 256:1 combinational read MUX
  V2 dist_ram      (* ram_style = "distributed" *) on coeff[]
                   lets Vivado try LUTRAM for the 256x16 array
  V3 no_arith      butterfly / reduce / scale writes become
                   pass-throughs: address-decode + write-mux structure
                   is kept, only fqmul / montgomery / barrett / the
                   16-bit adders are removed

Delta interpretation:
  V0 - V3 = modular-arithmetic datapath cost
  V0 - V1 = external combinational read-MUX cost
  V0 - V2 = distributed-RAM benefit (negative = it made things worse)
  V0 - V4 = register-file + address-decode cost (N=256 -> N=16 shrinks
            the coeff array 16x while the arithmetic stays put)

Each variant lives in its OWN tag dir; an earlier revision of this
script reused one project dir and every variant wiped the previous one.
The tag dir is also Vivado's cwd, so it must never be deleted from
inside the TCL (permission denied).

Outputs -> results/nttvar_<V>_*.{rpt,log,v,txt}
"""
import io, os, re, shutil, subprocess, sys, time

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE = os.path.join(PROJECT, "rtl", "core")
CONST = os.path.join(PROJECT, "constrains")
RESULTS = os.path.join(PROJECT, "results")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART = "xc7a100tcsg324-1"
TOP = "kyber_ntt"
BASE_V = os.path.join(CORE, TOP + ".v")
XDC = os.path.join(CONST, "kem.xdc")
TMP = "C:/tmp_nttvar_" + str(int(time.time()))
VDIR = os.path.join(TMP, "v")

# primitives we care about (Artix-7 7-series)
PRIMS = ["LUT1", "LUT2", "LUT3", "LUT4", "LUT5", "LUT6", "MUXF7", "MUXF8",
         "CARRY4", "DSP48E1", "FDRE", "FDCE", "FDSE", "FDPE", "LDCE",
         "SRLC32E", "SRLC16E", "RAM32X1S", "RAM64X1S", "RAM64M",
         "RAM128X1S", "RAMB36E1", "RAMB18E1", "IBUF", "OBUF", "BUFG"]
LUTS = {"LUT1", "LUT2", "LUT3", "LUT4", "LUT5", "LUT6"}
FLOPS = {"FDRE", "FDCE", "FDSE", "FDPE", "LDCE"}
BUCKETS = ["coeff", "zeta", "fqmul", "montgomery", "barrett", "modadd",
           "modsub", "block_start", "block_cnt", "zeta_cnt", "j_cnt",
           "read_data", "load_data", "aj", "ajl", "zv", "state",
           "layer_idx", "len", "cnt"]

# --------------------------------------------------------------------------- #
# variant generators -- each returns modified RTL source
# --------------------------------------------------------------------------- #
def v0(src):
    return src


def v1_no_read_mux(src):
    old = "    assign read_data = coeff[read_addr];"
    new = ("    // V1: kill the external 256:1 combinational read MUX\n"
           "    assign read_data = 16'd0;")
    assert old in src, "V1 anchor not found"
    return src.replace(old, new)


def v1b_fix_addr(src):
    """Freeze the read address but KEEP the port live.  (Tying read_data to
    a constant, as in V1, makes the whole array dead and collapses the module
    to 52 LUTs -- that measures nothing.)  With a constant address the 256:1
    read MUX is folded to a constant, so V0 - V1b is the read-MUX cost."""
    old = "    assign read_data = coeff[read_addr];"
    new = ("    // V1b: freeze the read address so the 256:1 read MUX folds\n"
           "    // away; read_data still drives the port so the coeff array\n"
           "    // is not dead-code eliminated.\n"
           "    assign read_data = coeff[8'd1];")
    assert old in src, "V1b anchor not found"
    return src.replace(old, new)


def v2_dist_ram(src):
    old = "    reg [BW-1:0] coeff [0:N-1];"
    new = ("    (* ram_style = \"distributed\" *)\n"
           "    reg [BW-1:0] coeff [0:N-1];")
    assert old in src, "V2 anchor not found"
    return src.replace(old, new, 1)


def v3_no_arith(src):
    """Keep every coeff[] write port and every address expression, but
    replace the modular-arithmetic operands with pass-throughs."""
    subs = [
        ("coeff[block_start + j_cnt]       <= $signed(aj_tmp) + $signed(fqmul(zv_tmp, ajl_tmp));",
         "coeff[block_start + j_cnt]       <= ajl_tmp;"),
        ("coeff[block_start + j_cnt + len] <= $signed(aj_tmp) - $signed(fqmul(zv_tmp, ajl_tmp));",
         "coeff[block_start + j_cnt + len] <= aj_tmp;"),
        ("coeff[block_start + j_cnt]       <= barrett_reduce(aj_tmp + ajl_tmp);",
         "coeff[block_start + j_cnt]       <= aj_tmp;"),
        ("coeff[block_start + j_cnt + len] <= fqmul(zv_tmp, $signed(ajl_tmp) - $signed(aj_tmp));",
         "coeff[block_start + j_cnt + len] <= ajl_tmp;"),
        ("coeff[cnt] <= barrett_reduce(coeff[cnt]);",
         "coeff[cnt] <= coeff[cnt];"),
        ("coeff[cnt] <= fqmul(coeff[cnt], 16'd1441);",
         "coeff[cnt] <= coeff[cnt];"),
    ]
    for old, new in subs:
        assert old in src, "V3 anchor not found: %r" % old[:60]
        src = src.replace(old, new)
    return src


def v4_small_n(src):
    """Shrink the coeff array 16x.  The register file, the read MUX and
    the write-address decode all scale with N; the fqmul / montgomery /
    barrett functions do not."""
    for old, new in (("parameter N  = 256", "parameter N  = 16"),
                     ("parameter N = 256", "parameter N = 16")):
        if old in src:
            return src.replace(old, new, 1)
    raise AssertionError("V4 anchor not found")


VARIANTS = [("V0", "baseline",     v0),
            ("V1", "no_read_mux",  v1_no_read_mux),
            ("V1b", "fix_addr",    v1b_fix_addr),
            ("V2", "dist_ram",     v2_dist_ram),
            ("V3", "no_arith",     v3_no_arith),
            ("V4", "n16",          v4_small_n)]

# --------------------------------------------------------------------------- #
# TCL
# --------------------------------------------------------------------------- #
TAIL = """catch { report_utilization -file "$RPT/util.rpt" -hierarchical }
catch { report_common_property -of_objects [current_design]
        -property {NUM_LUTS NUM_LOGIC_LUTS NUM_LUT_FLOPS NUM_LUTRAM
                    NUM_SLICE_LUTS NUM_FLOPS NUM_DSP NUM_BRAM}
        -file "$RPT/common.rpt" }
set d [current_design]
foreach pr {NUM_LUTS NUM_LOGIC_LUTS NUM_LUT_FLOPS NUM_LUTRAM NUM_FLOPS
            NUM_DSP NUM_BRAM NUM_SLICE_LUTS NUM_SLICES} {
    catch { set v 0 }
    catch { set v [get_property $pr $d] }
    puts "SUMMARY @TAG@ $pr=$v"
}
catch { write_verilog -force -nolib "$RPT/netlist.v" }
catch { write_xst -force "$RPT/netlist.xst" }
puts "@TAG@ DONE"
exit
"""

TCL = """set TAG "@TAG@"
set TAGD "@TAGD@"
set VFILE "@VFILE@"
set XDC  "@XDC@"
set PART "@PART@"
set TOP  "@TOP@"
set RPT  "$TAGD/reports"
set PD   "$TAGD/proj"
puts "=== @TAG@ : @NAME@ ==="
if {[file exists $PD]} { file delete -force $PD }
file mkdir $RPT
create_project -force @TAG@ "$PD" -part $PART
add_files "$VFILE"
catch { read_xdc "$XDC" }
synth_design -top $TOP -part $PART -directive RuntimeOptimized
@TAIL@
"""


def _fill(tpl, tag, name, tagd, vpath):
    return (tpl.replace("@TAIL@", TAIL.replace("@TAG@", tag))
             .replace("@TAG@", tag).replace("@NAME@", name)
             .replace("@TAGD@", tagd.replace("\\", "/"))
             .replace("@VFILE@", vpath.replace("\\", "/"))
             .replace("@XDC@", XDC.replace("\\", "/"))
             .replace("@PART@", PART).replace("@TOP@", TOP))


def synth_variant(tag, name, vpath):
    tagd = os.path.join(TMP, tag)
    os.makedirs(tagd, exist_ok=True)
    tcl = os.path.join(tagd, "run.tcl")
    io.open(tcl, "w", encoding="utf-8").write(_fill(TCL, tag, name, tagd, vpath))
    log = os.path.join(tagd, "run.log")
    t0 = time.time()
    try:
        subprocess.run([VIVADO, "-mode", "batch", "-nojournal",
                        "-log", log, "-source", tcl],
                       capture_output=True, text=True, timeout=1800,
                       cwd=tagd, errors="replace")
        rc = 0
    except subprocess.TimeoutExpired:
        rc = -999
    return rc, time.time() - t0, log, tagd


def logs_only(tag, tagd):
    """Vivado stdout: run.log + the project's synth_1 runme.log."""
    out = []
    for root, dirs, files in os.walk(tagd):
        for f in files:
            if not f.lower().endswith(".log"):
                continue
            p = os.path.join(root, f)
            try:
                out.append(io.open(p, encoding="utf-8", errors="replace").read())
            except OSError:
                pass
    return "".join(out)


PRIM_ALT = "|".join(PRIMS)
# instance-name: either "\name" on its own line after the #(...) block, or
# "PRIM name (" for param-less cells
_NAME_A = re.compile(r"\)\s*\n?\s*\\?([^\s(]+)\s*\n?\s*\(")
_NAME_B = re.compile(r"\b(?:%s)\b\s+\\?([^\s(]+)\s*\(" % PRIM_ALT)
_PRIM = re.compile(r"\b(%s)\b" % PRIM_ALT)


def parse_netlist(path):
    """Bucket netlist cells by primitive and by source-name substring.

    Vivado `write_verilog -force -nolib` emits one instance per chunk
    terminated by `;`, laid out like

        LUT6 #(
          .INIT(64'h...))
          \\FSM_sequential_state[0]_i_1
             (.I0(\\... ), ..., .O(net));

    so the instance name sits on its OWN line and must not be assumed to
    be on the same line as `(`.
    """
    cens = {}
    bucket_lut = {}
    bucket_ff = {}
    if not path or not os.path.exists(path):
        return cens, bucket_lut, bucket_ff, []
    txt = io.open(path, encoding="utf-8", errors="replace").read()
    names = []
    for chunk in txt.split(";"):
        m = _PRIM.search(chunk)
        if not m:
            continue
        pri = m.group(1)
        cens[pri] = cens.get(pri, 0) + 1
        mi = _NAME_A.search(chunk) or _NAME_B.search(chunk)
        if not mi:
            continue
        nm = mi.group(1).lstrip("\\")
        names.append(nm)
        ln = nm.lower()
        for b in BUCKETS:
            if b in ln:
                if pri in LUTS:
                    bucket_lut[b] = bucket_lut.get(b, 0) + 1
                elif pri in FLOPS:
                    bucket_ff[b] = bucket_ff.get(b, 0) + 1
    return cens, bucket_lut, bucket_ff, names


def parse_util_rpt(tagd):
    """report_utilization -hierarchical is the reliable source of totals:
    on Vivado 2026.1 `get_property NUM_LUTS [current_design]` returns
    empty right after synth_design, so the puts-based SUMMARY line is
    unusable."""
    out = {}
    for root, dirs, files in os.walk(tagd):
        for f in files:
            if f.lower() != "util.rpt":
                continue
            p = os.path.join(root, f)
            s = io.open(p, encoding="utf-8", errors="replace").read()
            for ln in s.splitlines():
                m = re.match(r"\|\s*([\w.]+)\s*\|\s*\(?\w*\)?\s*\|\s*"
                             r"(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|"
                             r"\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|", ln)
                if not m:
                    continue
                inst = m.group(1)
                out[inst] = {"NUM_LUTS": int(m.group(2)), "NUM_LOGIC_LUTS": int(m.group(3)),
                             "NUM_LUTRAM": int(m.group(4)), "NUM_SRL": int(m.group(5)),
                             "NUM_FLOPS": int(m.group(6)), "NUM_RAMB36": int(m.group(7)),
                             "NUM_RAMB18": int(m.group(8)), "NUM_DSP": int(m.group(9))}
            if out:
                break
    return out


def harvest(tag, tagd):
    dsts = []
    txt = logs_only(tag, tagd)
    for root, dirs, files in os.walk(tagd):
        for f in files:
            if f.lower() in ("util.rpt", "common.rpt", "netlist.v", "netlist.xst"):
                p = os.path.join(root, f)
                d = os.path.join(RESULTS, "nttvar_%s_%s" % (tag, f))
                try:
                    shutil.copy2(p, d)
                    dsts.append(d)
                except OSError:
                    pass
    io.open(os.path.join(RESULTS, "nttvar_%s_alllogs.txt" % tag), "w",
            encoding="utf-8").write(txt)
    dsts.append(os.path.join(RESULTS, "nttvar_%s_alllogs.txt" % tag))

    info = {"summary": {}, "prim_log": {}, "bucket": [], "rom": [],
            "markers": [], "warn": {}}
    for m in re.finditer(r"SUMMARY\s+%s\s+(\w+)=(\S+)" % tag, txt):
        info["summary"][m.group(1)] = m.group(2)
    # NB: the DSP Final Report table has the same "| n | word | n |" shape, so
    # only accept rows whose second column is a known primitive name.
    for m in re.finditer(r"\|\s*(\d+)\s+\|\s*(\w+)\s+\|\s*([\d,]+)\s*\|", txt):
        if m.group(2) not in PRIMS:
            continue
        try:
            info["prim_log"][m.group(2)] = \
                info["prim_log"].get(m.group(2), 0) + int(m.group(3).replace(",", ""))
        except ValueError:
            pass
    for m in re.finditer(
            r"\|\s*([\w.]+)\s*\|\s*([\w.]+)\s*\|\s*(\d+)x(\d+)\s*\|\s*(\w+)\s*\|", txt):
        info["rom"].append((m.group(1), m.group(2), int(m.group(3)),
                            int(m.group(4)), m.group(5)))
    for pat in ("Synthesis Optimization Runtime", "Synthesis Optimization Complete",
                "synth_design completed successfully", "Report Cell Usage",
                "DSP Final Report", "ROM: Preliminary Mapping Report"):
        if pat in txt:
            info["markers"].append(pat)
    for wid in ("8-7186", "8-4767", "8-6849", "8-2914", "8-6090", "8-327", "8-6014"):
        c = txt.count("[Synth %s]" % wid)
        if c:
            info["warn"][wid] = c
    for m in re.finditer(r"(\d+)\s+Bit\s+Registers\s*:=\s*(\d+)", txt):
        info.setdefault("regs", []).append((int(m.group(1)), int(m.group(2))))
    # netlist attribution
    nl = None
    for root, dirs, files in os.walk(tagd):
        for f in files:
            if f.lower() == "netlist.v":
                nl = os.path.join(root, f)
    cens, blut, bff, names = parse_netlist(nl)
    info["cens"] = cens
    info["bucket_lut"] = blut
    info["bucket_ff"] = bff
    info["n_names"] = len(names)
    # report_utilization -hierarchical is authoritative for the totals
    util = parse_util_rpt(tagd)
    info["util"] = util
    if "kyber_ntt" in util:
        info["summary"] = {k: str(v) for k, v in util["kyber_ntt"].items()}
    return info, dsts


def _i(x):
    try:
        return int(x)
    except (TypeError, ValueError):
        return 0


def main():
    # `python probe_ntt_variants.py V1b` runs only the named variants, so a
    # single follow-up probe costs ~3 min instead of the full 20 min set.
    sel = sys.argv[1:]
    VAR = [(t, n, f) for t, n, f in VARIANTS if not sel or t in sel]
    os.makedirs(VDIR, exist_ok=True)
    os.makedirs(RESULTS, exist_ok=True)
    src = io.open(BASE_V, encoding="utf-8").read()
    vpaths = {}
    for tag, name, fn in VAR:
        p = os.path.join(VDIR, "%s_%s.v" % (tag, TOP))
        io.open(p, "w", encoding="utf-8", newline="\n").write(fn(src))
        vpaths[tag] = p
        print("wrote %s  (%d bytes)" % (p, os.path.getsize(p)), flush=True)

    results = {}
    for tag, name, fn in VAR:
        print("\n===== %s (%s) =====" % (tag, name), flush=True)
        rc, el, log, tagd = synth_variant(tag, name, vpaths[tag])
        info, dsts = harvest(tag, tagd)
        results[tag] = info
        print("  rc=%s elapsed=%.1fs" % (rc, el))
        print("  markers: %s" % (", ".join(info["markers"]) or "NONE"))
        print("  %s" % (info["summary"] or "NO SUMMARY"))
        if info["rom"]:
            for mod, obj, d, w, typ in info["rom"]:
                print("  ROM %s/%s %dx%d %s = %d" % (mod, obj, d, w, typ, d * w))
        if info["regs"]:
            print("  regbits=%d %s" % (sum(a * b for a, b in info["regs"]),
                                       info["regs"]))
        if info["warn"]:
            print("  warns: %s" % info["warn"])
        print("  netlist names=%d" % info["n_names"], flush=True)

    # ---- comparison table ------------------------------------------------
    print("\n================ VARIANT COMPARISON ================")
    print("%-4s %-13s %8s %8s %7s %7s %7s %6s %5s %5s %9s %10s %10s" %
          ("tag", "variant", "LUTs", "logicL", "LUTF", "LUTRAM", "SrlL",
           "FFs", "DSP", "BRAM", "netLUT", "netFF", "netMUXF"))
    base = None
    for tag, name, fn in VAR:
        s = results[tag]["summary"]
        if not s:
            print("%-4s %-13s %s" % (tag, name, "(no summary)"))
            continue
        cl = sum(results[tag]["cens"].get(k, 0) for k in LUTS)
        cf = sum(results[tag]["cens"].get(k, 0) for k in FLOPS)
        cm = results[tag]["cens"].get("MUXF7", 0) + results[tag]["cens"].get("MUXF8", 0)
        print("%-4s %-13s %8d %8s %7s %7s %7s %6d %5s %5s %9d %10d %10d" %
              (tag, name, _i(s.get("NUM_LUTS")), s.get("NUM_LOGIC_LUTS"),
               s.get("NUM_LUT_FLOPS"), s.get("NUM_LUTRAM"), s.get("NUM_SLICE_LUTS"),
               _i(s.get("NUM_FLOPS")), s.get("NUM_DSP"), s.get("NUM_BRAM"),
               cl, cf, cm))
        if tag == "V0":
            base = _i(s.get("NUM_LUTS"))

    if base:
        print("\n--- deltas vs V0 (baseline %d LUTs) ---" % base)
        for tag, name, fn in VAR:
            if tag == "V0":
                continue
            s = results[tag]["summary"]
            v = _i(s.get("NUM_LUTS")) if s else 0
            if not v:
                continue
            print("  %s %-13s %7d LUTs   delta %+6d  (%+.1f%%)"
                  % (tag, name, v, v - base, 100.0 * (v - base) / base))

    # ---- primitive census diff (from the synth log's own table) ---------
    print("\n--- primitive census per variant (synth-log 'Report Cell Usage') ---")
    tags = [t for t, _, _ in VAR]
    allk = set()
    for t in tags:
        allk |= set(results[t]["prim_log"])
    print("%-10s" % "prim" + "".join("%10s" % t for t in tags))
    for k in sorted(allk, key=lambda x: -max(results[t]["prim_log"].get(x, 0)
                                             for t in tags)):
        vals = [results[t]["prim_log"].get(k, 0) for t in tags]
        if max(vals) == 0:
            continue
        print("%-10s" % k + "".join("%10d" % v for v in vals))

    # ---- name buckets from the netlist ----------------------------------
    print("\n--- LUT cells per name bucket (netlist parse) ---")
    bk = {}
    for t in tags:
        for k, v in results[t]["bucket_lut"].items():
            bk.setdefault(k, {})[t] = v
    if bk:
        print("%-13s" % "bucket" + "".join("%10s" % t for t in tags))
        for k in sorted(bk, key=lambda p: -bk[p].get("V0", 0)):
            print("%-13s" % k + "".join("%10d" % bk[k].get(t, 0) for t in tags))
    print("\n--- FF cells per name bucket (netlist parse) ---")
    bk2 = {}
    for t in tags:
        for k, v in results[t]["bucket_ff"].items():
            bk2.setdefault(k, {})[t] = v
    if bk2:
        print("%-13s" % "bucket" + "".join("%10s" % t for t in tags))
        for k in sorted(bk2, key=lambda p: -bk2[p].get("V0", 0)):
            print("%-13s" % k + "".join("%10d" % bk2[k].get(t, 0) for t in tags))
    if not bk and not bk2:
        print("  (no buckets -- netlist.v was not produced)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
