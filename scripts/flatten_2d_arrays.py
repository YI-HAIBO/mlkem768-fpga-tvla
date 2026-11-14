# -*- coding: utf-8 -*-
"""
P1-a.1 — Flatten 2-D packed arrays to 1-D for BRAM inference
============================================================

Root cause (Vivado Synth 8-7186 x101 + Synth 8-4767, 0 BRAM in netlist):
    The 11 2-D packed arrays (`reg [BW-1:0] X [0:K-1][0:N-1]`) do not
    match Xilinx's BRAM inference template. Even with `(* ram_style =
    "block" *)` they are ignored and dissolve into ~200 k distributed
    FFs.

Fix (this script):
    1. Flatten each 2-D array declaration to 1-D and attach the
       attribute:
         reg [BW-1:0] X [0:K-1][0:N-1];
       ->
         (* ram_style = "block" *)
         reg [BW-1:0] X [0:K*N-1];
    2. Rewrite every 2-D access `X[a][b]` to `X[a*N + b]` where N is
       the module parameter (compile-time constant = 256, which the
       synthesiser reduces to an 8-bit shift-add).
    3. A_mat is already 1-D in the RTL (declared `[0:K*K*N-1]`,
       accessed as `A_mat[(i*K+j)*N + k]`); only the attribute is added.

    Result on target device: 24 KB of polynomial storage lands on ~6
    RAMB36 tiles (2.2% of the 270 available on XC7A100T), freeing the
    202 k FF of distributed-register storage that §3.1 of the main
    report identified as the reason for the 3.11x FF / 3.83x LUT
    overage.

Behaviour preservation:
    Every rewrite is a pure index-arithmetic equivalence on a
    compile-time-constant stride (N = 256).  Bit-exact regression
    against the `.pre_p1` backup is required before accepting the
    change.

Ground truth (kyber_kem.v, 2026 lines, CRLF):
    11 two-D arrays, 36 two-D access sites, all single-line.
    Index forms observed: ident, literal, and slice `X[7:0]` — in
    either bracket, including nested slices `out_cnt[10:8]`.

Scanner design:
    One comment-aware, string-aware, bracket-depth-aware pass over the
    whole file.  For each position it tries `NAME[`, finds the matching
    `]` at depth 1, and only rewrites when the very next character is
    `[` (i.e. a genuine two-D reference).  Single-bracket references
    `NAME[x]` and any reference inside a `//` / `/* */` comment or a
    `"..."` string are left untouched, so comments such as
    `// -> cu_poly[0]  256..511 -> cu_poly[1]` and the documentation
    line `cu_poly[p][128..255]` in a comment are never mangled.

Usage:
    python flatten_2d_arrays.py            # dry-run: prints plan + summary
    python flatten_2d_arrays.py --diff     # dry-run + unified diff
    python flatten_2d_arrays.py --apply    # writes kyber_kem.v + .pre_p1 backup
"""
import io, os, re, sys, shutil, difflib

HERE      = os.path.dirname(os.path.abspath(__file__))
ROOT      = os.path.dirname(HERE)
V         = os.path.join(ROOT, "rtl", "core", "kyber_kem.v")
BAK       = V + ".pre_p1"
APPLY     = "--apply" in sys.argv
SHOW_DIFF = "--diff" in sys.argv

# All 12 arrays that need `(* ram_style = "block" *)`.  The 11 two-D
# arrays ALSO get flattened; A_mat is already 1-D so only the
# attribute is added.
ARRAYS = [
    "A_mat",
    "s_poly", "e_poly", "t_poly", "r_poly", "e1_poly",
    "u_poly", "u_ntt_poly", "cu_poly",
    "s_ntt_poly", "e_ntt_poly", "r_ntt_poly",
]
# Two-D arrays only (those that also need access rewriting).
TWO_DIM = [n for n in ARRAYS if n != "A_mat"]

WORD = re.compile(r"[A-Za-z0-9_]")


