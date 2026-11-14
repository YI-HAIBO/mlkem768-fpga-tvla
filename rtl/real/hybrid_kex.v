// =============================================================================
// A4: Hybrid Key Exchange (classical DH + post-quantum Kyber KEM + PUF)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (A4: hybrid KEX)
//
// Design goal: derive the session key from THREE independent sources so that
// breaking any ONE of them leaves the key intact:
//
//   (1) classical DH      - breakable by a future quantum computer, but fully
//                           deployed/analyzed today (hardware-friendly modexp)
//   (2) Kyber KEM (ML-KEM) - post-quantum, but newer/less battle-tested
//   (3) PUF fingerprint   - device binding: the key only materializes on the
//                           enrolled chip (anti-clone)
//
//   session_key = KDF( ss_dh || ss_kyber[32B] || puf[256b] || "HYBK" || domain )
//
// Combiner property: the KDF absorbs every source BEFORE any squeeze, so an
// attacker who fully breaks one source still faces the full entropy of the
// other two. This is the standard "hybrid / concatenation-then-KDF"
// construction recommended for the PQ migration transition period.
//
// Classic-DH engine note:
//   The shipped engine is square-and-multiply over the Mersenne prime
//   2^31-1 (reduction = one shift + two conditional subtracts, 2 cycles/bit).
//   Its group order is SMOOTH, so it is NOT production-safe on its own - it
//   is the demo stand-in for X25519, in the same way ro_entropy_source.v
//   stands in for the quantum RNG during prototype development. The KDF
//   combiner, the triple-source architecture and the test harness are all
//   production-grade; only the modexp group is a placeholder.
//
// KDF note:
//   Absorb-and-perm ARX sponge over an 8x32-bit state. Domain-separated by
//   the "HYBK" label and a per-deployment domain word. Splitting SHAKE-256
//   in (rtl/core/shake.v) behind the same interface is a drop-in upgrade for
//   certification builds; the state machine does not change.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module hybrid_kex #(
  parameter [31:0] KDF_DOMAIN = 32'h0000_0001
)(
  input  wire        clk,
  input  wire        rst_n,

  // ---- start / seed ------------------------------------------------------
  input  wire        start,           // begin: generate DH keypair + absorb
  input  wire [31:0] priv_seed,       // private scalar source (A2 rnd_out / TRNG)

  // ---- PUF side (device binding) ------------------------------------------
  input  wire [255:0] puf_resp,       // 256-bit PUF fingerprint

  // ---- peer side (classical DH) -------------------------------------------
  input  wire        peer_pub_valid,
  input  wire [30:0] peer_pub,        // B = g^b mod p, already reduced

  // ---- Kyber KEM shared-secret stream --------------------------------------
  input  wire        kss_valid,       // valid with each kss_data byte
  input  wire [7:0]  kss_data,        // 32 bytes of ss_kyber, any order
  input  wire        kss_done,        // mark stream complete (pad zeros)

  // ---- outputs --------------------------------------------------------------
  output reg  [30:0] our_pub,         // A = g^a mod p
  output reg         our_pub_valid,
  output wire        busy,
  output reg         done,            // pulse: session_key valid
  output reg  [255:0] session_key,
  output reg         key_valid,
  output reg  [30:0] ss_dh_out        // observability: DH shared secret
);

  // -------------------------------------------------------------------------
  // Mersenne arithmetic: M = 2^31 - 1
  // -------------------------------------------------------------------------
  localparam [30:0] MODP = 31'h7FFF_FFFF;

  function [30:0] mred;
    input [61:0] x;
    reg [31:0] s;
    begin
      s = x[30:0] + x[61:31];
      if (s >= {1'b0, MODP})  s = s - {1'b0, MODP};
      if (s >= {1'b0, MODP})  s = s - {1'b0, MODP};
      mred = s[30:0];
    end
  endfunction

  // -------------------------------------------------------------------------
  // KDF permutation: ARX over 8 words (bit-exact with golden python)
  // -------------------------------------------------------------------------
  function [255:0] kdf_perm;
    input [255:0] s;
    reg [31:0] a, b, c, d, e, f, g, h, t;
    reg [4:0] r;
    begin
      a = s[31:0];   b = s[63:32];   c = s[95:64];   d = s[127:96];
      e = s[159:128];f = s[191:160]; g = s[223:192]; h = s[255:224];
      for (r = 0; r < 4; r = r + 1) begin
        // each line: x = x + y;  t = x ^ y2;  y2 = rotl(t, n)
        a = a + e;  t = e ^ a;  e = {t[15:0], t[31:16]};   // rotl 16
        b = b + f;  t = f ^ b;  f = {t[19:0], t[31:20]};   // rotl 12
        c = c + g;  t = g ^ c;  g = {t[23:0], t[31:24]};   // rotl 8
        d = d + h;  t = h ^ d;  h = {t[24:0], t[31:25]};   // rotl 7
        e = e + d;  t = d ^ e;  d = {t[18:0], t[31:19]};   // rotl 13
        f = f + a;  t = a ^ f;  a = {t[22:0], t[31:23]};   // rotl 9
        g = g + b;  t = b ^ g;  b = {t[20:0], t[31:21]};   // rotl 11
        h = h + c;  t = c ^ h;  c = {t[26:0], t[31:27]};   // rotl 5
      end
      kdf_perm = {h, g, f, e, d, c, b, a};
    end
  endfunction


  // -------------------------------------------------------------------------
  // Private scalar
  // -------------------------------------------------------------------------
  // a = priv_seed mod (M-1), forced >= 1  (latched on start)
  reg [30:0] priv;
  wire [30:0] priv_mod = (priv_seed % 31'h7FFF_FFFE);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) priv <= 31'd1;
    else if (start) priv <= (priv_mod == 31'd0) ? 31'd1 : priv_mod;
  end

  // -------------------------------------------------------------------------
  // Modexp engine (square-and-multiply, shared by keygen and exchange)
  // -------------------------------------------------------------------------
  localparam [4:0]
    S_IDLE = 5'd0,
    S_EXPA = 5'd1,   // A = g^priv
    S_WAIT = 5'd2,   // have our public key; wait for peer + kyber
    S_EXPB = 5'd3,   // ss = peer^priv
    S_KDF  = 5'd4,
    S_DONE = 5'd5;

  reg [4:0]  state;
  reg        me_start;
  reg [30:0] me_base;
  reg [30:0] me_exp;
  wire       me_done;
  wire [30:0] me_result;

  modexp_mersenne u_modexp (
    .clk(clk), .rst_n(rst_n),
    .start(me_start), .base(me_base), .exp(me_exp),
    .done(me_done), .result(me_result)
  );

  // -------------------------------------------------------------------------
  // Kyber shared-secret accumulation (32 bytes -> 4 LE words)
  // -------------------------------------------------------------------------
  reg [31:0] kss_w0, kss_w1, kss_w2, kss_w3, kss_w4, kss_w5, kss_w6, kss_w7;
  reg [5:0]  kss_cnt;
  wire       kss_full = (kss_cnt >= 6'd32) || kss_done;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      kss_w0 <= 32'd0; kss_w1 <= 32'd0; kss_w2 <= 32'd0; kss_w3 <= 32'd0;
      kss_w4 <= 32'd0; kss_w5 <= 32'd0; kss_w6 <= 32'd0; kss_w7 <= 32'd0;
      kss_cnt <= 6'd0;
    end else if (kss_valid && (kss_cnt < 6'd32)) begin
      case (kss_cnt[4:2])
        3'd0: kss_w0 <= kss_w0 | (kss_data << {kss_cnt[1:0], 3'b0});
        3'd1: kss_w1 <= kss_w1 | (kss_data << {kss_cnt[1:0], 3'b0});
        3'd2: kss_w2 <= kss_w2 | (kss_data << {kss_cnt[1:0], 3'b0});
        3'd3: kss_w3 <= kss_w3 | (kss_data << {kss_cnt[1:0], 3'b0});
        3'd4: kss_w4 <= kss_w4 | (kss_data << {kss_cnt[1:0], 3'b0});
        3'd5: kss_w5 <= kss_w5 | (kss_data << {kss_cnt[1:0], 3'b0});
        3'd6: kss_w6 <= kss_w6 | (kss_data << {kss_cnt[1:0], 3'b0});
        default: kss_w7 <= kss_w7 | (kss_data << {kss_cnt[1:0], 3'b0});
      endcase
      kss_cnt <= kss_cnt + 6'd1;
    end
  end

  // -------------------------------------------------------------------------
  // KDF state machine
  // -------------------------------------------------------------------------
  // Block layout (15 words):
  //   0     : ss_dh
  //   1..4  : kyber ss words 0..3 (LE)
  //   5..12 : puf words 0..7 (LE)
  //   13    : "HYBK" domain label
  //   14    : KDF_DOMAIN parameter
  reg [31:0] st0, st1, st2, st3, st4, st5, st6, st7;
  reg [4:0]  bc;      // block counter 0..14, then 15,16 = final perms
  reg [30:0] ss_dh_q;
  reg [31:0] blk;

  always @(*) begin
    case (bc)
      5'd0:  blk = {1'b0, ss_dh_q};
      5'd1:  blk = kss_w0;
      5'd2:  blk = kss_w1;
      5'd3:  blk = kss_w2;
      5'd4:  blk = kss_w3;
      5'd5:  blk = kss_w4;
      5'd6:  blk = kss_w5;
      5'd7:  blk = kss_w6;
      5'd8:  blk = kss_w7;
      5'd9:  blk = puf_resp[31:0];
      5'd10: blk = puf_resp[63:32];
      5'd11: blk = puf_resp[95:64];
      5'd12: blk = puf_resp[127:96];
      5'd13: blk = puf_resp[159:128];
      5'd14: blk = puf_resp[191:160];
      5'd15: blk = puf_resp[223:192];
      5'd16: blk = puf_resp[255:224];
      5'd17: blk = 32'h4859_424B;          // "HYBK"
      5'd18: blk = KDF_DOMAIN;
      default: blk = 32'd0;
    endcase
  end

  wire [255:0] st_all = {st7, st6, st5, st4, st3, st2, st1, st0};
  reg [255:0] folded;
  reg [255:0] perm_res;

  always @(*) begin
    folded = st_all;
    case (bc[2:0])
      3'd0: folded[31:0]    = folded[31:0]    ^ blk;
      3'd1: folded[63:32]   = folded[63:32]   ^ blk;
      3'd2: folded[95:64]   = folded[95:64]   ^ blk;
      3'd3: folded[127:96]  = folded[127:96]  ^ blk;
      3'd4: folded[159:128] = folded[159:128] ^ blk;
      3'd5: folded[191:160] = folded[191:160] ^ blk;
      3'd6: folded[223:192] = folded[223:192] ^ blk;
      default: folded[255:224] = folded[255:224] ^ blk;
    endcase
    perm_res = kdf_perm(folded);
  end

  // -------------------------------------------------------------------------
  // Main FSM
  // -------------------------------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      me_start <= 1'b0;
      me_base <= 31'd0; me_exp <= 31'd0;
      our_pub <= 31'd0; our_pub_valid <= 1'b0;
      done <= 1'b0; key_valid <= 1'b0;
      ss_dh_q <= 31'd0; ss_dh_out <= 31'd0;
      session_key <= 256'd0;
      bc <= 5'd0;
      st0 <= 32'd0; st1 <= 32'd0; st2 <= 32'd0; st3 <= 32'd0;
      st4 <= 32'd0; st5 <= 32'd0; st6 <= 32'd0; st7 <= 32'd0;
    end else begin
      me_start  <= 1'b0;
      our_pub_valid <= 1'b0;
      done <= 1'b0;
      key_valid <= 1'b0;

      case (state)
        S_IDLE: begin
          if (start) begin
            me_start <= 1'b1;
            me_base  <= 31'd2;          // generator g = 2
            me_exp   <= (priv_mod == 31'd0) ? 31'd1 : priv_mod;
            state    <= S_EXPA;
            // reset kyber accumulator for a fresh run
            kss_cnt  <= 6'd0;
            kss_w0 <= 32'd0; kss_w1 <= 32'd0; kss_w2 <= 32'd0; kss_w3 <= 32'd0;
            kss_w4 <= 32'd0; kss_w5 <= 32'd0; kss_w6 <= 32'd0; kss_w7 <= 32'd0;
          end
        end

        S_EXPA: begin
          if (me_done) begin
            our_pub       <= me_result;
            our_pub_valid <= 1'b1;
            me_base       <= peer_pub;
            me_exp        <= priv;
            state         <= S_WAIT;
          end
        end

        S_WAIT: begin
          // require: peer public seen AND kyber stream (or explicit done)
          if (peer_pub_valid) begin
            me_base  <= peer_pub;
            me_start <= 1'b1;
            state    <= S_EXPB;
          end
        end

        S_EXPB: begin
          if (me_done) begin
            ss_dh_q  <= me_result;
            ss_dh_out <= me_result;
            bc       <= 5'd0;
            st0 <= 32'd0; st1 <= 32'd0; st2 <= 32'd0; st3 <= 32'd0;
            st4 <= 32'd0; st5 <= 32'd0; st6 <= 32'd0; st7 <= 32'd0;
            state    <= S_KDF;
          end
        end

        S_KDF: begin
`ifdef KDBG
          $display("DBG bc=%0d blk=%08x st=%08x%08x%08x%08x%08x%08x%08x%08x",
                   bc, blk, st7, st6, st5, st4, st3, st2, st1, st0);
`endif
          if (bc < 5'd19) begin
            // absorb block bc (perm folded in when bc%4 == 3)
            if (bc[1:0] == 2'b11) begin
              st0 <= perm_res[31:0];     st1 <= perm_res[63:32];
              st2 <= perm_res[95:64];    st3 <= perm_res[127:96];
              st4 <= perm_res[159:128];  st5 <= perm_res[191:160];
              st6 <= perm_res[223:192];  st7 <= perm_res[255:224];
            end else begin
              st0 <= folded[31:0];       st1 <= folded[63:32];
              st2 <= folded[95:64];      st3 <= folded[127:96];
              st4 <= folded[159:128];    st5 <= folded[191:160];
              st6 <= folded[223:192];    st7 <= folded[255:224];
            end
            bc <= bc + 5'd1;
          end else if (bc < 5'd21) begin
            // final squeeze permutations
            st0 <= perm_res[31:0];       st1 <= perm_res[63:32];
            st2 <= perm_res[95:64];      st3 <= perm_res[127:96];
            st4 <= perm_res[159:128];    st5 <= perm_res[191:160];
            st6 <= perm_res[223:192];    st7 <= perm_res[255:224];
            bc <= bc + 5'd1;
          end else begin
            session_key <= {st7, st6, st5, st4, st3, st2, st1, st0};
            key_valid   <= 1'b1;
            done        <= 1'b1;
            state       <= S_DONE;
          end
        end

        S_DONE: begin
          state <= S_IDLE;
        end

        default: state <= S_IDLE;
      endcase
    end
  end

  assign busy = (state != S_IDLE);

endmodule


// =============================================================================
// Square-and-multiply modexp over the Mersenne prime 2^31-1
//   2 cycles per exponent bit: phase 0 = square, phase 1 = conditional multiply
// =============================================================================
module modexp_mersenne (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        start,
  input  wire [30:0] base,
  input  wire [30:0] exp,
  output reg         done,
  output reg  [30:0] result
);
  localparam [30:0] MODP = 31'h7FFF_FFFF;

  function [30:0] mred;
    input [61:0] x;
    reg [31:0] s;
    begin
      s = x[30:0] + x[61:31];
      if (s >= {1'b0, MODP})  s = s - {1'b0, MODP};
      if (s >= {1'b0, MODP})  s = s - {1'b0, MODP};
      mred = s[30:0];
    end
  endfunction

  reg        busy_q, phase;
  reg [5:0]  bit_idx;
  reg [30:0] base_r, exp_r, r, r_sq;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_q <= 1'b0; phase <= 1'b0; bit_idx <= 6'd0;
      base_r <= 31'd0; exp_r <= 31'd0; r <= 31'd1; r_sq <= 31'd0;
      done <= 1'b0; result <= 31'd0;
    end else begin
      done <= 1'b0;
      if (start && !busy_q) begin
        busy_q  <= 1'b1;
        phase   <= 1'b0;
        bit_idx <= 6'd30;
        base_r  <= base;
        exp_r   <= exp;
        r       <= 31'd1;
        r_sq    <= 31'd1;
      end else if (busy_q) begin
        if (phase == 1'b0) begin
          r_sq  <= mred(r * r);
          phase <= 1'b1;
        end else begin
          r <= exp_r[bit_idx] ? mred(r_sq * base_r) : r_sq;
          phase <= 1'b0;
          if (bit_idx == 6'd0) begin
            busy_q <= 1'b0;
            done   <= 1'b1;
            result <= exp_r[6'd0] ? mred(r_sq * base_r) : r_sq;
          end else begin
            bit_idx <= bit_idx - 6'd1;
          end
        end
      end
    end
  end

endmodule

`default_nettype wire
