"""Dump utilisation figures from Vivado util.rpt files (baseline comparison).

Usage: python scripts/dump_util.py [glob1 glob2 ...]
       defaults to the KEM kyber_ntt pipe* reports.
"""
import io, os, re, sys, glob

D = r'C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype'
R = os.path.join(D, 'results')


def cells(txt):
    """Parse every row of every Vivado util table -> (label, used, avail, pct)."""
    out = []
    for ln in txt.splitlines():
        s = ln.strip()
        if not (s.startswith('|') and s.endswith('|')):
            continue
        parts = [p.strip() for p in s.strip('|').split('|')]
        if len(parts) < 5:
            continue
        label, used = parts[0], parts[1]
        # Vivado tables: Used | Fixed | Prohibited | Available | Util%
        avail, pct = parts[4], parts[5]
        if not (used.isdigit() and avail.isdigit()):
            continue
        pct = pct.replace('%', '').strip()
        out.append((label, int(used), int(avail), pct))
    return out


def design(txt):
    m = re.search(r'\|\s*Design\s*:\s*(\S+)', txt)
    m2 = re.search(r'\|\s*Device\s*:\s*(\S+)', txt)
    m3 = re.search(r'\|\s*Date\s*:\s*(.+?)\s*\|', txt)
    return (m.group(1) if m else '?', m2.group(1) if m2 else '?',
            m3.group(1) if m3 else '?')


def main():
    pats = sys.argv[1:] or ['synth_one_kyber_ntt_%s_util.rpt' % t
                            for t in ('base', 'pipe1', 'pipe3', 'pipeline',
                                      'pipe5', 'pipe6', 'pipe7')]
    files = []
    for p in pats:
        g = glob.glob(os.path.join(R, p))
        files.extend(sorted(g))
    if not files:
        print('no reports matched')
        return 1

    for p in files:
        t = io.open(p, encoding='utf-8', errors='replace').read()
        name, dev, date = design(t)
        print('=== %s   (design=%s, device=%s)' % (os.path.basename(p), name, dev))
        print('    date: %s' % date)
        for lab, used, avail, pct in cells(t):
            if used > 0:
                print('    %-26s %8d / %8d  %6s %%' % (lab, used, avail, pct))
        print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
