# -*- coding: utf-8 -*-
"""
P1-b — make the polynomial memories BRAM-inferrable (reset style + bulk writes)
===============================================================================

What P1-a.1 proved and did not prove
------------------------------------
`flatten_2d_arrays.py` (P1-a.1) flattened the 11 two-D packed arrays to 1-D and
was proven bit-exact.  The full-top re-synthesis of that change showed

    Synth 8-7186 = 0     (was 101)   <- the 2-D shape complaint is GONE
    Synth 8-4767 = 20                 <- but inference STILL fails
    "is dissolved into (12288) registers bits"  x 12 arrays

i.e. flattening was necessary but NOT sufficient.  The log states the real
reason verbatim:

    1: RAM is sensitive to asynchronous reset signal.
       this RTL style is not supported.

Two further defects, visible only after 8-7186 cleared:

    t_poly:  "RAM has multiple writes via different ports in same process"
             "Invalid write to RAM"
    cu_poly: the same, from its reset clear loop

Root causes and fixes
---------------------
Block 1 (L378)  always @(posedge clk or negedge rst_n)
                Reset branch bulk-clears seed_buf/msg_buf with for-loops.
  ->  always @(posedge clk); delete the clear loops.  Both buffers are 32
      bytes; nobody reads them before writing, so the clear is dead weight
      and is exactly what poisons the RAM inference.

Block 2 (L402)  always @(posedge clk or negedge rst_n)
                Reset branch bulk-clears cu_poly (3x256) and cv_poly (256)
                - 1024 write ports in one cycle, reset-only.
  ->  always @(posedge clk); delete the clear loops.  cu_poly/cv_poly are
      always written by the ct_load datapath or the FSM's own decompress
      stage before being read, so the clear is unnecessary.

Block 3 (L429)  always @(posedge clk or negedge rst_n)
                Reset branch touches ONLY control regs (st/busy/i_idx/...) -
                no array writes at all.  All 16 array writes already sit in
                the else branch in the canonical one-word-per-cycle form
                `X[i*N + coeff_cnt[7:0]] <= data;` guarded by (st, phase).
  ->  always @(posedge clk).  Sensitivity-list change only; the branch body
      is untouched, so simulation behaviour is unchanged for any testbench
      that holds rst_n low for at least one clock period.

Phase 7 (L1014-1022)
                `for (lc = 0; lc < N; lc = lc + 1) t_poly[i*N + lc] <= ...`
                writes all 256 coefficients in ONE cycle => 256 RAM write
                ports.  Un-inferrable regardless of reset style.
  ->  sequentialise to one coefficient per cycle, re-arming coeff_cnt in
      phase 6 (which hands off to phase 7 with coeff_cnt still == 255).
      t_poly[i] is not read until S_KG_OUTPUT, which runs after S_KG_DONE
      after phase 8, so the end state is identical.

      Note that `acc` and `e_ntt_poly` are read 256x across those cycles;
      neither is written during phase 7, so the reads are stable.

Behaviour preservation: bit-exact regression (scripts/regress_p1b.py) is
required before accepting.  Acceptance needs a full-top re-synthesis
(showing BRAM > 0) which is not possible locally in one pass.

Usage:
    python fix_bram_template.py            # dry-run: prints the plan
    python fix_bram_template.py --apply    # writes kyber_kem.v + .pre_p1b
"""
import io, os, sys, shutil, difflib

HERE  = os.path.dirname(os.path.abspath(__file__))
ROOT  = os.path.dirname(HERE)
V     = os.path.join(ROOT, "rtl", "core", "kyber_kem.v")
BAK   = V + ".pre_p1b"
APPLY = "--apply" in sys.argv

# ---------------------------------------------------------------------------
# Block 1: seed/message load
# ---------------------------------------------------------------------------
BLOCK1_OLD = """    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (ll = 0; ll < SEED_B; ll = ll + 1)
                seed_buf[ll] <= 8'd0;
            for (ll = 0; ll < MSG_B; ll = ll + 1)
                msg_buf[ll] <= 8'd0;
        end else begin
            if (in_load && !busy) begin
                if (in_addr < SEED_B)
                    seed_buf[in_addr] <= in_data;
                else if (in_addr < SEED_B + MSG_B)
                    msg_buf[in_addr - SEED_B] <= in_data;
            end
        end
    end"""

