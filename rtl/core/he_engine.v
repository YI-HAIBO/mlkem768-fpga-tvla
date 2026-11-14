// =============================================================================
// B1: Homomorphic-Encryption Inference Engine (BGV-style integer slots)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B1: HE inference)
//
// Design goal: run the linear stage of model inference WITHOUT EVER
// DECRYPTING THE INPUT, so an attacker who scrapes the bus between the
// sensor front-end and the inference core cannot read the feature vector.
//
// Scheme (BGV-flavored, integer slot, toy parameters chosen so every
// reduction is a power of two -> free in hardware):
//
//   ciphertext modulus  q  = 2^16      (mod q = 16-bit wraparound)
//   plaintext  modulus  p  = 2^8       (message is a byte)
//   encoding scale     /\ = q/p = 256  (message sits at bits [15:8])
//
//   secret key      s  ∈ {0,1}
//   public key      a  = LCG(seed)
//                    b  = -a*s mod 2^16
//   encryption of m:  r  = LCG bit
//                     c0 = b*r + /\*m  mod q
//                     c1 = a*r         mod q
//   decryption:       v = (c0 + c1*s) mod q'
//                     m = round(v/ /\') mod p
//
// Homomorphic properties (all exact in this e=0 demo):
//   add : (c0+c0', c1+c1')          -> decrypts to m + m' mod p
//   sub : (c0-c0', c1-c1')          -> decrypts to m - m' mod p
//   pmul: (w*c0,  w*c1)             -> decrypts to w*m  mod p
//   mod-switch q=2^16 -> q'=2^15 :   c_i' = round(c_i/2)
//                     noise halves; message survives because
//                     /\ = 256 also halves to \' = 128 = q'/p.
//
// Inference (the security-relevant path):
//   acc = Σ_{i<NF} w_i · CT_i  + bias   (accumulated on CIPHERTEXTS)
//   then ONE mod-switch (noise management), then decrypt ONCE.
//   The feature vector is never exposed in cleartext on any internal bus.
//
// e = 0 note: this engine is an architecture demo of the HE datapath
// (encryption, homomorphic ALU, mod-switching, encrypted accumulation).
// Real BGV noise is what mod-switch manages; with e=0 every result is
// exact, which is what makes the FPGA testbench bit-exact against the
// Python golden model. The datapath is unchanged when noise is added.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module he_engine #(
  parameter Q_BITS      = 16,    // q = 2^16
  parameter P_BITS      = 8,     // p = 2^8
  parameter QP_BITS     = 15,    // q' = 2^15 after mod-switch
  parameter NF          = 8      // feature count for inference
)(
  input  wire        clk,
  input  wire        rst_n,

  // ---- register interface (host) -------------------------------------------
  input  wire        reg_wr,            // write pulse
  input  wire [7:0]  reg_waddr,
  input  wire [15:0] reg_wdata,
  input  wire        reg_rd,            // read strobe
  input  wire [7:0]  reg_raddr,
  output reg  [15:0] reg_rdata,

  // ---- command interface ----------------------------------------------------
  input  wire [3:0]  cmd,
  input  wire        cmd_start,
  output reg         cmd_busy,
  output reg         cmd_done,
  output reg         cmd_err            // bad command / encryption overflow
);

  // -------------------------------------------------------------------------
  // Commands
  // -------------------------------------------------------------------------
  localparam [3:0]
    C_NOP   = 4'd0,
    C_KEYGEN= 4'd1,
    C_ENC   = 4'd2,
    C_DEC   = 4'd3,
    C_ADD   = 4'd4,
    C_SUB   = 4'd5,
    C_PMUL  = 4'd6,
    C_MODSW = 4'd7,
    C_INFER = 4'd8;

  // -------------------------------------------------------------------------
  // Register map
  //   0x00..0x0F  CT RAM: 8 ciphertexts x (c0, c1)
  //   0x10..0x17  weight RAM w[0..7]
  //   0x18        bias
  //   0x20        LCG seed (write)
  //   0x21        sk (s)
  //   0x22        pk_a
  //   0x23        pk_b
  //   0x24        scalar m / w / addend input
  //   0x25        result c0
  //   0x26        result c1
  //   0x27        result m
  // -------------------------------------------------------------------------
  localparam [7:0] A_BIAS  = 8'h18;
  localparam [7:0] A_SEED  = 8'h20;
  localparam [7:0] A_SK    = 8'h21;
  localparam [7:0] A_PKA   = 8'h22;
  localparam [7:0] A_PKB   = 8'h23;
  localparam [7:0] A_SCAL  = 8'h24;
  localparam [7:0] A_RC0   = 8'h25;
  localparam [7:0] A_RC1   = 8'h26;
  localparam [7:0] A_RM    = 8'h27;

  reg [15:0] ct_ram [0:2*NF-1];      // 8 cts x 2 words
  reg [15:0] w_ram  [0:NF];          // 8 weights + bias
  reg [15:0] seed_r;
  reg [15:0] sk_r;                   // s in {0,1}
  reg [15:0] pka_r, pkb_r;
  reg [15:0] scal_r;
  reg [15:0] rc0, rc1, rm;

  integer k;

  // -------------------------------------------------------------------------
  // LCG (deterministic, mirrored 1:1 in the Python golden model)
  // -------------------------------------------------------------------------
  reg [31:0] lcg_state;
  reg [15:0] lcg_out;                // most recent draw
  wire [31:0] lcg_next = lcg_state * 32'd1664525 + 32'd1013904223;

  task lcg_draw;
    begin
      lcg_state <= lcg_next;
      lcg_out   <= lcg_next[31:16];
    end
  endtask

  // -------------------------------------------------------------------------
  // Register file access
  // -------------------------------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      seed_r <= 16'd0;
      sk_r   <= 16'd0;
      pka_r  <= 16'd0;
      pkb_r  <= 16'd0;
      scal_r <= 16'd0;
      rc0    <= 16'd0;
      rc1    <= 16'd0;
      rm     <= 16'd0;
      lcg_state <= 32'd0;
      lcg_out   <= 16'd0;
      for (k = 0; k < 2*NF; k = k + 1) ct_ram[k] <= 16'd0;
      for (k = 0; k <= NF; k = k + 1) w_ram[k]  <= 16'd0;
    end else begin
      if (reg_wr) begin
        case (reg_waddr)
          A_SEED: begin seed_r <= reg_wdata; lcg_state <= {reg_wdata, 16'h0000}; end
          A_SCAL: scal_r <= reg_wdata;
          A_RC0:  rc0 <= reg_wdata;
          A_RC1:  rc1 <= reg_wdata;
          default: ;
        endcase
        if (reg_waddr < 2*NF)
          ct_ram[reg_waddr[3:0]] <= reg_wdata;
        else if (reg_waddr >= 8'h10 && reg_waddr <= A_BIAS)
          w_ram[reg_waddr[3:0]] <= reg_wdata;
      end
    end
  end

  always @(*) begin
    reg_rdata = 16'd0;
    case (reg_raddr)
      A_SK:   reg_rdata = sk_r;
      A_PKA:  reg_rdata = pka_r;
      A_PKB:  reg_rdata = pkb_r;
      A_SCAL: reg_rdata = scal_r;
      A_RC0:  reg_rdata = rc0;
      A_RC1:  reg_rdata = rc1;
      A_RM:   reg_rdata = rm;
      default: begin
        if (reg_raddr < 2*NF)
          reg_rdata = ct_ram[reg_raddr[3:0]];
        else if (reg_raddr >= 8'h10 && reg_raddr <= A_BIAS)
          reg_rdata = w_ram[reg_raddr[3:0]];
      end
    endcase
  end

  // -------------------------------------------------------------------------
  // Command FSM
  // -------------------------------------------------------------------------
  reg [3:0]  cstate;
  reg [3:0]  sub;                     // sub-step counter
  reg [15:0] acc0, acc1;              // accumulator ciphertext
  reg        switched;                // 0: q=2^16, 1: q'=2^15

  // decrypt helper: v = (c0 + c1*s) mod 2^QP_BITS; m = round(v/delta') & 0xFF
  //   delta' = q'/p = 2^QP_BITS / 2^P_BITS
  function [15:0] he_dec;
    input [15:0] c0, c1;
    input [15:0] s;
    input        sw;                  // 0: q=2^16,  1: q'=2^15
    reg [15:0] v;
    reg [15:0] delta_half;
    begin
      v = c0 + (s ? c1 : 16'd0);
      if (sw) begin
        // q' = 2^15 : mask to 15 bits, delta' = 128, delta'/2 = 64
        v = v & 16'h7FFF;
        delta_half = 16'd64;
        he_dec = ((v + delta_half) >> 7) & 16'h00FF;
      end else begin
        // q = 2^16 : delta = 256, delta/2 = 128
        delta_half = 16'd128;
        he_dec = ((v + delta_half) >> 8) & 16'h00FF;
      end
    end
  endfunction

  // mod-switch a ciphertext: round(c/2), mask to 15 bits
  function [15:0] he_msw;
    input [15:0] c;
    begin
      he_msw = ((c + 16'd1) >> 1) & 16'h7FFF;
    end
  endfunction

  localparam [3:0]
    S_IDLE   = 4'd0,
    S_RUN    = 4'd1,
    S_STEP   = 4'd2,
    S_FINISH = 4'd3;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cstate    <= S_IDLE;
      cmd_busy  <= 1'b0;
      cmd_done  <= 1'b0;
      cmd_err   <= 1'b0;
      sub       <= 4'd0;
      acc0      <= 16'd0;
      acc1      <= 16'd0;
      switched  <= 1'b0;
      sk_r      <= 16'd0;
      pka_r     <= 16'd0;
      pkb_r     <= 16'd0;
    end else begin
      cmd_done <= 1'b0;
      cmd_err  <= 1'b0;

      case (cstate)
        S_IDLE: begin
          if (cmd_start) begin
            case (cmd)
              C_KEYGEN: begin
                cmd_busy <= 1'b1;
                sub <= 4'd0;
                cstate <= S_RUN;
              end
              C_ENC, C_DEC, C_ADD, C_SUB, C_PMUL, C_MODSW: begin
                cmd_busy <= 1'b1;
                sub <= 4'd0;
                cstate <= S_RUN;
              end
              C_INFER: begin
                cmd_busy <= 1'b1;
                sub <= 4'd0;
                acc0 <= 16'd0;
                acc1 <= 16'd0;
                switched <= 1'b0;
                cstate <= S_RUN;
              end
              default: cmd_err <= 1'b1;
            endcase
          end
        end

        S_RUN: begin
          case (cmd)
            // ---- keygen: 2 LCG draws (a, then s bit) ----------------------
            C_KEYGEN: begin
              case (sub)
                4'd0: begin lcg_draw; sub <= 4'd1; end
                4'd1: begin
                  pka_r <= lcg_out;
                  lcg_draw;
                  sub <= 4'd2;
                end
                4'd2: begin
                  sk_r  <= {15'd0, lcg_out[0]};
                  pkb_r <= lcg_out[0] ? (16'd0 - pka_r) : 16'd0;
                  cstate <= S_FINISH;
                end
                default: cstate <= S_FINISH;
              endcase
            end

            // ---- encrypt scalar -> (rc0, rc1) -------------------------------
            //   c0 = b*r + 256*m ; c1 = a*r       (all mod 2^16, free)
            C_ENC: begin
              // r = LCG bit; one draw
              if (sub == 4'd0) begin
                lcg_draw;
                sub <= 4'd1;
              end else begin
                rc0 <= pkb_r * {15'd0, lcg_out[0]} + (scal_r << 8);
                rc1 <= pka_r * {15'd0, lcg_out[0]};
                cstate <= S_FINISH;
              end
            end

            // ---- decrypt (rc0, rc1) -> rm -----------------------------------
            C_DEC: begin
              rm <= he_dec(rc0, rc1, sk_r, 1'b0);
              cstate <= S_FINISH;
            end

            // ---- add / sub / pmul of CT[0] and CT[1] or CT[0] x ---------
            C_ADD: begin
              rc0 <= ct_ram[0] + ct_ram[1];
              rc1 <= ct_ram[2] + ct_ram[3];
              cstate <= S_FINISH;
            end
            C_SUB: begin
              rc0 <= ct_ram[0] - ct_ram[1];
              rc1 <= ct_ram[2] - ct_ram[3];
              cstate <= S_FINISH;
            end
            C_PMUL: begin
              rc0 <= scal_r * ct_ram[0];
              rc1 <= scal_r * ct_ram[2];
              cstate <= S_FINISH;
            end

            // ---- mod-switch CT[0] --------------------------------------------
            C_MODSW: begin
              rc0 <= he_msw(ct_ram[0]);
              rc1 <= he_msw(ct_ram[2]);
              cstate <= S_FINISH;
            end

            // ---- encrypted inference -----------------------------------------
            // phase 0: acc += w_i * ct_i   (i = sub)
            // phase 1: acc0 += bias
            // phase 2: mod-switch acc
            // phase 3: decrypt -> rm
            C_INFER: begin
              if (sub < NF) begin
                // one feature: two 16x16 muls + adds, single cycle
                acc0 <= acc0 + w_ram[sub] * ct_ram[2*sub];
                acc1 <= acc1 + w_ram[sub] * ct_ram[2*sub + 1];
                sub  <= sub + 4'd1;
              end else if (sub == NF) begin
                // bias must enter in the ENCODED position: /\*bias = bias<<8
                acc0 <= acc0 + (w_ram[NF] << 8);
                sub  <= sub + 4'd1;
              end else if (sub == NF + 4'd1) begin
                // mod-switch
                rc0 <= he_msw(acc0);
                rc1 <= he_msw(acc1);
                switched <= 1'b1;
                sub <= sub + 4'd1;
              end else if (sub == NF + 4'd2) begin
                rm <= he_dec(rc0, rc1, sk_r, 1'b1);
                cstate <= S_FINISH;
              end
            end

            default: cstate <= S_FINISH;
          endcase
        end

        S_FINISH: begin
          cmd_done <= 1'b1;
          cmd_busy <= 1'b0;
          cstate   <= S_IDLE;
        end

        default: cstate <= S_IDLE;
      endcase
    end
  end

endmodule

`default_nettype wire
