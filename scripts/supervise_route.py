#!/usr/bin/env python3
"""Supervisor: launch a route-only retry (Quick by default) from the placed
checkpoint, monitor it, and write a definitive STATUS file.

This survives as a detached process and logs to Temp so the WorkBuddy agent
can monitor progress across turns.  It refuses to start if any OTHER vivado
is already running (external uov/tvla sweep) so we only route in a clean
window.

Usage:
    python scripts/supervise_route.py <dcp> <tag> [directive] [timeout] [attempts]
"""
import os, sys, time, subprocess, io, datetime

PROJECT = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
RESULTS = os.path.join(PROJECT, "results")
ROUTE   = os.path.join(PROJECT, "scripts", "route_from_dcp.py")  # default runner
PY      = r"C:\Users\Yi\.workbuddy\binaries\python\versions\3.13.12\python.exe"


def log(fh, msg):
    line = "[%s] %s" % (datetime.datetime.now().strftime("%H:%M:%S"), msg)
    fh.write(line + "\n")
    fh.flush()
    try:
        print(line, flush=True)
    except Exception:
        pass


def vivado_pids():
    """Return set of vivado.exe PIDs currently running."""
    try:
        out = subprocess.run(
            ["powershell", "-NoProfile", "-Command",
             "Get-CimInstance Win32_Process -Filter \"name='vivado.exe'\" | "
             "Select-Object -ExpandProperty ProcessId"],
            capture_output=True, text=True, timeout=60).stdout
    except Exception:
        return set()
    pids = set()
    for line in out.splitlines():
        line = line.strip()
        if line.isdigit():
            pids.add(int(line))
    return pids


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    dcp = sys.argv[1]
    tag = sys.argv[2]
    directive = sys.argv[3] if len(sys.argv) > 3 else "Quick"
    timeout = int(sys.argv[4]) if len(sys.argv) > 4 else 7200
    attempts = int(sys.argv[5]) if len(sys.argv) > 5 else 1
    runner = sys.argv[6] if len(sys.argv) > 6 else ROUTE
    if not os.path.isabs(runner):
        runner = os.path.join(PROJECT, "scripts", runner)

    status = os.path.join(RESULTS, "impl_board_top_%s_STATUS.txt" % tag)
    logf = os.path.join(os.environ.get("TEMP", r"C:\Users\Yi\AppData\Local\Temp"),
                        "supervise_%s.log" % tag)

    fh = io.open(logf, "a", encoding="utf-8")
    log(fh, "supervise %s start %s dcp=%s directive=%s timeout=%s attempts=%s runner=%s"
        % (tag, datetime.datetime.now().isoformat(), dcp, directive, timeout, attempts,
           os.path.basename(runner)))

    if not os.path.exists(dcp):
        log(fh, "ERROR: checkpoint not found: %s" % dcp)
        _write_status(status, "ERROR", "checkpoint missing", [], "")
        fh.close()
        return 1

    # Clean-window gate: refuse if another vivado is already up.
    others = vivado_pids()
    if others:
        log(fh, "WARN: %d foreign vivado PID(s) running %s -- waiting for clean window"
            % (len(others), sorted(others)))
        t0 = time.time()
        while others and time.time() - t0 < 3600:
            time.sleep(30)
            others = vivado_pids()
        if others:
            log(fh, "ABORT: window never cleared (%s still running)" % sorted(others))
            _write_status(status, "ABORTED", "foreign vivado %s" % sorted(others), [], "")
            fh.close()
            return 1
        log(fh, "window cleared after %.0fs" % (time.time() - t0))

    marks_seen = set()
    for attempt in range(1, attempts + 1):
        log(fh, "==== attempt %d @ %s ====" % (attempt, time.strftime("%Y%m%d_%H%M%S")))
        cmd = [PY, runner, dcp, tag, directive, str(timeout)]
        try:
            proc = subprocess.Popen(cmd, cwd=PROJECT,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    text=True, encoding="utf-8", errors="replace",
                                    creationflags=getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0))
        except Exception as e:
            log(fh, "FATAL: cannot spawn route_from_dcp: %r" % e)
            _write_status(status, "ERROR", "spawn fail", [], "")
            fh.close()
            return 1
        log(fh, "  child pid=%d" % proc.pid)

        t0 = time.time()
        last_marks = ""
        rc = None
        while True:
            if proc.poll() is not None:
                rc = proc.poll()
                break
            time.sleep(2)
            # progress heartbeat
            el = int(time.time() - t0)
            if el % 30 == 0:
                cur_marks = _read_marks(tag)
                if cur_marks != last_marks:
                    log(fh, "  [%5ds] marks=%s" % (el, cur_marks))
                    last_marks = cur_marks

        log(fh, "  child exited rc=%s elapsed=%.0fs" % (rc, time.time() - t0))
        cur_marks = _read_marks(tag)
        log(fh, "  final marks=%s" % cur_marks)

        # Decide success: route_done + post_timing marks and a report on disk.
        rpt = os.path.join(RESULTS, "impl_board_top_%s_post_route_timing.rpt" % tag)
        if "40_route_done" in cur_marks and os.path.exists(rpt):
            log(fh, "SUCCESS: route completed, post-route report present")
            _write_status(status, "DONE", "route+timing complete", sorted(cur_marks),
                          _tail_status(Results_dir_report(tag)))
            fh.close()
            return 0

        log(fh, "attempt %d -> DEAD (marks=%s), retrying" % (attempt, cur_marks))
        # brief cooldown so a repeated external taskkill burst passes
        time.sleep(10)

    _write_status(status, "DEAD", "all attempts exhausted", sorted(_read_marks(tag)), "")
    log(fh, "all attempts exhausted")
    fh.close()
    return 1


def _read_marks(tag):
    import glob
    marks = set()
    # Search both route-* (route_from_dcp) and physopt-* (route_physopt) tmp dirs.
    for pat in (r"C:\tmp_impl_board_route-%s_*" % tag.replace("_", "-"),
                r"C:\tmp_impl_board_physopt-%s_*" % tag.replace("_", "-")):
        for d in glob.glob(pat):
            mk = os.path.join(d, "mark")
            if os.path.isdir(mk):
                for f in os.listdir(mk):
                    if f.endswith(".txt"):
                        marks.add(f[:-4])
    return marks


def Results_dir_report(tag):
    rpt = os.path.join(RESULTS, "impl_board_top_%s_post_route_timing.rpt" % tag)
    if os.path.exists(rpt):
        try:
            txt = open(rpt, encoding="utf-8", errors="replace").read()
            i = txt.find("Setup")
            return txt[max(0, i - 200): i + 400]
        except Exception:
            return ""
    return ""


def _tail_status(extra):
    return extra


def _write_status(path, state, detail, marks, tail):
    try:
        with io.open(path, "w", encoding="utf-8") as f:
            f.write("%s supervisor\n" % os.path.basename(path))
            f.write("state: %s\n" % state)
            f.write("time : %s\n" % datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
            f.write("marks: %s\n" % (marks or []))
            f.write("detail: %s\n" % detail)
            if tail:
                f.write("post-route timing snippet:\n%s\n" % tail)
    except Exception as e:
        print("status write failed:", e)


if __name__ == "__main__":
    sys.exit(main())