BLOCK1_NEW = """    // P1-b: clock-only sensitivity.  The previous async-reset branch
    // bulk-cleared these buffers with for-loops, which marked the arrays as
    // "sensitive to asynchronous reset signal" - a style Vivado will not map
    // to Block RAM (Synth 8-4767).  Nobody reads either buffer before the
    // loader writes it, so the clear was dead weight.
    always @(posedge clk) begin
        if (in_load && !busy) begin
            if (in_addr < SEED_B)
                seed_buf[in_addr] <= in_data;
            else if (in_addr < SEED_B + MSG_B)
                msg_buf[in_addr - SEED_B] <= in_data;
        end
    end"""

# ---------------------------------------------------------------------------
# Block 2: ciphertext load
# ---------------------------------------------------------------------------
BLOCK2_OLD = """    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (ll = 0; ll < K; ll = ll + 1)
                for (lc = 0; lc < N; lc = lc + 1)
                    cu_poly[ll*N + lc] <= 16'd0;
            for (lc = 0; lc < N; lc = lc + 1)
                cv_poly[lc] <= 16'd0;
        end else begin
            if (ct_load && !busy) begin"""

BLOCK2_NEW = """    // P1-b: clock-only sensitivity.  The async-reset branch bulk-cleared
    // cu_poly (3x256) and cv_poly (256) - 1024 write ports in a single
    // cycle, reset-only - which is what made both arrays un-inferrable as
    // Block RAM.  The ct_load datapath and the FSM's own decompress stage
    // always write these before they are read, so the clear is unnecessary.
    always @(posedge clk) begin
        if (ct_load && !busy) begin"""

# the tail of block 2: the reset's `end else begin` contributed one extra
# `end`; drop it so the begin/end pairs still balance
BLOCK2_TAIL_OLD = """                endcase
            end
        end
    end"""

BLOCK2_TAIL_NEW = """                endcase
        end
    end"""

# ---------------------------------------------------------------------------
# Block 3: main FSM - sensitivity list only
# ---------------------------------------------------------------------------
BLOCK3_OLD = """    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= S_IDLE;"""

BLOCK3_NEW = """    // P1-b: clock-only sensitivity (synchronous reset).  This branch touches
    // only control registers - no array writes - yet its async-reset
    // sensitivity is what marked every polynomial array as "sensitive to
    // asynchronous reset signal" and blocked Block RAM inference.
    always @(posedge clk) begin
        if (!rst_n) begin
            st <= S_IDLE;"""

# ---------------------------------------------------------------------------
# KeyGen phase 6 -> 7 hand-off must re-arm coeff_cnt
# ---------------------------------------------------------------------------
P6_OLD = """                            end else begin
                                phase <= 4'd7;
                            end
                        end
                        // Phase 7: ADD e_ntt[i] to acc -> t_poly[i]
                        4'd7: begin
                            for (lc = 0; lc < N; lc = lc + 1)
                                t_poly[i_idx*N + lc] <= barrett_reduce(
                                    $signed(acc[lc]) +
                                    $signed(e_ntt_poly[i_idx*N + lc])
                                );
                            phase <= 4'd8;
                        end"""

P6_NEW = """                            end else begin
                                coeff_cnt <= 0;   // re-arm: phase 7 writes one coeff/cycle
                                phase <= 4'd7;
                            end
                        end
                        // Phase 7: ADD e_ntt[i] to acc -> t_poly[i], one
                        // coefficient per cycle.  P1-b: the previous
                        // `for (lc = 0; lc < N; ...)` wrote all 256 entries
                        // in a single cycle, i.e. 256 RAM write ports in one
                        // process, which Vivado rejects ("multiple writes via
                        // different ports in same process", Synth 8-4767).
                        // acc / e_ntt_poly are not written in this phase and
                        // t_poly[i] is not read until S_KG_OUTPUT, so the
                        // end state is identical.
                        4'd7: begin
                            t_poly[i_idx*N + coeff_cnt[7:0]] <= barrett_reduce(
                                $signed(acc[coeff_cnt[7:0]]) +
                                $signed(e_ntt_poly[i_idx*N + coeff_cnt[7:0]])
                            );
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd8;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end"""


EDITS = [
    ("Block 1  seed/msg load  -> @(posedge clk), clear loops deleted",
     BLOCK1_OLD, BLOCK1_NEW),
    ("Block 2  ct load  -> @(posedge clk), clear loops deleted",
     BLOCK2_OLD, BLOCK2_NEW),
    ("Block 2  tail begin/end rebalance",
     BLOCK2_TAIL_OLD, BLOCK2_TAIL_NEW),
    ("Block 3  main FSM  -> @(posedge clk) (synchronous reset)",
     BLOCK3_OLD, BLOCK3_NEW),
    ("KeyGen phase 6->7 re-arm coeff_cnt; phase 7 sequentialised",
     P6_OLD, P6_NEW),
]


