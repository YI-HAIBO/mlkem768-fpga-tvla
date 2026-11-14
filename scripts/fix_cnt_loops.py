# -*- coding: utf-8 -*-
"""
Problem-A fix for rtl/core/kyber_kem.v
======================================

Root cause (Vivado Synth 8-6090 x5 + Synth 8-327 latch x1):

    coeff_cnt / byte_cnt / load_cnt are declared as `reg` FSM state, but the
    same names are also reused as `for`-loop indices (blocking `=`).  One
    variable is therefore written with BOTH `<=` (FSM control path) and `=`
    (loop control) - inside the main FSM block, and across blocks 1/2/3 for
    load_cnt.  Vivado reports the mixed assignment, and the loop's blocking
    side-effect on an FSM register is what trips the latch-inference check.

Fix:

    Introduce three module-scope `integer` loop iterators (lc / lb / ll) and
    retarget every for-loop onto them.  After the change:
      - coeff_cnt / byte_cnt / load_cnt are written ONLY with `<=`
      - lc / lb / ll are written ONLY with blocking `=` (loop control)
    Behaviour is bit-identical: the iterators are pure elaboration-time
    variables that Vivado unrolls and eliminates, and each loop was already
    followed by an explicit `<reg> <= 0;` that restores the FSM value, so
    the removed blocking side-effect was never load-bearing.

    The now-redundant `coeff_cnt <= 0;` / `byte_cnt <= 0;` statements are
    LEFT IN PLACE on purpose - they are harmless and removing them would add
    edit surface with no warning-closure benefit.

Usage:  python fix_cnt_loops.py            (dry-run: prints plan only)
        python fix_cnt_loops.py --apply   (writes kyber_kem.v + .pre_cntfix backup)
"""
import io, os, re, sys, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
V    = os.path.join(ROOT, "rtl", "core", "kyber_kem.v")
BAK  = V + ".pre_cntfix"
APPLY = "--apply" in sys.argv

# --------------------------------------------------------------------------
# EDIT TABLE.  Each entry: (label, old, new, expect_count)
# `old` must match byte-exactly.  count is the number of replacements made.
# --------------------------------------------------------------------------
INT_DECL = """    integer lc;          // coeff_cnt loop iterator (elaboration-time only)
    integer lb;          // byte_cnt  loop iterator (elaboration-time only)
    integer ll;          // load_cnt  loop iterator (elaboration-time only)
"""

EDITS = []

# --- declarations: anchor on the Counters block tail -----------------------
EDITS.append((
    "declare lc / lb / ll after out_cnt",
    "    reg [15:0] out_cnt;     // output byte counter (pk/ct/ss)\n",
    "    reg [15:0] out_cnt;     // output byte counter (pk/ct/ss)\n" + INT_DECL,
    1,
))

# --- block 1: seed_buf / msg_buf clear (2 loops) --------------------------
EDITS.append((
    "block1: seed_buf/msg_buf clear loops -> ll",
    "            for (load_cnt = 0; load_cnt < SEED_B; load_cnt = load_cnt + 1)\n"
    "                seed_buf[load_cnt] <= 8'd0;\n"
    "            for (load_cnt = 0; load_cnt < MSG_B; load_cnt = load_cnt + 1)\n"
    "                msg_buf[load_cnt] <= 8'd0;\n",
    "            for (ll = 0; ll < SEED_B; ll = ll + 1)\n"
    "                seed_buf[ll] <= 8'd0;\n"
    "            for (ll = 0; ll < MSG_B; ll = ll + 1)\n"
    "                msg_buf[ll] <= 8'd0;\n",
    1,
))

# --- block 2: cu_poly / cv_poly clear (3 loops, one nested) ---------------
EDITS.append((
    "block2: cu_poly/cv_poly clear loops -> ll, lc",
    "            for (load_cnt = 0; load_cnt < K; load_cnt = load_cnt + 1)\n"
    "                for (coeff_cnt = 0; coeff_cnt < N; coeff_cnt = coeff_cnt + 1)\n"
    "                    cu_poly[load_cnt][coeff_cnt] <= 16'd0;\n"
    "            for (coeff_cnt = 0; coeff_cnt < N; coeff_cnt = coeff_cnt + 1)\n"
    "                cv_poly[coeff_cnt] <= 16'd0;\n",
    "            for (ll = 0; ll < K; ll = ll + 1)\n"
    "                for (lc = 0; lc < N; lc = lc + 1)\n"
    "                    cu_poly[ll][lc] <= 16'd0;\n"
    "            for (lc = 0; lc < N; lc = lc + 1)\n"
    "                cv_poly[lc] <= 16'd0;\n",
    1,
))

# --- block 3: acc[] clear loop (4 IDENTICAL occurrences: L921/1355/1479/1836)
EDITS.append((
    "block3: acc[] clear loops -> lc  (4x)",
    "                            for (coeff_cnt = 0; coeff_cnt < N; coeff_cnt = coeff_cnt + 1)\n"
    "                                acc[coeff_cnt] <= 16'd0;\n",
    "                            for (lc = 0; lc < N; lc = lc + 1)\n"
    "                                acc[lc] <= 16'd0;\n",
    4,
))

