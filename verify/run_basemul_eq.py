import subprocess, tempfile, os, shutil, sys

IV = r'C:\iverilog\bin\iverilog.exe'
VVP = r'C:\iverilog\bin\vvp.exe'
base = r'c:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype'
src = [os.path.join(base, 'rtl', 'core', 'kyber_poly.v'),
       os.path.join(base, 'verify', 'kyber_basemul_pipe.v'),
       os.path.join(base, 'verify', 'tb_basemul_eq.v')]
tmp = tempfile.mkdtemp(prefix='bmeq_')
vvp = os.path.join(tmp, 'eq.vvp')
log = os.path.join(tmp, 'run.log')

def logln(s):
    print(s, flush=True)
    with open(log, 'a', encoding='utf-8') as f:
        f.write(s + '\n')

logln('compile...')
p = subprocess.run([IV, '-g2012', '-o', vvp] + src, capture_output=True)
logln('compile rc=%d' % p.returncode)
if p.stdout:
    logln(p.stdout.decode('utf-8', 'replace'))
if p.stderr:
    logln('[compile stderr] ' + p.stderr.decode('utf-8', 'replace'))
if p.returncode == 0:
    logln('run vvp...')
    with open(log, 'a', encoding='utf-8') as f:
        r = subprocess.run([VVP, vvp], capture_output=True, cwd=tmp, timeout=120)
    logln(r.stdout.decode('utf-8', 'replace'))
    if r.stderr:
        logln('[run stderr] ' + r.stderr.decode('utf-8', 'replace'))
    logln('vvp rc=%d' % r.returncode)
shutil.rmtree(tmp, ignore_errors=True)
