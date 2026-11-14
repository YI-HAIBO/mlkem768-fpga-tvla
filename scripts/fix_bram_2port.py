#!/usr/bin/env python3
"""
P1-c: Fix the 2-write-port / 2-read-port BRAM inference failure on
cu_poly and cv_poly.

Root causes (from Vivado 2026.1 synth.log):
  1. cv_poly  – Synth 8-2914 "Unsupported RAM template"
  2. cu_poly  – Synth 8-4767 "Invalid write to RAM / No valid clock"
     Dissolved into 12 288 FFs (768×16).

Both arrays are written by TWO separate always blocks (the standalone
ct_load block and the main FSM block), giving each array 2 write ports.
Vivado BRAM inference supports at most 1 write port per array.

Fix:
  a) Remove the standalone ct_load always block.
  b) Merge its write logic into the FSM's S_IDLE state (same always block
     as the FSM's own S_ENC_COMP writes).
  c) Simplify address expressions  out_cnt[9:8]*N + out_cnt[7:0]  →
     out_cnt[9:0]  and  0*N + ct_in_addr[7:0]  →  ct_in_addr[7:0]
     (and analogous), which Vivado can resolve to a clean bit-select.

Behaviour is preserved: ct_load is still guarded by !busy, and the FSM
writes cu_poly / cv_poly only in S_ENC_COMP.  The two write sources are
now in the same always block, in mutually-exclusive states, so Vivado
sees a single write port.
"""
from __future__ import annotations
import shutil, sys, difflib, re, pathlib

RTL = pathlib.Path(r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/"
                   r"调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype/"
                   r"rtl/core/kyber_kem.v")
BAK = RTL.with_suffix(RTL.suffix + ".pre_p1c")

src = RTL.read_text(encoding="utf-8")
orig = src
n_changes = 0

def sub(old: str, new: str, label: str) -> None:
    """Replace *old* with *new* in the module-level *src*, assert exactly
    one hit."""
    global src, n_changes
    cnt = src.count(old)
    if cnt != 1:
        print(f"[FATAL] '{label}': expected 1 hit, got {cnt}")
        sys.exit(1)
    src = src.replace(old, new, 1)
    n_changes += 1
    print(f"[OK] {label}")


# ------------------------------------------------------------------ #
# 1. Remove the standalone ct_load always block (L392-419).
# ------------------------------------------------------------------ #
old_ct_load = """    // -------------------------------------------------------------------------
    // Ciphertext load: let Decaps consume a ct that was NOT produced by this
    // instance's own Encaps (the realistic case: the ct arrives over the
    // network from the sender).  Mirrors the ct output address map exactly:
    //   0..255   -> cu_poly[0]   256..511 -> cu_poly[1]
    //   512..767 -> cu_poly[2]   768..1023-> cv_poly
    // Guarded by !busy so it cannot race the FSM's own decompress stage.
    // -------------------------------------------------------------------------
    // P1-b: clock-only sensitivity.  The async-reset branch bulk-cleared
    // cu_poly (3x256) and cv_poly (256) - 1024 write ports in a single
    // cycle, reset-only - which is what made both arrays un-inferrable as
    // Block RAM.  The ct_load datapath and the FSM's own decompress stage
    // always write these before they are read, so the clear is unnecessary.
    always @(posedge clk) begin
        if (ct_load && !busy) begin
                // 256 words per block, so bits [9:8] ARE the block index and
                // bits [7:0] are the offset.  Using a case avoids the
                // subtract-from-index formulation, which mis-routed loop data
                // into cu_poly[0] in iverilog (cu_poly[0] and cu_poly[2]
                // both ended up holding the cu2 words).
                case (ct_in_addr[9:8])
                    2'd0: cu_poly[0*N + ct_in_addr[7:0]] <= ct_data_in;
                    2'd1: cu_poly[1*N + ct_in_addr[7:0]] <= ct_data_in;
                    2'd2: cu_poly[2*N + ct_in_addr[7:0]] <= ct_data_in;
                    2'd3: cv_poly[ct_in_addr[7:0]]   <= ct_data_in;
                endcase
        end
    end

    // -------------------------------------------------------------------------"""

new_ct_load = """    // -------------------------------------------------------------------------"""
sub(old_ct_load, new_ct_load, "remove standalone ct_load always block")


# ------------------------------------------------------------------ #
# 2. Merge ct_load writes into FSM S_IDLE state.
# ------------------------------------------------------------------ #
old_s_idle = """                S_IDLE: begin
                    if (start) begin
                        busy <= 1;
                        i_idx <= 0; j_idx <= 0; coeff_cnt <= 0; byte_cnt <= 0;
                        phase <= 0; out_cnt <= 0;
                        if (op_keygen)      st <= S_KG_G;
                        else if (op_encaps) st <= S_ENC_R;
                        else                st <= S_DEC_DECOMP;
                    end
                end"""

new_s_idle = """                S_IDLE: begin
                    // P1-c: ct_load merged into the FSM always block so that
                    // cu_poly / cv_poly have only ONE write port (the FSM's
                    // own S_ENC_COMP write).  The standalone always block that
                    // used to handle ct_load created a second write port, which
                    // blocked BRAM inference (Synth 8-2914 / 8-4767).  Guarded
                    // by !busy so it cannot race the FSM's own decompress stage.
                    if (ct_load && !busy) begin
                        if (ct_in_addr[9:8] < 2'd3)
                            cu_poly[ct_in_addr[9:0]] <= ct_data_in;
                        else
                            cv_poly[ct_in_addr[7:0]] <= ct_data_in;
                    end
                    if (start) begin
                        busy <= 1;
                        i_idx <= 0; j_idx <= 0; coeff_cnt <= 0; byte_cnt <= 0;
                        phase <= 0; out_cnt <= 0;
                        if (op_keygen)      st <= S_KG_G;
                        else if (op_encaps) st <= S_ENC_R;
                        else                st <= S_DEC_DECOMP;
                    end
                end"""
