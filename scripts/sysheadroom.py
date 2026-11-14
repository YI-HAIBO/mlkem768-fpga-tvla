"""Show system memory / disk headroom (Windows, no third-party deps).

Usage: python scripts/sysheadroom.py
"""
import ctypes
import ctypes.wintypes as wt
import os

k32 = ctypes.windll.kernel32
ULONG = ctypes.c_ulong
ULONGLONG = ctypes.c_ulonglong


class MEMORYSTATUSEX(ctypes.Structure):
    _fields_ = [
        ("Length", ULONG),
        ("MemoryLoad", ULONG),
        ("TotalPhys", ULONGLONG),
        ("AvailPhys", ULONGLONG),
        ("TotalPageFile", ULONGLONG),
        ("AvailPageFile", ULONGLONG),
        ("TotalVirtual", ULONGLONG),
        ("AvailVirtual", ULONGLONG),
        ("AvailExtendedVirtual", ULONGLONG),
    ]


def mem():
    m = MEMORYSTATUSEX()
    m.Length = ctypes.sizeof(m)
    ok = k32.GlobalMemoryStatusEx(ctypes.byref(m))
    if not ok:
        print("GlobalMemoryStatusEx FAILED")
        return
    GB = 2.0 ** 30
    print("Memory load        : %5.1f %%" % m.MemoryLoad)
    print("Total physical     : %6.2f GB" % (m.TotalPhys / GB))
    print("Available physical : %6.2f GB" % (m.AvailPhys / GB))
    print("Total pagefile     : %6.2f GB" % (m.TotalPageFile / GB))
    print("Available pagefile : %6.2f GB" % (m.AvailPageFile / GB))


def disks():
    """GetDiskFreeSpaceExW -- os.statvfs is Posix-only."""
    print()
    print("Drive            Total      Free     Free%")
    for drv in ("C:", "D:"):
        tot, fre, _avail = ULONGLONG(), ULONGLONG(), ULONGLONG()
        ok = k32.GetDiskFreeSpaceExW(drv + "\\",
                                     ctypes.byref(tot), ctypes.byref(fre),
                                     ctypes.byref(_avail))
        if not ok:
            print("%-16s GetDiskFreeSpaceExW FAILED (rc=%d)"
                  % (drv + "/", ctypes.get_last_error()))
            continue
        t = tot.value / 2.0 ** 30
        f = fre.value / 2.0 ** 30
        print("%-16s %6.1f GB %7.1f GB %6.1f %%" % (drv + "/", t, f, 100 * f / t))


def vivado_procs():
    print()
    import subprocess
    r = subprocess.run(["tasklist"], capture_output=True, text=True, errors="replace")
    rows = [l for l in r.stdout.replace("\r", "").splitlines()
            if "ivado" in l.lower()]
    print("vivado.exe processes: %d" % len(rows))
    for l in rows:
        print("   ", l)


if __name__ == "__main__":
    mem()
    disks()
    vivado_procs()
