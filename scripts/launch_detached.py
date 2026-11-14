#!/usr/bin/env python3
"""Launch supervise_route.py as a DETACHED process so it survives the WorkBuddy
session ending (the known 'background Vivado dies at session end' limitation).

Windows: CREATE_NEW_PROCESS_GROUP | DETACHED_PROCESS | CREATE_BREAKAWAY_FROM_JOB.
If breakaway is denied by the job, we fall back to a schtasks one-shot task.

Usage:
    python scripts/launch_detached.py <dcp> <tag> [directive] [timeout] [attempts]
"""
import os, sys, subprocess, time, io, datetime

PROJECT = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
PY      = r"C:\Users\Yi\.workbuddy\binaries\python\versions\3.13.12\python.exe"
SUP     = os.path.join(PROJECT, "scripts", "supervise_route.py")

LOG = os.path.join(os.environ.get("TEMP", r"C:\Users\Yi\AppData\Local\Temp"),
                   "launch_detached.log")


def log(msg):
    with io.open(LOG, "a", encoding="utf-8") as f:
        f.write("[%s] %s\n" % (datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), msg))
    try:
        print(msg, flush=True)
    except Exception:
        pass


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    dcp = sys.argv[1]
    tag = sys.argv[2]
    directive = sys.argv[3] if len(sys.argv) > 3 else "default"
    timeout = sys.argv[4] if len(sys.argv) > 4 else "21600"
    attempts = sys.argv[5] if len(sys.argv) > 5 else "1"

    cmd = [PY, SUP, dcp, tag, directive, timeout, attempts]

    # 1) Try detached spawn with breakaway.
    flags = 0
    for f in ("CREATE_NEW_PROCESS_GROUP", "DETACHED_PROCESS", "CREATE_BREAKAWAY_FROM_JOB"):
        flags |= getattr(subprocess, f, 0)
    log("attempt detached spawn: %s" % " ".join(cmd))
    try:
        p = subprocess.Popen(cmd, cwd=PROJECT, close_fds=True, creationflags=flags,
                             stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL)
        log("detached spawn OK pid=%d" % p.pid)
        # wait 20s to confirm it did not die instantly
        time.sleep(20)
        if p.poll() is None:
            log("survived 20s -> running detached, pid=%d" % p.pid)
            return 0
        log("died within 20s rc=%s -> falling back to schtasks" % p.poll())
    except Exception as e:
        log("detached spawn failed: %r -> falling back to schtasks" % e)

    # 2) Fallback: schtasks one-shot, run now.
    taskname = "WB_Route_%s" % tag
    tr = '"%s" "%s" "%s" "%s" "%s" "%s" "%s"' % (PY, SUP, dcp, tag, directive, timeout, attempts)
    log("schtasks fallback: %s" % taskname)
    r = subprocess.run(["schtasks", "/create", "/tn", taskname,
                        "/tr", tr, "/sc", "once", "/st", "23:59", "/f"],
                       capture_output=True, text=True)
    log("schtasks create rc=%s out=%s err=%s" % (r.returncode, r.stdout.strip(), r.stderr.strip()))
    r = subprocess.run(["schtasks", "/run", "/tn", taskname], capture_output=True, text=True)
    log("schtasks run rc=%s out=%s err=%s" % (r.returncode, r.stdout.strip(), r.stderr.strip()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
