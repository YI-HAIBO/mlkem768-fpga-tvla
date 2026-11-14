import os, sys, traceback
BASE = r'C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype'
sys.path.insert(0, os.path.join(BASE, 'scripts', 'glpwr'))
try:
    import run_gl_sim as R
    net = r'C:/tmp/glpwr_1794115624/gl_synth_netlist.v'
    prims = R.detect_prims(net)
    print('DETECTED %d PRIMS:' % len(prims))
    for p in prims:
        src = R.prim_source(p)
        ok = 'OK' if src else 'MISSING'
        print('  %-12s %s  %s' % (p, ok, src if src else ''))
    missing = [p for p in prims if R.prim_source(p) is None]
    print('MISSING MODELS:', missing if missing else 'NONE')
except Exception:
    traceback.print_exc()
