#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""R1 driver: compile + run tb_r1_realstream with the PROBE_SEED probe.

Usage:
    python run_r1_seed.py [NLOG2] [tag]
NLOG2 : engine group size exponent (default 12 -> n=4096)
tag   : output log suffix (default str(NLOG2))
All outputs are written into SIM (absolute), independent of the caller's cwd.
"""
import os, subprocess, sys

SIM   = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype/sim"
IV    = r"C:/iverilog/bin/iverilog.exe"
VVP   = r"C:/iverilog/bin/vvp.exe"
CORE  = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype/rtl/core"
REAL  = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype/rtl/real"

NLOG2 = sys.argv[1] if len(sys.argv) > 1 else "12"
tag   = sys.argv[2] if len(sys.argv) > 2 else NLOG2
LOAD  = sys.argv[3] if len(sys.argv) > 3 else "0"   # LOAD_ONLY 0/1

os.chdir(SIM)
build_log = os.path.join(SIM, f"r1_seed_{tag}_build.log")
run_log   = os.path.join(SIM, f"r1_seed_{tag}_run.log")
vvp       = os.path.join(SIM, "tb_r1_seed.vvp")

# --- compile ---
cmd = [IV, "-g2012", "-s", "tb_r1_realstream",
       "-P", f"tb_r1_realstream.N_LOG2={NLOG2}",
       "-P", f"tb_r1_realstream.LOAD_ONLY={LOAD}",
       "-o", vvp, "tb_r1_realstream.v",
       os.path.join(CORE, "shake.v"), os.path.join(CORE, "keccak_perm.v"),
       os.path.join(CORE, "kyber_ntt.v"), os.path.join(CORE, "kyber_poly.v"),
       os.path.join(CORE, "kyber_sampler.v"), os.path.join(CORE, "kyber_kem.v"),
       os.path.join(REAL, "tvla_online.v")]
print("COMPILE:", " ".join(cmd), flush=True)
with open(build_log, "w") as f:
    r = subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT)
print("compile rc =", r.returncode, flush=True)
if r.returncode != 0:
    print(open(build_log, encoding="utf-8", errors="replace").read(), flush=True)
    sys.exit(1)

# --- run ---
print("RUN ...", flush=True)
with open(run_log, "w") as f:
    r = subprocess.run([VVP, vvp], stdout=f, stderr=subprocess.STDOUT)
print("run rc =", r.returncode, flush=True)
log = open(run_log, encoding="utf-8", errors="replace").read()
print(log, flush=True)
sys.exit(r.returncode)
