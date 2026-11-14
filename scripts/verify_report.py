# -*- coding: utf-8 -*-
"""Check that every file reference in the report's tables resolves on disk."""
import io, os, re, sys

ROOT = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
REP  = os.path.join(ROOT, "results", "kem_synth_final_report.md")

s = io.open(REP, encoding="utf-8").read()
BACKTICK = chr(96)

# collect every `path` token that appears inside a markdown table cell
refs = re.findall(r"\|\s*" + BACKTICK + r"([^" + BACKTICK + r"]+)" + BACKTICK + r"\s*\|", s)

print("report : %s" % REP)
print("bytes  : %d   lines: %d" % (len(s), len(s.splitlines())))
print("refs   : %d" % len(refs))
print()

expanded = []
for r in refs:
    if "{" in r:
        pre, rest = r.split("{", 1)
        names, suf = rest.split("}", 1)
        expanded += [pre + n + suf for n in names.split(",")]
    else:
        expanded.append(r)

# Only table cells that look like a path are file references.  The report's
# sub-module tables put bare module names in backticks (kyber_ntt, shake, ...),
# and the Problem A table backticks a warning message.  Those are not paths.
PATH_HINT = re.compile(r"[\\/]", re.M)


def looks_like_path(r):
    if PATH_HINT.search(r):
        return True
    # brace-expansion shorthand like synth_sub_{a,b,c}_util.rpt has no slash
    if "{" in r and re.search(r"\.\w{2,}$", r):
        return True
    # basename + known artifact extension
    return bool(re.search(r"\.(rpt|log|txt|md|v|vvp|xdc|py|tcl|hex|json)$", r))


nonpaths = []
paths = []
for r in expanded:
    (paths if looks_like_path(r) else nonpaths).append(r)

print("non-path backticked cells (module names, warning text): %d"
      % len(nonpaths))
print("  " + ", ".join(sorted(set(nonpaths))[:12]))
print()


def resolve(p):
    for base in ("results", "scripts", "."):
        q = os.path.join(ROOT, base, p)
        if os.path.exists(q):
            return os.path.join(base, p)
    return None


missing = []
for r in paths:
    if not resolve(r):
        missing.append(r)
        print("  MISS  %s" % r)

print()
print("file refs  : %d   resolved: %d   missing: %d"
      % (len(paths), len(paths) - len(missing), len(missing)))
print()

print("--- section headers ---")
for m in re.finditer(r"^#{1,3} .*", s, re.M):
    print("  L%-4d %s" % (s[:m.start()].count("\n") + 1, m.group(0)[:84]))

print()
print("-> %s" % ("ALL FILE REFERENCES RESOLVE" if not missing else "SEE MISS LINES ABOVE"))
sys.exit(1 if missing else 0)
