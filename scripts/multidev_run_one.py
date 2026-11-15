#!/usr/bin/env python3
# Run one Vivado synthesis for a device tag, with:
#  - fresh unique cwd (avoid stale .Xil / zombie)
#  - fast-fail: detect "Synthesis finished" (engine log, robust even when the
#    tcl interpreter hangs after synth_design returns) and if the process does
#    not exit within N sec after that, kill ONLY our own process tree.
#  - retry once with -directive RuntimeOptimized if the default run hangs.
#  - fallback: parse whatever the synth.log contains (cell usage table).
import subprocess, os, sys, time, re, json, shutil

VIV   = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
BASE  = r"C:\mdv_work"
TCL   = os.path.join(BASE, "multidev_synth.tcl")
TCL_RT= os.path.join(BASE, "multidev_synth_rt.tcl")

def kill_tree(pid):
    try:
        subprocess.run(["taskkill", "/F", "/T", "/PID", str(pid)],
                       capture_output=True, timeout=30)
    except Exception as e:
        print("kill err", e, flush=True)

def synth_done_in(log):
    """Return True once the synth engine has finished (its own log line),
    which appears even when the tcl interpreter hangs right after."""
    try:
        txt = open(log, encoding="utf-8", errors="replace").read()
    except Exception:
        return False
    return ("Synthesis finished with" in txt or
            "Synthesis Optimization Runtime" in txt)

def wait_run(log, part, proc, t_total=900, t_hang_after_synth=240):
    """Return (status, elapsed). status in {DONE,HANG,FAILED,TIMEOUT}.
    NOTE: tcl prints '=== DONE <PART> ===' (the part string), not the tag."""
    t0 = time.time()
    synth_at = None
    done_marker = "=== DONE %s ===" % part
    while time.time() - t0 < t_total:
        txt = ""
        try:
            txt = open(log, encoding="utf-8", errors="replace").read()
        except Exception:
            pass
        if done_marker in txt:
            return "DONE", time.time() - t0
        if synth_at is None and synth_done_in(log):
            synth_at = time.time()
        # hang detection: engine finished, no further progress, proc alive
        if synth_at is not None and (time.time() - synth_at) > t_hang_after_synth:
            if proc.poll() is None:
                return "HANG", time.time() - t0
        rc = proc.poll()
        if rc is not None:
            if done_marker in txt:
                return "DONE", time.time() - t0
            return "FAILED", time.time() - t0
        time.sleep(4)
    if proc.poll() is None:
        return "TIMEOUT", time.time() - t0
    return "FAILED", time.time() - t0

def run_once(tag, part, out, tcl, cwd):
    os.makedirs(cwd, exist_ok=True)
    log = os.path.join(cwd, "synth.log")
    cmd = '"%s" -mode batch -source "%s" -tclargs "%s" "%s" "%s"' % (VIV, tcl, tag, part, out)
    f = open(log, "w")
    proc = subprocess.Popen(cmd, shell=True, cwd=cwd, stdout=f, stderr=subprocess.STDOUT)
    status, elapsed = wait_run(log, part, proc)
    f.flush()
    if status in ("HANG", "TIMEOUT"):
        kill_tree(proc.pid)
        time.sleep(2)
    try:
        proc.wait(timeout=10)
    except Exception:
        pass
    f.close()
    return status, elapsed, log

def parse_util_from_log(log):
    """Parse Slice LUTs / Registers / DSP / Block RAM from synth.log cell usage."""
    out = {}
    try:
        txt = open(log, encoding="utf-8", errors="replace").read()
    except Exception:
        return out
    lines = txt.splitlines()
    for kw, key in [("Slice LUTs", "LUT"), ("Slice Registers", "FF"),
                    ("DSPs", "DSP"), ("Block RAM Tile", "BRAM")]:
        for l in lines:
            if kw in l and "|" in l and "Used" not in l:
                parts = [p.strip() for p in l.split("|")]
                nums = [p for p in parts if p and p.replace(",", "").isdigit()]
                if nums:
                    out[key] = int(nums[0].replace(",", ""))
                    break
    return out

def main(tag, part):
    out = os.path.join(BASE, "out_" + tag)
    stamp = str(int(time.time()))
    cwd = os.path.join(BASE, "run_" + tag + "_" + stamp)
    status, elapsed, log = run_once(tag, part, out, TCL, cwd)
    directive_note = ""
    if status in ("HANG", "TIMEOUT", "FAILED"):
        # retry once with RuntimeOptimized
        cwd2 = os.path.join(BASE, "run_" + tag + "_rt_" + stamp)
        print("[%s] %s after %.0fs; retrying with RuntimeOptimized" % (tag, status, elapsed), flush=True)
        status2, elapsed2, log2 = run_once(tag, part, out, TCL_RT, cwd2)
        directive_note = " (RuntimeOptimized retry)"
        if status2 in ("DONE",) or status2 == "DONE":
            status, elapsed, log = status2, elapsed2, log2
        else:
            status = status + "->" + status2
            elapsed = elapsed + elapsed2
            log = log2
    res = {"tag": tag, "part": part, "status": status, "elapsed": round(elapsed, 1),
           "directive": directive_note}
    for fn in ["util.rpt", "timing.rpt", "synth.dcp"]:
        p = os.path.join(out, fn)
        res[fn] = os.path.exists(p) and os.path.getsize(p) or 0
    u = parse_util_from_log(log)
    if u:
        res["util_from_log"] = u
    print(json.dumps(res, ensure_ascii=False), flush=True)
    return res

if __name__ == "__main__":
    tag, part = sys.argv[1], sys.argv[2]
    main(tag, part)
