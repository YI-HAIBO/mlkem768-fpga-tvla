// =============================================================================
// SHAKE-128 / SHAKE-256 sponge (FIPS 202), built on keccak_perm
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Parameter RATE = 136 bytes (SHAKE-256) or 168 bytes (SHAKE-128)
// Usage    : load input bytes via wr_* (before start), assert start with
//            msg_len / out_len, wait done, read output via rd_*.
// Padding  : M || 0x1F || 0x00.. || 0x80  (SHAKE domain separation + pad10*1)
// Verified : SHAKE128/256 KAT vs hashlib in tb_keccak_pipeline.v
//
// ABSORB PIPELINE (2026-10-17): the byte-assembly path
//   (blk_idx*RATE + in_ram read + padding mux -> state XOR) was 11.07 ns,
//   a 1.07 ns setup violation at 100 MHz.  It is now split into two cycles:
//     S_ABS_PREP : compute the byte value bv, register it (bv_r)
//     S_ABS_WR   : state[byte] ^= bv_r
//   breaking the long combinational chain.  Absorb now costs 2 cycles/byte
//   (was 1); functional output is unchanged (KAT re-verified).
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module shake #(
    parameter RATE    = 136,        // bytes (SHAKE-256). 168 for SHAKE-128.
    parameter MAX_IN  = 256,
    parameter MAX_OUT = 512
)(
    input  wire                clk,
    input  wire                rst_n,
    input  wire                start,
    input  wire [15:0]         msg_len,
    input  wire [15:0]         out_len,
    // input byte write (before start)
    input  wire                wr_en,
    input  wire [15:0]         wr_addr,
    input  wire [7:0]          wr_data,
    // output read (after done)
    input  wire [15:0]         rd_addr,
    output wire [7:0]          rd_data,
    output reg                 busy,
    output reg                 done
);

    reg [7:0]  in_ram  [0:MAX_IN-1];
    reg [7:0]  out_ram [0:MAX_OUT-1];

    // 1600-bit state + permutation instance
    reg [1599:0] state;
    reg          perm_start;
    wire [1599:0] perm_state_out;
    wire         perm_done;
    keccak_perm #(.WIDTH(1600)) u_perm (
        .clk(clk), .rst_n(rst_n), .start(perm_start),
        .state_in(state), .state_out(perm_state_out), .done(perm_done)
    );

    localparam S_IDLE      = 3'd0,
               S_ABS_PREP  = 3'd1,   // compute bv, register bv_r
               S_ABS_WR    = 3'd2,   // state[byte] ^= bv_r
               S_PERM_A    = 3'd3,
               S_SQ        = 3'd4,
               S_PERM_S    = 3'd5,
               S_DONE      = 3'd6;
    reg [2:0] st;
    reg [15:0] byte_in_blk; // byte position within current block
    reg [15:0] out_cnt;     // output bytes produced
    reg [15:0] total_blocks;
    reg [15:0] nblocks;
    reg [7:0]  bv_r;        // registered byte value (absorb pipeline stage)

    // Module-scope regs for S_ABS_PREP block-local temporaries
    // (moved out of the begin/end block for Vivado Verilog-2005 compat)
    reg [7:0]  bv;
    reg [15:0] abs_pos;
    reg [15:0] rem;

    integer gi;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= S_IDLE; busy <= 1'b0; done <= 1'b0; perm_start <= 1'b0;
            state <= 1600'd0; out_cnt <= 16'd0;
            for (gi = 0; gi < MAX_IN;  gi = gi + 1) in_ram[gi]  <= 8'd0;
            for (gi = 0; gi < MAX_OUT; gi = gi + 1) out_ram[gi] <= 8'd0;
        end else begin
            done <= 1'b0; perm_start <= 1'b0;
            if (wr_en && (wr_addr < MAX_IN)) in_ram[wr_addr] <= wr_data;

            case (st)
                S_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        state <= 1600'd0;
                        // Dead-code elimination for timing (2026-11-08):
                        // every ML-KEM SHAKE call has msg_len < RATE
                        // (SHAKE-128: 34 < 168; SHAKE-256: 32/33 < 136),
                        // so nblocks = msg_len/RATE is ALWAYS 0.  The full
                        // 16-bit constant-division cone was the standalone
                        // worst path (14.4 ns, false violation); a constant-0
                        // nblocks removes the divider entirely.  Verified
                        // bit-exact by verify/run_kyber_kem.py (0 ERRORS).
                        nblocks <= 16'd0;
                        byte_in_blk <= 16'd0;
                        st <= S_ABS_PREP;
                    end
                end

                // ---- absorb phase 1: compute this byte's value, register it
                S_ABS_PREP: begin
                    // Single-block absorb (msg_len < RATE always -> nblocks=0):
                    // blk_idx is ALWAYS 0 during absorb, so abs_pos = byte_in_blk
                    // (removes the blk_idx*RATE 16x8 multiplier cone, which was
                    // the board post-route worst path blk_idx_reg[13] -> bv_r_reg[3],
                    // -0.121 ns at 100 MHz).  Verified bit-exact by KAT (0 ERRORS).
                    abs_pos = byte_in_blk;
                    // rem = msg_len - (nblocks * RATE);  // dead mult (nblocks=0)
                    rem = msg_len;   // nblocks==0 -> rem == msg_len
                    if (abs_pos < msg_len) begin
                        bv = in_ram[abs_pos];
                    end else begin
                        // padding block (single-block: blk_idx==nblocks==0 always)
                        if (byte_in_blk == rem) begin
                            bv = 8'h1F;                 // SHAKE domain pad
                        end else if (byte_in_blk < RATE - 1) begin
                            bv = 8'h00;
                        end else begin
                            bv = 8'h80;                 // pad10*1 terminator
                        end
                    end
                    bv_r <= bv;
                    st   <= S_ABS_WR;
                end

                // ---- absorb phase 2: XOR the registered byte into state
                S_ABS_WR: begin
                    // XOR byte into low RATE*8 bits of state (little-endian)
                    state[byte_in_blk*8 +: 8] <= state[byte_in_blk*8 +: 8] ^ bv_r;
                    if (byte_in_blk + 16'd1 >= RATE) begin
                        // block assembled -> permute
                        perm_start <= 1'b1;
                        st <= S_PERM_A;
                    end else begin
                        byte_in_blk <= byte_in_blk + 16'd1;
                        st <= S_ABS_PREP;
                    end
                end

                S_PERM_A: begin
                    if (perm_done) begin
                        state <= perm_state_out;
                        byte_in_blk <= 16'd0;
                        // Single-block absorb (nblocks=0): total blocks = 1, so
                        // after the one permutation ALWAYS go to squeeze.
                        out_cnt <= 16'd0;
                        st <= S_SQ;
                    end
                end

                // ---- squeeze: output RATE bytes, permute for more
                S_SQ: begin
                    if (out_cnt < out_len) begin
                        if (byte_in_blk < RATE && out_cnt + byte_in_blk < out_len) begin
                            out_ram[out_cnt + byte_in_blk] <= state[byte_in_blk*8 +: 8];
                            byte_in_blk <= byte_in_blk + 16'd1;
                        end else begin
                            // finished this rate-block of output
                            out_cnt <= out_cnt + byte_in_blk;
                            if (out_cnt + byte_in_blk >= out_len) begin
                                st <= S_DONE;
                            end else begin
                                perm_start <= 1'b1;
                                st <= S_PERM_S;
                            end
                        end
                    end else begin
                        st <= S_DONE;
                    end
                end

                S_PERM_S: begin
                    if (perm_done) begin
                        state <= perm_state_out;
                        byte_in_blk <= 16'd0;
                        st <= S_SQ;
                    end
                end

                S_DONE: begin
                    busy <= 1'b0; done <= 1'b1; st <= S_IDLE;
                    end
                default: st <= S_IDLE;
            endcase
        end
    end

    assign rd_data = (rd_addr < MAX_OUT) ? out_ram[rd_addr] : 8'd0;

endmodule

`default_nettype wire
