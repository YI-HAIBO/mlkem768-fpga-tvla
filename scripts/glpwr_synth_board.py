#!/usr/bin/env python3
"""Gate-level power prep: synthesize board_top to a DCP + funcsim netlist.

§8.5 gate-level SAIF flow, step 1.  Mirrors the ML-DSA gl_synth.tcl recipe:
  read_verilog -> synth_design -flatten_hierarchy none (keeps hierarchy so
  SAIF instance paths survive) -> write_checkpoint -> write_verilog -mode
  funcsim (UNISIM primitives, no timing).  The DCP and the netlist come from
  the SAME synthesis, so read_saif annotation reaches ~99% (Medium).

Host workarounds (inherited from impl_board_top.py):
  * synth.enableParallelHelperSpawn none   (orphan-helper IPC corruption)
  * synth.elaboration.useElabCache false   (synth-finish hang)

Usage:
    python scripts/glpwr_synth_board.py
Emits into a fresh ASCII dir  C:/tmp/glpwr_<ts>/  and prints its path.
"""
import os, sys, io, time, shutil, subprocess, re

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
CORE = os.path.join(ROOT, "rtl", "core")
REAL = os.path.join(ROOT, "rtl", "real")
RTL  = os.path.join(ROOT, "rtl")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART   = "xc7a100tcsg324-1"
TOP    = "ipx_aoi_sec_board_top"
CORE_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v",
              "kyber_sampler.v", "shake.v", "keccak_perm.v"]
# Path A: on-chip Welch t-test engine now part of the gate-level netlist.
REAL_FILES = ["tvla_online.v"]

WORK = "C:/tmp/glpwr_" + str(int(time.time()))


def build_tcl():
    lines = []
    lines.append('catch {set_param synth.enableParallelHelperSpawn none}')
    lines.append('catch {set_param synth.elaboration.useElabCache false}')
    lines.append('set OUT "' + WORK + '"')
    lines.append('puts "=== gl_synth board_top (%s) ==="' % TOP)
    lines.append('puts "Time: [clock format [clock seconds]]"')
    lines.append('read_verilog [list \\')
    for f in CORE_FILES + REAL_FILES:
        lines.append('    "' + WORK.replace("/", "/") + '/core/' + f + '" \\')
    lines.append('    "' + WORK + '/rtl/' + TOP + '.v"]')
    lines.append('synth_design -top %s -part %s -flatten_hierarchy none'
                 % (TOP, PART))
    lines.append('write_checkpoint -force $OUT/gl_synth.dcp')
    lines.append('report_utilization -file $OUT/gl_synth_util.rpt')
    lines.append('write_verilog -mode funcsim -force $OUT/gl_synth_netlist.v')
    lines.append('puts "GL_SYNTH_OK"')
    lines.append('exit')
    return '\n'.join(lines)


def main():
    os.makedirs(WORK + "/core", exist_ok=True)
    os.makedirs(WORK + "/rtl", exist_ok=True)
    print("WORK:", WORK, flush=True)
    for f in CORE_FILES:
        shutil.copy2(os.path.join(CORE, f), os.path.join(WORK, "core", f))
    for f in REAL_FILES:
        shutil.copy2(os.path.join(REAL, f), os.path.join(WORK, "core", f))
    shutil.copy2(os.path.join(RTL, TOP + ".v"), os.path.join(WORK, "rtl", TOP + ".v"))
    print("copied %d core + board_top" % len(CORE_FILES), flush=True)

    # Optional CLK_DIV override (env var): rewrite the parameter in the COPY
    # in the tmp dir (source RTL untouched).  BOARD_CLK_DIV=1 puts the whole
    # KEM datapath on clk (100 MHz, matches the timing-closure config and the
    # RTL POST TB), so the gate-level POST completes in 352,627 cycles instead
    # of ~8x that at the default CLK_DIV=8 (12.5 MHz, infeasible for gate sim).
    clk_div = os.environ.get("BOARD_CLK_DIV")
    if clk_div:
        topv = os.path.join(WORK, "rtl", TOP + ".v")
        s = open(topv, encoding="utf-8").read()
        s, n = re.subn(r"(parameter\s+integer\s+CLK_DIV\s*=\s*)(\d+)",
                       r"\g<1>" + clk_div, s, count=1)
        if n != 1:
            raise RuntimeError("CLK_DIV param rewrite matched %d times (want 1)"
                               % n)
        open(topv, "w", encoding="utf-8").write(s)
        print("  BOARD_CLK_DIV=%s -> rewrote CLK_DIV in %s"
              % (clk_div, topv), flush=True)

    tcl = os.path.join(WORK, "gl_synth.tcl")
    with io.open(tcl, "w", encoding="utf-8") as fh:
        fh.write(build_tcl())
    print("wrote", tcl, flush=True)

    log = os.path.join(WORK, "gl_synth.log")
    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", log,
           "-source", tcl]
    print("CMD:", " ".join(cmd), flush=True)
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=3600,
                       cwd=WORK, errors="replace")
    dt = time.time() - t0
    print("vivado rc=%s  %.0f s" % (r.returncode, dt), flush=True)
    out = (r.stdout or "") + "\n---STDERR---\n" + (r.stderr or "")
    with open(os.path.join(WORK, "gl_synth_console.log"), "w",
              encoding="utf-8") as fh:
        fh.write(out)
    for line in out.splitlines():
        if any(k in line for k in ("GL_SYNTH_OK", "ERROR", "Synthesis finished",
                                   "error", "WNS", "Utilization")):
            print("  | " + line[:160], flush=True)

    dcp = os.path.join(WORK, "gl_synth.dcp")
    net = os.path.join(WORK, "gl_synth_netlist.v")
    print("DCP:", os.path.exists(dcp),
          os.path.getsize(dcp) if os.path.exists(dcp) else "-", flush=True)
    print("NET:", os.path.exists(net),
          os.path.getsize(net) if os.path.exists(net) else "-", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