def main():
    raw = io.open(V, "rb").read()
    CRLF = raw.count(b"\r\n") > raw.count(b"\n") - raw.count(b"\r\n")
    s = raw.decode("utf-8").replace("\r\n", "\n")
    s_orig = s

    print("=" * 76)
    print("P1-b: make polynomial memories BRAM-inferrable")
    print("file : %s" % V)
    print("mode : %s" % ("APPLY" if APPLY else "DRY-RUN"))
    print("EOL  : %s" % ("CRLF" if CRLF else "LF"))
    print("=" * 76)

    n = 0
    for label, old, new in EDITS:
        c = s.count(old)
        if c != 1:
            print("[FAIL] %-70s anchor found %d time(s), need 1" % (label, c))
            return 1
        s = s.replace(old, new, 1)
        n += 1
        print("[ ok ] %-70s" % label)
    print("\n  edits applied in memory : %d" % n)

    # ---- post-conditions -------------------------------------------------
    print("\n--- post-condition checks ---")
    bad = False

    # 1. no async reset left anywhere in the module
    async_cnt = s.count("posedge clk or negedge rst_n")
    print("  [%s] async-reset sensitivity lists : %d (expect 0)"
          % ("OK " if async_cnt == 0 else "BAD", async_cnt))
    if async_cnt:
        bad = True

    # 2. sync-reset branch retained in the FSM (control regs still reset)
    ok_sync = "if (!rst_n) begin\n            st <= S_IDLE;" in s
    print("  [%s] FSM synchronous-reset branch intact" % ("OK " if ok_sync else "BAD"))
    if not ok_sync:
        bad = True

    # 3. no bulk-clear for-loops left into the poly memories
    import re
    for nm in ("cu_poly", "cv_poly", "seed_buf", "msg_buf"):
        hits = re.findall(r"%s\[[^\]]*\]\s*<=\s*1[6']?d0" % re.escape(nm), s)
        print("  [%s] %-9s reset-clear writes : %d (expect 0)"
              % ("OK " if not hits else "BAD", nm, len(hits)))
        if hits:
            bad = True

    # 4. the t_poly bulk write is gone
    bulk = "for (lc = 0; lc < N; lc = lc + 1)\n                                t_poly" in s
    print("  [%s] t_poly bulk for-loop write removed" % ("OK " if not bulk else "BAD"))
    if bulk:
        bad = True

    # 5. begin/end balance (rough but catches the block-2 rebalance mistake)
    def body_only(t):
        out, i, L = [], 0, len(t)
        while i < L:
            if t[i:i+2] == "/*":
                j = t.find("*/", i + 2); j = L if j < 0 else j + 2; i = j; continue
            if t[i:i+2] == "//":
                j = t.find("\n", i); j = L if j < 0 else j; i = j; continue
            if t[i] == '"':
                j = i + 1
                while j < L and t[j] != '"':
                    j += 2 if t[j] == "\\" else 1
                i = min(j + 1, L); continue
            out.append(t[i]); i += 1
        return "".join(out)
    b = body_only(s)
    nb, ne = len(re.findall(r"\bbegin\b", b)), len(re.findall(r"\bend\b", b))
    print("  [%s] begin=%d end=%d  (diff %d)"
          % ("OK " if nb == ne else "BAD", nb, ne, ne - nb))
    if nb != ne:
        bad = True

    if bad:
        print("\nABORTED: post-condition failed; %s left untouched." % V)
        return 1
    print("  All post-conditions passed.")

    if not APPLY:
        print("\n(dry-run) re-run with --apply to write %s" % V)
        return 0

    if not os.path.exists(BAK):
        shutil.copy2(V, BAK)
        print("\n[backup] %s (%d B)" % (BAK, os.path.getsize(BAK)))
    if CRLF:
        s = s.replace("\n", "\r\n")
    io.open(V, "wb").write(s.encode("utf-8"))
    print("[write ] %s (%d B, EOL=%s, %d -> %d lines)"
          % (V, os.path.getsize(V), "CRLF" if CRLF else "LF",
             s_orig.count("\n") + 1, s.count("\r\n") + 1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
