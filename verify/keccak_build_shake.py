import subprocess, os, shutil, runpy
PY = "/c/Users/Yi/.workbuddy/binaries/python/versions/3.13.12/python.exe"
WS = "C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14"
PROTO = WS + "/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
BUILD = WS + "/simbuild"

# 1. regenerate golden in PROTO (in-process, os.chdir works for Chinese paths)
os.chdir(PROTO)
runpy.run_path("verify/gen_shake_golden.py", run_name="__main__")

# 2. set up ASCII build dir
if os.path.isdir(BUILD):
    shutil.rmtree(BUILD)
os.makedirs(BUILD + "/sim")
for f in ["rtl/core/keccak_perm.v", "rtl/core/shake.v", "sim/tb_shake.v"]:
    shutil.copy(os.path.join(PROTO, f), os.path.join(BUILD, os.path.basename(f)))
for f in os.listdir(os.path.join(PROTO, "sim")):
    if f.endswith(".hex"):
        shutil.copy(os.path.join(PROTO, "sim", f), os.path.join(BUILD, "sim", f))

# 3. compile from ASCII cwd
os.chdir(BUILD)
p = subprocess.run(["iverilog", "-g2012", "-o", "tb_shake.sim",
                    "keccak_perm.v", "shake.v", "tb_shake.v"],
                   capture_output=True, text=True)
print("== iverilog rc=%d" % p.returncode)
if p.stdout.strip(): print("STDOUT:", p.stdout.strip()[-1500:])
if p.stderr.strip(): print("STDERR:", p.stderr.strip()[-1500:])
if p.returncode != 0:
    raise SystemExit(1)

# 4. run
p = subprocess.run(["vvp", "tb_shake.sim"], capture_output=True, text=True)
print("== vvp rc=%d" % p.returncode)
print("STDOUT:")
print(p.stdout[-4000:])
if p.stderr.strip(): print("STDERR:", p.stderr.strip()[-800:])