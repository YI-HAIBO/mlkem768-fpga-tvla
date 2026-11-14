import subprocess, tempfile, os, shutil, sys, time

IV = r'C:\iverilog\bin\iverilog.exe'
VVP = r'C:\iverilog\bin\vvp.exe'
base = r'c:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype'
tb = sys.argv[1] if len(sys.argv) > 1 else 'tb_pipe_min.v'
src = [os.path.join(base, 'rtl', 'core', 'kyber_poly.v'),
       os.path.join(base, 'verify', 'kyber_basemul_pipe.v'),
       os.path.join(base, 'verify', tb)]
tmp = tempfile.mkdtemp(prefix='min_')
vvp = os.path.join(tmp, 'm.vvp')
logf = os.path.join(tmp, 'sim.log')

def logln(s):
    print(s, flush=True)

logln('compile %s ...' % tb)
p = subprocess.run([IV, '-g2012', '-o', vvp] + src, capture_output=True)
logln('compile rc=%d' % p.returncode)
if p.stdout: logln(p.stdout.decode('utf-8', 'replace'))
if p.stderr: logln('[ce] ' + p.stderr.decode('utf-8', 'replace'))
if p.returncode == 0:
    logln('run vvp (timeout 15s, stream to log)...')
    t0 = time.time()
    with open(logf, 'wb') as f:
        try:
            r = subprocess.run([VVP, vvp], stdout=f, stderr=f, cwd=tmp, timeout=15)
            logln('vvp rc=%d in %.1fs' % (r.returncode, time.time() - t0))
        except subprocess.TimeoutExpired:
            logln('VVP TIMEOUT after %.1fs -> HANG' % (time.time() - t0))
    # dump partial log
    if os.path.exists(logf):
        logln('--- sim.log (%d bytes) ---' % os.path.getsize(logf))
        logln(open(logf, 'rb').read().decode('utf-8', 'replace'))
shutil.rmtree(tmp, ignore_errors=True)