# ---------------------------------------------------------------------------
# Bracket-depth helper: s[open_pos] must be '['; returns index of the
# matching ']' at depth 0, or -1.  Handles nesting (slices inside the
# index expression).
# ---------------------------------------------------------------------------
def match_bracket(s, open_pos):
    assert s[open_pos] == "["
    depth = 0
    j = open_pos
    L = len(s)
    while j < L:
        c = s[j]
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                return j
        j += 1
    return -1


def at_boundary(s, i):
    """True when s[i] starts a fresh identifier token."""
    return i == 0 or not WORD.match(s[i - 1])


# ---------------------------------------------------------------------------
# Comment / string aware scanner.  Rewrites every `NAME[a][b]` outside
# comments and string literals to `NAME[a*N + b]`.
# ---------------------------------------------------------------------------
def scan_2d(s, names, rewrite):
    """Scan `s`; return (new_s, counts) where counts maps name -> number
    of two-D references found (rewrite=True) or remaining (rewrite=False).
    """
    counts = dict((n, 0) for n in names)
    out = []
    i = 0
    L = len(s)
    nnames = len(names)
    while i < L:
        two = s[i:i + 2]
        # /* ... */ block comment
        if two == "/*":
            j = s.find("*/", i + 2)
            j = L if j < 0 else j + 2
            out.append(s[i:j]); i = j; continue
        # // line comment
        if two == "//":
            j = s.find("\n", i)
            j = L if j < 0 else j
            out.append(s[i:j]); i = j; continue
        # string literal
        if s[i] == '"':
            j = i + 1
            while j < L and s[j] != '"':
                j += 2 if s[j] == "\\" else 1
            j = min(j + 1, L)
            out.append(s[i:j]); i = j; continue

        hit = None
        for nm in names:
            pre = nm + "["
            if not s.startswith(pre, i) or not at_boundary(s, i):
                continue
            j = match_bracket(s, i + len(pre) - 1)
            if j < 0 or j + 1 >= L or s[j + 1] != "[":
                continue
            k = match_bracket(s, j + 1)
            if k < 0:
                continue
            hit = (nm, i, i + len(pre), j, k)
            break
        if hit:
            nm, start, a0, j, k = hit
            if rewrite:
                a = s[a0:j]
                b = s[j + 2:k]
                out.append("%s[%s*N + %s]" % (nm, a, b))
            else:
                out.append(s[start:k + 1])
            i = k + 1
            counts[nm] += 1
            continue

        out.append(s[i]); i += 1
    return "".join(out), counts


# ---------------------------------------------------------------------------
# Declaration rewrite: line based, naturally idempotent.
# ---------------------------------------------------------------------------
DECL_2D = re.compile(
    r"^(\s*)reg\s+\[BW-1:0\]\s+(\w+)\s+\[0:K-1\]\[0:N-1\];\s*(//.*)?$")
DECL_AM = re.compile(
    r"^(\s*)reg\s+\[BW-1:0\]\s+A_mat\s+\[0:K\*K\*N-1\];\s*(//.*)?$")


def _tail(m, n=3):
    """Re-attach the trailing `// comment` group (group index n)."""
    return m.group(n) if len(m.groups()) >= n and m.group(n) else ""


def rewrite_decls(s, arrays, two_dim):
    lines = s.split("\n")
    out = []
    added = 0
    skipped = []
    for line in lines:
        m = DECL_2D.match(line)
        if m and m.group(2) in two_dim:
            indent, nm, tail = m.group(1), m.group(2), _tail(m)
            flat = "%sreg [BW-1:0] %s [0:K*N-1];%s" % (
                indent, nm, "   " + tail if tail else "")
            if out and "ram_style" in out[-1]:
                out.append(flat)
                skipped.append(nm)
            else:
                out.append('%s(* ram_style = "block" *)' % indent)
                out.append(flat)
                added += 1
            continue
        m = DECL_AM.match(line)
        if m:
            indent, tail = m.group(1), _tail(m, 2)
            flat = "%sreg [BW-1:0] A_mat [0:K*K*N-1];%s" % (indent, tail)
            if out and "ram_style" in out[-1]:
                out.append(flat)
                skipped.append("A_mat")
            else:
                out.append('%s(* ram_style = "block" *)' % indent)
                out.append(flat)
                added += 1
            continue
        out.append(line)
    return "\n".join(out), added, skipped


