#!/usr/bin/env python3
"""Gate-level simulation of the board_top netlist for §8.5 SAIF power.

Step 2-4 of the gate-level flow.  Mirrors the ML-DSA run_gl_sim.py recipe,
adapted to Artix-7 xc7a100t (CARRY4 / RAMD64E / DSP48E1 / SRL16E ...) and the
ML-KEM board_top netlist.

  netlist (funcsim, UNISIM prims)
     + tb_gl_board.v (drives clk/rst, waits test_led, dumps dut)
     + tb_gl_board_top.v (wrapper: TB as instance + glbl instance)
     + glbl_sim.v (GSR/GTS held low)
     -> iverilog -g2012 -s tb_gl_board_top -> vvp -> gl_board.vcd

Usage:
    python scripts/glpwr/run_gl_sim.py [--work WORK] [--sessions N]
        [--compile] [--no-run]

PRIMS are auto-detected from the netlist (module instantiations), then mapped
to Vivado's UNISIM funcsim models (unisims/<P>.v, retarget for FDCPE/FDCP).
"""
import os, re, sys, time, subprocess, argparse

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
PROJ = os.path.abspath(os.path.join(ROOT, ".."))
VIVADO_SRC = r"D:/FPGA/2026.1/Vivado/data/verilog/src"
IVL = r"C:/iverilog/bin/iverilog.exe"
VVP = r"C:/iverilog/bin/vvp.exe"

# non-primitive module names that may appear as instantiations
NON_PRIM = {"glbl", "glbl_xilinx_startup", "ipx_aoi_sec_board_top",
            "kyber_kem", "kyber_poly", "kyber_ntt", "kyber_sampler",
            "shake", "keccak_perm", "tb_gl_board", "tb_gl_board_top"}
RETARGET = {"FDCPE", "FDCP"}   # no direct funcsim model -> retarget wrappers

# names that need the retarget/ or a special source location
RETARGET_DIR = {"FDCPE": "retarget", "FDCP": "retarget"}

# uppercase Verilog keywords (never instantiated) — safety skip
KW_SKIP = {"MODULE", "ENDMODULE", "INPUT", "OUTPUT", "INOUT", "WIRE", "REG",
           "PARAMETER", "LOCALPARAM", "GENERATE", "ENDGENERATE", "ASSIGN",
           "INITIAL", "ALWAYS", "CASE", "BEGIN", "END", "INTEGER", "REAL",
           "GENVAR", "IF", "ELSE", "FOR", "WHILE", "SPECIFY", "ENDSPECIFY"}


def _skip_balanced(txt, i, oc="(", cc=")"):
    """Index just after the balanced group starting at txt[i]==oc."""
    depth = 0
    while i < len(txt):
        c = txt[i]
        if c == oc:
            depth += 1
        elif c == cc:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return i


# whitespace that may separate `#(...)`/name from the instance identifier
_WS = " \t\r\n"


def detect_prims(netlist):
    """Return sorted set of UNISIM primitives instantiated in the netlist.

    Robust to parameter overrides `#(...)` that themselves contain nested
    parens (e.g. `.INIT(64'h...)` inside `LUT6 #(...)`), which a naive
    `[^)]*` regex silently truncates and drops the largest prim class (LUT).
    """
    txt = open(netlist, encoding="utf-8", errors="replace").read()
    prims = set()
    # at start of line: uppercase identifier (prim candidate)
    for m in re.finditer(r"(?m)^[ \t]*([A-Z][A-Z0-9_]*)\b", txt):
        name = m.group(1)
        if name in NON_PRIM or name in KW_SKIP:
            continue
        i = m.end()
        while i < len(txt) and txt[i] in _WS:
            i += 1
        # optional #(...) param override with balanced parens
        if i < len(txt) and txt[i] == "#":
            i += 1
            while i < len(txt) and txt[i] in _WS:
                i += 1
            if i < len(txt) and txt[i] == "(":
                i = _skip_balanced(txt, i)
                while i < len(txt) and txt[i] in _WS:
                    i += 1
        # instance name followed by '('  ->  it is an instantiation.
        # Vivado emits escaped identifiers (leading '\', e.g. \li[4]_i_1),
        # so accept a leading backslash in the instance name.
        # BOUNDED slice: txt[i:] on a 22 MB netlist per match is O(n^2) and
        # OOMs the process (SIGTERM) — take a 256-char lookahead instead.
        if re.match(r"[A-Za-z_\\][\w\$\[\].]*\s*\(", txt[i:i + 256]):
            prims.add(name)
    return sorted(prims)