sub(old_s_idle, new_s_idle, "merge ct_load into FSM S_IDLE")


# ------------------------------------------------------------------ #
# 3. Simplify address in S_ENC_COMP  (cu_poly / cv_poly writes).
# ------------------------------------------------------------------ #
old_enc_comp = """                S_ENC_COMP: begin
                    // out_cnt = poly*256 + coeff, so the coefficient index needs
                    // ALL 8 BITS (out_cnt[7:0]).  Using [6:0] covers only 0..127
                    // and silently folds out_cnt 128..255 back onto cu_poly[p]
                    // [0..127], leaving cu_poly[p][128..255] and
                    // cv_poly[128..255] unwritten (X).  The polynomial select
                    // is consequently out_cnt[9:8], not out_cnt[9:7].
                    if (out_cnt < 16'd768) begin
                        cu_poly[out_cnt[9:8]*N + out_cnt[7:0]] <=
                            compress_du(u_poly[out_cnt[9:8]*N + out_cnt[7:0]]);
                    end else begin
                        cv_poly[out_cnt[7:0]] <=
                            compress_dv(v_poly[out_cnt[7:0]]);
                    end
                    if (out_cnt == 16'd1023) begin"""

new_enc_comp = """                S_ENC_COMP: begin
                    // out_cnt = poly*256 + coeff.  out_cnt[9:0] is the flat
                    // 10-bit address into cu_poly (0..767); out_cnt[7:0] is the
                    // 8-bit address into cv_poly (0..255).  Using bit-selects
                    // instead of  out_cnt[9:8]*N + out_cnt[7:0]  lets Vivado
                    // match a clean BRAM address template.
                    if (out_cnt < 16'd768) begin
                        cu_poly[out_cnt[9:0]] <=
                            compress_du(u_poly[out_cnt[9:0]]);
                    end else begin
                        cv_poly[out_cnt[7:0]] <=
                            compress_dv(v_poly[out_cnt[7:0]]);
                    end
                    if (out_cnt == 16'd1023) begin"""
sub(old_enc_comp, new_enc_comp, "simplify S_ENC_COMP address")


# ------------------------------------------------------------------ #
# 4. Simplify address in S_DEC_DECOMP  (cu_poly / cv_poly reads).
# ------------------------------------------------------------------ #
old_dec_decomp = """                S_DEC_DECOMP: begin
                    // Same out_cnt[7:0] fix as S_ENC_COMP - see the note there.
                    if (out_cnt < 16'd768) begin
                        u_poly[out_cnt[9:8]*N + out_cnt[7:0]] <=
                            decompress_du(cu_poly[out_cnt[9:8]*N + out_cnt[7:0]]);
                    end else begin
                        v_poly[out_cnt[7:0]] <=
                            decompress_dv(cv_poly[out_cnt[7:0]]);
                    end
                    if (out_cnt == 16'd1023) begin"""

new_dec_decomp = """                S_DEC_DECOMP: begin
                    // Same bit-select address as S_ENC_COMP (see note there).
                    if (out_cnt < 16'd768) begin
                        u_poly[out_cnt[9:0]] <=
                            decompress_du(cu_poly[out_cnt[9:0]]);
                    end else begin
                        v_poly[out_cnt[7:0]] <=
                            decompress_dv(cv_poly[out_cnt[7:0]]);
                    end
                    if (out_cnt == 16'd1023) begin"""
sub(old_dec_decomp, new_dec_decomp, "simplify S_DEC_DECOMP address")


# ------------------------------------------------------------------ #
# 5. Simplify address in S_ENC_OUTPUT  (cu_poly / cv_poly reads).
# ------------------------------------------------------------------ #
old_enc_output = """                S_ENC_OUTPUT: begin
                    if (out_cnt < 16'd1024) begin
                        ct_valid <= 1;
                        ct_addr  <= out_cnt;
                        if      (out_cnt < 16'd256) ct_data <= cu_poly[0*N + out_cnt[7:0]];
                        else if (out_cnt < 16'd512) ct_data <= cu_poly[1*N + out_cnt[7:0]];
                        else if (out_cnt < 16'd768) ct_data <= cu_poly[2*N + out_cnt[7:0]];
                        else                        ct_data <= cv_poly[out_cnt[7:0]];
                        out_cnt <= out_cnt + 16'd1;"""

new_enc_output = """                S_ENC_OUTPUT: begin
                    if (out_cnt < 16'd1024) begin
                        ct_valid <= 1;
                        ct_addr  <= out_cnt;
                        if (out_cnt < 16'd768)
                            ct_data <= cu_poly[out_cnt[9:0]];
                        else
                            ct_data <= cv_poly[out_cnt[7:0]];
                        out_cnt <= out_cnt + 16'd1;"""
sub(old_enc_output, new_enc_output, "simplify S_ENC_OUTPUT address")


# ------------------------------------------------------------------ #
# Write + backup
# ------------------------------------------------------------------ #
if src != orig:
    BAK.write_text(orig, encoding="utf-8")
    RTL.write_text(src, encoding="utf-8")
    print(f"\nDone: {n_changes} edits.  Backup -> {BAK.name}")
else:
    print("\nNo changes made.")