# ---------------------------------------------------------------------------
def main():
    raw = io.open(V, "rb").read()
    CRLF = raw.count(b"\r\n") > raw.count(b"\n") - raw.count(b"\r\n")
    s = raw.decode("utf-8").replace("\r\n", "\n")   # normalise to LF
    s_orig = s
    n0 = s.count("\n") + 1

    print("=" * 74)
    print("P1-a.1: flatten 2-D packed arrays -> 1-D with ram_style=block")
    print("file : %s" % V)
    print("mode : %s" % ("APPLY" if APPLY else "DRY-RUN"))
    print("arrays: %d total (1 already 1-D, %d 2-D to flatten)"
          % (len(ARRAYS), len(TWO_DIM)))
    print("EOL  : %s" % ("CRLF" if CRLF else "LF"))
    print("=" * 74)

    # ---- Step 1: rewrite every 2-D access (comment-aware) --------------
    s, counts = scan_2d(s, TWO_DIM, rewrite=True)
    total_access = sum(counts.values())
    print("\n--- Step 1: 2-D access rewrite (comment/string aware) ---")
    for nm in TWO_DIM:
        print("  [flat] %-13s %2d access(es) -> X[a*N + b]" % (nm, counts[nm]))
    print("  TOTAL 2-D accesses rewritten : %d" % total_access)

    # ---- Step 2: declarations + ram_style ------------------------------
    s, added, skipped = rewrite_decls(s, ARRAYS, TWO_DIM)
    total_decl = added
    print("\n--- Step 2: declarations flattened + ram_style=block ---")
    print("  declarations rewritten : %d" % total_decl)
    if skipped:
        print("  already had ram_style  : %s (idempotent)" % ", ".join(skipped))

    total = total_access + total_decl
    print("\n--- summary ---")
    print("  TOTAL edits            : %d" % total)

    if SHOW_DIFF:
        print("\n--- unified diff (first 300 lines) ---")
        diff = list(difflib.unified_diff(
            s_orig.split("\n"), s.split("\n"),
            fromfile="kyber_kem.v (before)", tofile="kyber_kem.v (after)",
            lineterm="", n=2,
        ))
        for line in diff[:300]:
            print(line)
        if len(diff) > 300:
            print("... (%d diff lines total, truncated)" % len(diff))

    # ---- Step 3: post-conditions (on the prospective text) ------------
    print("\n--- post-condition checks ---")
    bad = False

    _, rem = scan_2d(s, TWO_DIM, rewrite=False)
    for nm in TWO_DIM:
        r = rem[nm]
        print("  [%s] %-13s remaining 2-D accesses: %d"
              % ("OK " if r == 0 else "BAD", nm, r))
        if r:
            bad = True

    for nm in ARRAYS:
        pat = re.compile(
            r'\(\*\s*ram_style\s*=\s*"block"\s*\*\)\s*'
            r"reg\s+\[BW-1:0\]\s+" + re.escape(nm))
        if pat.search(s):
            print("  [OK ] %-13s ram_style=block attribute present" % nm)
        else:
            print("  [BAD] %-13s ram_style=block attribute MISSING" % nm)
            bad = True

    if bad:
        print("\nABORTED: post-condition failed; %s left untouched." % V)
        return 1
    print("  All post-conditions passed.")

    if not APPLY:
        print("\n(dry-run) re-run with --apply to write %s" % V)
        return 0

    # ---- Step 4: backup + write ----------------------------------------
    if not os.path.exists(BAK):
        shutil.copy2(V, BAK)
        print("\n[backup] %s (%d B)" % (BAK, os.path.getsize(BAK)))
    if CRLF:
        s = s.replace("\n", "\r\n")
    io.open(V, "wb").write(s.encode("utf-8"))
    print("[write ] %s (%d B, %d lines, EOL=%s)"
          % (V, os.path.getsize(V), n0, "CRLF" if CRLF else "LF"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