def prim_source(prim):
    """Return the Vivado source file for a primitive, or None."""
    if prim in RETARGET_DIR:
        f = os.path.join(VIVADO_SRC, RETARGET_DIR[prim], prim + ".v")
    else:
        f = os.path.join(VIVADO_SRC, "unisims", prim + ".v")
    return f if os.path.exists(f) else None


def prep_netlist(netlist, netlist_prep):
    """Rename Vivado's own `module glbl` so our stub owns that name."""
    t = open(netlist, encoding="utf-8", errors="replace").read()
    if re.search(r"(?m)^\s*module\s+glbl\s*\(\s*\)", t):
        t = re.sub(r"(?m)^(\s*)module\s+glbl\s*\(\s*\)",
                   r"\1module glbl_xilinx_startup ()", t, count=1)
    open(netlist_prep, "w", encoding="utf-8").write(t)
    return netlist_prep


def compile_sim(netlist, workdir):
    netlist_prep = os.path.join(workdir, "gl_netlist_sim.v")
    prep_netlist(netlist, netlist_prep)

    prims = detect_prims(netlist)
    print("PRIMS (%d): %s" % (len(prims), ", ".join(prims)), flush=True)
    missing = [p for p in prims if prim_source(p) is None]
    if missing:
        sys.exit("NO UNISIM MODEL for: %s" % ", ".join(missing))

    srcs = [netlist_prep]
    for p in prims:
        srcs.append(prim_source(p))
    srcs += [
        os.path.join(HERE, "tb_gl_board_top.v"),
        os.path.join(HERE, "tb_gl_board.v"),
        os.path.join(HERE, "glbl_sim.v"),
    ]

    vvp = os.path.join(workdir, "gl_tb.vvp")
    cmd = [IVL, "-g2012", "-s", "tb_gl_board_top", "-o", vvp] + srcs
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=900,
                       cwd=PROJ)
    dt = time.time() - t0
    print("iverilog rc=%d  %.0fs" % (r.returncode, dt), flush=True)
    for l in (r.stderr or "").strip().splitlines()[:25]:
        print("   E: " + l[:170], flush=True)
    for l in (r.stdout or "").strip().splitlines()[:8]:
        print("   O: " + l[:170], flush=True)
    if r.returncode != 0 or not os.path.exists(vvp):
        print("COMPILE FAILED", flush=True)
        return None
    print("compiled ->", vvp, flush=True)
    return vvp


def run_sim(vvp, workdir):
    vcd = os.path.join(workdir, "gl_board.vcd")
    if os.path.exists(vcd):
        os.remove(vcd)
    cmd = [VVP, vvp]
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=3600,
                       cwd=workdir)
    dt = time.time() - t0
    print("vvp rc=%d  %.0fs" % (r.returncode, dt), flush=True)
    for l in (r.stdout or "").splitlines():
        if l.strip():
            print("   " + l.strip()[:170], flush=True)
    if not os.path.exists(vcd):
        print("FATAL: no VCD produced", flush=True)
        return None
    print("VCD %s  %.1f MB" % (vcd, os.path.getsize(vcd) / 1e6), flush=True)
    return vcd


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--work", default=None, help="C:/tmp/glpwr_<ts> dir")
    ap.add_argument("--no-run", action="store_true")
    a = ap.parse_args()

    workdir = a.work
    if not workdir:
        workdir = sorted([d for d in __import__("glob").glob("C:/tmp/glpwr_*")
                          if os.path.exists(os.path.join(d, "gl_synth_netlist.v"))])[-1]
    netlist = os.path.join(workdir, "gl_synth_netlist.v")
    if not os.path.exists(netlist):
        sys.exit("netlist not found: " + netlist)
    print("workdir:", workdir, flush=True)

    vvp = compile_sim(netlist, workdir)
    if vvp is None:
        sys.exit(1)
    if a.no_run:
        return 0
    vcd = run_sim(vvp, workdir)
    if vcd is None:
        sys.exit(1)
    return 0


if __name__ == "__main__":
    sys.exit(main())
