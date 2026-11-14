"""Parse Vivado report_timing_summary output: list the N worst setup paths."""
import io, re, sys

def parse(path, maxn=10):
    t = io.open(path, encoding='utf-8', errors='replace').read()
    out = []
    parts = t.split('Slack (VIOLATED)')
    for k, s in enumerate(parts[1:], 1):
        if k > maxn:
            break
        d = {}
        m = re.search(r'Source:\s+(\S+)', s[:1500])
        d['src'] = m.group(1) if m else '?'
        m = re.search(r'Destination:\s+(\S+)', s[:1500])
        d['dst'] = m.group(1) if m else '?'
        m = re.search(r'Logic Levels:\s*(\d+)\s+\(([^)]+)\)', s[:1500])
        d['lvls'] = m.group(0).replace('\n', ' ') if m else '?'
        m = re.search(r'Slack \(VIOLATED\)\s*:\s*(-?[\d.]+)ns', s[:200])
        d['slack'] = m.group(1) if m else '?'
        m = re.search(r'Data Path Delay:\s*([\d.]+)ns\s*\(logic\s*([\d.]+)ns.*route\s*([\d.]+)ns', s[:1200])
        if m:
            d['dpd'] = m.group(1)
            d['logic'] = m.group(2)
            d['route'] = m.group(3)
        out.append(d)
    m = re.search(r'WNS\(ns\)\s+TNS\(ns\)[^\n]*\n\s*(-?[\d.]+)\s+(-?[\d.]+)\s+(\d+)', t)
    summary = {'wns': m.group(1), 'tns': m.group(2), 'nfail': m.group(3)} if m else {}
    return summary, out

if __name__ == '__main__':
    summary, paths = parse(sys.argv[1])
    print('summary:', summary)
    for p in paths:
        print(p)