# --- block 3: t_poly[i] add-e_ntt loop (1 occurrence, L1001-1005) ---------
EDITS.append((
    "block3: t_poly phase-7 loop -> lc  (1x)",
    "                            for (coeff_cnt = 0; coeff_cnt < N; coeff_cnt = coeff_cnt + 1)\n"
    "                                t_poly[i_idx][coeff_cnt] <= barrett_reduce(\n"
    "                                    $signed(acc[coeff_cnt]) +\n"
    "                                    $signed(e_ntt_poly[i_idx][coeff_cnt])\n"
    "                                );\n",
    "                            for (lc = 0; lc < N; lc = lc + 1)\n"
    "                                t_poly[i_idx][lc] <= barrett_reduce(\n"
    "                                    $signed(acc[lc]) +\n"
    "                                    $signed(e_ntt_poly[i_idx][lc])\n"
    "                                );\n",
    1,
))

# --- block 3: m_prime_buf clear loop (1 occurrence, L1945-1946) -----------
EDITS.append((
    "block3: m_prime_buf clear loop -> lb  (1x)",
    "                            for (byte_cnt = 0; byte_cnt < MSG_B; byte_cnt = byte_cnt + 1)\n"
    "                                m_prime_buf[byte_cnt] <= 8'd0;\n",
    "                            for (lb = 0; lb < MSG_B; lb = lb + 1)\n"
    "                                m_prime_buf[lb] <= 8'd0;\n",
    1,
))

# --------------------------------------------------------------------------
def main():
    # Detect the file's native line ending first so we can preserve it on
    # write-back.  The project mixes CRLF (kyber_*.v) and LF, and the
    # original kyber_kem.v is CRLF - an editor-neutral rewrite must not
    # silently normalise the whole file, or every diff becomes 2000 lines.
    raw = io.open(V, "rb").read()
    CRLF = raw.count(b"\r\n") > raw.count(b"\n") - raw.count(b"\r\n")
    EOL = "\r\n" if CRLF else "\n"
    s = io.open(V, encoding="utf-8").read()
    n0 = len(s.split("\n"))
    print("=" * 74)
    print("Problem-A fix: kyber_kem.v loop-iterator separation")
    print("file : %s" % V)
    print("mode : %s" % ("APPLY" if APPLY else "DRY-RUN"))
    print("=" * 74)

    if not APPLY and not os.path.exists(BAK):
        print("[backup] would write %s" % BAK)

    # 1) verify every anchor exists, in order, with the expected count
    cursor = 0
    ok = True
    for label, old, new, exp in EDITS:
        found = 0
        pos = 0
        while True:
            i = s.find(old, pos)
            if i < 0:
                break
            found += 1
            pos = i + 1
        if found != exp:
            print("[FAIL] %-46s expected %d match(es), found %d" % (label, exp, found))
            ok = False
        else:
            print("[ ok ] %-46s %d match(es)" % (label, found))
    if not ok:
        print("\nABORTED: an anchor did not match. No changes made.")
        return 1

    # 2) apply (right-to-left is unnecessary; all anchors are distinct text
    #    blocks and every replacement is count-verified above)
    if APPLY:
        if not os.path.exists(BAK):
            shutil.copy2(V, BAK)
            print("[backup] wrote %s (%d B)" % (BAK, os.path.getsize(BAK)))
        for label, old, new, exp in EDITS:
            s = s.replace(old, new)
        # io.open() text mode applied universal-newline translation on read,
        # so `s` is LF-normalised.  Restore the original EOL before writing.
        if CRLF:
            s = s.replace("\r\n", "\n").replace("\n", "\r\n")
        io.open(V, "wb").write(s.encode("utf-8"))
        print("[write ] %s (%d B, %d -> %d lines, EOL=%s)"
              % (V, os.path.getsize(V), n0, len(s.split("\n")),
                 "CRLF" if CRLF else "LF"))

    # 3) post-conditions, evaluated on the POST-replacement text:
    #      - no for-loop header may use one of the three FSM regs as iterator
    #      - no blocking `=` may assign one of the three FSM regs
    #        (exclude `==`, `!=`, `<=`, `=>`)
    #      - the three iterators must each be declared once and used
    s2 = s
    for label, old, new, exp in EDITS:
        s2 = s2.replace(old, new)

    print("\n--- post-condition checks (on post-replacement text) ---")
    for reg in ("coeff_cnt", "byte_cnt", "load_cnt"):
        hdr = re.findall(r"for\s*\(\s*%s\s*=" % reg, s2)
        plain = re.findall(r"(?<![<!=])\b%s\s*=(?!=)" % reg, s2)
        nbe = re.findall(r"\b%s\s*<=" % reg, s2)
        flag = "OK " if not hdr and not plain else "BAD"
        print("  [%s] %-10s  for-headers: %d   blocking '=': %d   non-blocking '<=': %d"
              % (flag, reg, len(hdr), len(plain), len(nbe)))
    tot = {n: len(re.findall(r"\b%s\b" % n, s2)) for n in ("lc", "lb", "ll")}
    decl = {n: len(re.findall(r"^\s*integer\s+%s\s*;" % n, s2, re.M)) for n in ("lc", "lb", "ll")}
    print("  %-10s  lc / lb / ll reference counts: %s" % ("OK " if all(v > 0 for v in tot.values()) else "BAD", tot))
    print("  %-10s  lc / lb / ll integer declarations: %s"
          % ("OK " if all(v == 1 for v in decl.values()) else "BAD", decl))
    return 0


if __name__ == "__main__":
    sys.exit(main())
