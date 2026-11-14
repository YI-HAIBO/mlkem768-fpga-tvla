"""Print the summary block(s) of a Vivado timing_summary report.

Usage: python scripts/peek_timing.py results/xxx_timing.rpt [more.rpt ...]
"""
import io, os, re, sys

D = r'C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype'
R = os.path.join(D, 'results')

KEY = re.compile(r'(WNS|WHS|TNS|Fmax|All Slacks Met|Clock\s*:|Period|Frequency|Slack\s*\(|Total Violation)')


def peek(path):
    p = path if os.path.isabs(path) or os.path.sep in path else os.path.join(R, path)
    if not os.path.exists(p):
        print('MISSING: %s' % p)
        return
    txt = io.open(p, encoding='utf-8', errors='replace').read()
    lines = txt.splitlines()
    print('=== %s  (%d lines)' % (os.path.basename(p), len(lines)))
    # Design info block
    for ln in lines[:60]:
        s = ln.strip()
        if s.startswith('|') and any(k in s for k in ('Design', 'Device', 'Date', 'Version')):
            print('   ', s)
    # Summary lines
    seen = set()
    for i, ln in enumerate(lines):
        s = ln.rstrip()
        if not KEY.search(s):
            continue
        if 'Path Group' in s:
            continue
        key = s.strip()
        if key in seen:
            continue
        seen.add(key)
        print('   ', key)
    print()


def main():
    args = sys.argv[1:] or ['synth_one_kyber_ntt_pipe7_timing.rpt']
    for a in args:
        peek(a)


if __name__ == '__main__':
    main()
