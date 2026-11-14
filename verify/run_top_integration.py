"""Task 75 integration regression: compile the full top-level RTL
(ipx_aoi_sec_fpga_top, which instantiates dilithium_ntt as u_ntt) with the
fixed zeta table and run both smoke testbenches.

Checks:
  1. tb_ipx_aoi_sec_fpga_top.v elaborates and runs to $finish (u_ntt included).
  2. tb_system_integration.v (dilithium_core + hybrid_signature_fsm +
     optical_puf_controller) still elaborates and runs.

Run from the project root or from verify/:
    python verify/run_top_integration.py
"""
import os, subprocess, tempfile, shutil, glob

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
RTL_ALL = glob.glob(os.path.join(ROOT, 'rtl', '**', '*.v'), recursive=True)
RTL_ALL = [f for f in RTL_ALL if not f.endswith('submodule_stubs.v')]
SIM_DIR = os.path.join(ROOT, 'sim')

iverilog = r'C:\iverilog\bin\iverilog.exe'
vvp = r'C:\iverilog\bin\vvp.exe'


def run_tb(tb_name, keep_log=None):
    tmp = tempfile.mkdtemp(prefix='top_int_')
    try:
        files = [os.path.join(SIM_DIR, tb_name)] + RTL_ALL
        # iverilog needs ASCII paths; copy everything into the temp dir
        local = []
        for f in files:
            dst = os.path.join(tmp, os.path.basename(f))
            shutil.copy2(f, dst)
            local.append(os.path.basename(f))
        vvp_out = os.path.join(tmp, 'sim.vvp')
        r = subprocess.run([iverilog, '-g2012', '-o', vvp_out] + local,
                           capture_output=True, text=True, cwd=tmp)
        if r.returncode != 0:
            print('[%s] COMPILE FAIL' % tb_name)
            print(r.stderr[:4000])
            return False
        try:
            r = subprocess.run([vvp, vvp_out], capture_output=True, text=True,
                               cwd=tmp, timeout=1800)
        except subprocess.TimeoutExpired:
            print('[%s] FAIL (vvp timeout: TB never reached $finish)' % tb_name)
            return False
        out = r.stdout + r.stderr
        if keep_log:
            with open(keep_log, 'w', encoding='utf-8') as fh:
                fh.write(out)
        ok = (r.returncode == 0 and
              'ERROR' not in out.upper().replace('ERRORS', '') and
              ('System Integration Test' in out or '$finish' in out or
               'All modules working together' in out))        # any iverilog runtime error message is fatal
        if 'ERROR:' in out or 'error:' in out:
            ok = False
        tag = 'PASS' if ok else 'FAIL'
        print('[%s] %s (rc=%d, %d bytes output)' % (tb_name, tag, r.returncode, len(out)))
        for line in out.split('\n'):
            s = line.strip()
            if s and any(k in s for k in ('Test', 'working together', 'ERROR',
                                          'WARNING', 'finish')):
                print('    ' + s[:160])
        return ok
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    import traceback
    LOG = os.path.join(HERE, '_int_run.log')
    log = open(LOG, 'w', encoding='utf-8')
    def say(msg):
        print(msg, flush=True)
        log.write(msg + '\n')
        log.flush()
    try:
        results = {}
        results['tb_ipx_aoi_sec_fpga_top.v'] = run_tb(
            'tb_ipx_aoi_sec_fpga_top.v',
            os.path.join(HERE, 'golden_top_integration_fpga.log'))
        results['tb_system_integration.v'] = run_tb(
            'tb_system_integration.v',
            os.path.join(HERE, 'golden_top_integration_sys.log'))
        say('==== SUMMARY ====')
        all_ok = True
        for k, v in results.items():
            say('  %s: %s' % (k, 'PASS' if v else 'FAIL'))
            all_ok = all_ok and v
        say('RESULT: %s' % ('INTEGRATION ALL PASS' if all_ok else 'INTEGRATION FAIL'))
    except Exception:
        traceback.print_exc(file=log)
        log.flush()
        say('RESULT: EXCEPTION')
    finally:
        log.close()
