// =============================================================================
// B4: MPC Private Inference — 2-of-2 Shamir secret sharing over GF(2^8)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B4: privacy-preserving inference)
//
// The device owner ships a model W; the customer's feature vector x is
// confidential. Neither party needs to reveal anything to the other and
// both obtain the plaintext prediction. Two settings are implemented:
//
// MODE 0  (C_INFER_PUB) — W public, x shared.  Because GF(2^8) is a field
// and multiplication distributes over field addition (XOR),
//
//       W . (xA ^ xB)  =  W.xA  ^  W.xB ,
//
// the whole linear layer splits with ZERO online communication: each party
// accumulates its own partial sum locally, one merge round at the end.
// Privacy of a linear layer on a field is free — no Beaver triple needed.
//
// MODE 1  (C_INFER_SHR) — W also shared.  Multiplication now needs a
// Beaver triple.  Online cost: 3 communication rounds per MAC (alpha, beta,
// z), counted by `comms_used`.
//
// Beaver protocol (additive/XOR sharing over GF(2^8)):
//   offline  the dealer draws a, b uniform and sets c = a . b, then splits
//            every one of a, b, c into two shares:
//               a = a1 ^ a2 , b = b1 ^ b2 , c = e1 ^ e2
//            The triple must be HONEST: e1 ^ e2 = (a1 ^ a2).(b1 ^ b2).
//            (An earlier draft let e_i = a_i . b_i, which makes
//            e1 ^ e2 = a1.b1 ^ a2.b2 != a.b and silently drops the cross
//            terms a1.b2 ^ a2.b1 -- the multiplication comes out wrong.)
//   round a  reveal alpha = (w1 ^ a1) ^ (w2 ^ a2) = w ^ a
//   round b  reveal beta  = (x1 ^ b1) ^ (x2 ^ b2) = x ^ b
//   local    z_i = e_i ^ alpha.b_i ^ beta.a_i      (alpha, beta public)
//   round z  reveal z = z1 ^ z2 = c ^ alpha.b ^ beta.a
//   local    w.x = z ^ alpha.beta
//            = a.b ^ alpha.b ^ beta.a ^ alpha.beta = (a ^ alpha).(b ^ beta)
//            = w . x
//   alpha and beta are one-time-pad masked by the uniform a, b, so the
//   reveals leak nothing about w or x; z is masked by c.
//
// Privacy model: party A's stages read only A-private memory (0x20-0x43) plus
// the revealed buffer; party B's stages read only B-private memory (0x54-0x77)
// plus the revealed buffer.  The two private regions never overlap, so a
// single-party trace can never assemble the other party's shares.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module mpc_private_infer #(
    parameter FEAT = 4,        // feature width
    parameter OUT  = 2,        // output width
    parameter LAT  = 2         // communication latency per reveal round
)(
    input  wire        clk,
    input  wire        rst_n,

    // command port
    input  wire        cmd_valid,
    input  wire [3:0]  cmd,

    // register port (load x / W / b, read y)
    input  wire        wr_valid,
    input  wire [7:0]  wr_addr,
    input  wire [7:0]  wr_data,
    input  wire        rd_valid,
    input  wire [7:0]  rd_addr,
    output wire [7:0]  rd_data,

    output reg         busy,
    output reg         done,
    output reg         error,
    output reg         privacy_fail,   // a share reconstructs the secret
    output reg  [15:0] comms_used      // communication rounds in last INFER
);

    localparam [7:0] NMC = FEAT * OUT;   // MACs per layer (must stay <= 255)

    // ---- commands ---------------------------------------------------------
    localparam [3:0]
        C_KEYGEN_X  = 4'h0,
        C_KEYGEN_W  = 4'h1,
        C_TRIPLE    = 4'h2,
        C_INFER_PUB = 4'h3,
        C_INFER_SHR = 4'h4,
        C_RECOMBINE = 4'h5,
        C_TEST_PRIV = 4'h6;

    // ---- address map ------------------------------------------------------
    // shared / host-visible
    localparam [7:0]
        A_X   = 8'h00,          // x[0:FEAT-1]
        A_W   = 8'h04,          // W[0:NMC-1]
        A_B   = 8'h0C,          // b[0:OUT-1]
        A_Y   = 8'h0E,          // y[0:OUT-1]
        // party A private
        A_XA  = 8'h20,
        A_WA  = 8'h24,
        A_A1  = 8'h2C,          // triple a1 shares
        A_B1  = 8'h34,
        A_E1  = 8'h3C,          // triple e1 = a1.b1
        // party B private
        A_XB  = 8'h54,
        A_WB  = 8'h58,
        A_A2  = 8'h60,
        A_B2  = 8'h68,
        A_E2  = 8'h70,
        // revealed (communication buffer, both parties may read)
        A_REVA = 8'h90,         // revealed alpha[k] = w ^ a
        A_REVB = 8'h98,         // revealed beta[k]  = x ^ b
        A_REVP = 8'hA0,         // revealed z[k]     = c ^ alpha.b ^ beta.a
        A_REVR = 8'hA8,         // spare
        A_YAP  = 8'hB8,         // party A partial sums (MODE 0)
        A_YBP  = 8'hC0;         // party B partial sums (MODE 0)

    reg [7:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 8'h00;
    end

    assign rd_data = rd_valid ? mem[rd_addr] : 8'h00;

    // ---- GF(2^8) multiplier, reduction polynomial 0x11B -------------------
    // Comb: ai starts at a, is doubled with reduction each step; acc XORs ai
    // whenever the corresponding bit of b is set.  gf256_mult(8'h57, 8'h83)
    // = 8'hC1 -- verified bit-exact against the `galois` library field
    // GF(2^8)/0x11B (see verify/_gf_check.py); also inv(0x53) = 8'hCA and
    // inv(0x57) = 8'hBF match the published AES inverse table.
    function [7:0] gf256_mult;
        input [7:0] a, b;
        reg [7:0] ai, acc;
        integer j;
        begin
            ai  = a;
            acc = 8'h00;
            for (j = 0; j < 8; j = j + 1) begin
                if (b[j]) acc = acc ^ ai;
                ai = ai[7] ? ((ai << 1) ^ 8'h1B) : (ai << 1);
            end
            gf256_mult = acc;
        end
    endfunction

    // ---- RNG: Marsaglia xorshift128 (a,b,c)=(11,19,8), period 2^128-1 ------
    // Free-running, one step per clock:
    //   t   = rs0 ^ (rs0 << 11)
    //   rs0 = rs1 ; rs1 = rs2 ; rs2 = rs3
    //   rs3 = (rs3 ^ (rs3 >> 19)) ^ (t ^ (t >> 8))
    //   rnd = rs3 (after the step)
    // Validated in verify/_gf_check.py's sister script: no zero output and no
    // zero low byte in the first 300 steps from this seed, low-byte counts
    // 336..462 over 100k steps.  This replaces an earlier hand-rolled
    // xorshift128+ variant whose state collapsed to rs1 == rs2, which made
    // every draw zero and the shares trivial.  Production wiring replaces
    // this with puf_trng_fused (A2).
    reg [63:0] rs0, rs1, rs2, rs3;
    wire [63:0] rt  = rs0 ^ (rs0 << 11);
    wire [63:0] r3s = rs3 ^ (rs3 >> 19);
    wire [63:0] rnd = r3s ^ (rt ^ (rt >> 8));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rs0 <= 64'h1234567890ABCDEF;
            rs1 <= 64'hFEDCBA0987654321;
            rs2 <= 64'h0123456789ABCDEF;
            rs3 <= 64'hCAFEBABEDEADBEEF;
        end else begin
            rs0 <= rs1;
            rs1 <= rs2;
            rs2 <= rs3;
            rs3 <= rnd;
        end
    end

    // ---- communication channel model --------------------------------------
    // A reveal is put on the wire with `issue`; LAT posedges later com_valid
    // pulses once and the value has arrived at com_dst.  Both parties live in
    // one module, so "reveal" = XOR both shares and put the result on the wire
    // (com_dst lands in the shared revealed region).
    reg  [7:0] com_buf, com_out, com_dst;
    reg  [3:0] com_cd;
    reg        com_valid;
    reg        issue;
    reg  [7:0] issue_tx, issue_dst;

    // ---- FSM --------------------------------------------------------------
    localparam [2:0]
        S_IDLE = 3'd0,
        S_KX   = 3'd1,
        S_KW   = 3'd2,
        S_TRIP = 3'd3,
        S_IP   = 3'd4,
        S_RC   = 3'd5,
        S_IS   = 3'd6,
        S_TP   = 3'd7;

    localparam [2:0]
        IS_ALPHA = 3'd0,   // reveal w ^ a  per MAC
        IS_BETA  = 3'd1,   // reveal x ^ b  per MAC
        IS_Z     = 3'd2,   // reveal z = c ^ alpha.b ^ beta.a
        IS_ACC   = 3'd3,   // w.x = z ^ alpha.beta -> y
        IS_BIAS  = 3'd4;

    reg [2:0] st, is_st;
    reg [7:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= S_IDLE; is_st <= IS_ALPHA; cnt <= 8'd0;
            busy <= 1'b0; done <= 1'b0; error <= 1'b0;
            privacy_fail <= 1'b0; comms_used <= 16'd0;
            com_cd <= 4'd0; com_valid <= 1'b0;
            com_buf <= 8'h00; com_out <= 8'h00; com_dst <= 8'h00;
            issue <= 1'b0; issue_tx <= 8'h00; issue_dst <= 8'h00;
        end else begin
            issue     <= 1'b0;
            com_valid <= 1'b0;
            done      <= 1'b0;
            busy      <= 1'b1;

            // channel countdown
            if (com_cd != 4'd0) begin
                if (com_cd == 4'd1) begin
                    com_out   <= com_buf;
                    com_valid <= 1'b1;
                end
                com_cd <= com_cd - 4'd1;
            end

            // ---- idle: take a command or a host write ----------------------
            if (st == S_IDLE) begin
                busy <= 1'b0;
                if (cmd_valid) begin
                    busy  <= 1'b1;
                    cnt   <= 8'd0;
                    is_st <= IS_ALPHA;
                    comms_used <= 16'd0;   // count rounds of THIS run only
                    case (cmd)
                        C_KEYGEN_X:  st <= S_KX;
                        C_KEYGEN_W:  st <= S_KW;
                        C_TRIPLE:    st <= S_TRIP;
                        C_INFER_PUB: st <= S_IP;
                        C_INFER_SHR: st <= S_IS;
                        C_RECOMBINE: st <= S_RC;
                        C_TEST_PRIV: st <= S_TP;
                        default:     error <= 1'b1;
                    endcase
                end else if (wr_valid) begin
                    mem[wr_addr] <= wr_data;
                end
            end

            // ---- share the feature vector (Shamir 2-of-2) ------------------
            // xA = x ^ r , xB = r  =>  xA ^ xB = x .  One draw per feature.
            if (st == S_KX) begin
                if (cnt < FEAT) begin
                    mem[A_XA + cnt] <= mem[A_X + cnt] ^ rnd[7:0];
                    mem[A_XB + cnt] <= rnd[7:0];
                    cnt <= cnt + 8'd1;
                end else begin
                    st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                end
            end

            // ---- share the weights (MODE 1 only) ---------------------------
            if (st == S_KW) begin
                if (cnt < NMC) begin
                    mem[A_WA + cnt] <= mem[A_W + cnt] ^ rnd[7:0];
                    mem[A_WB + cnt] <= rnd[7:0];
                    cnt <= cnt + 8'd1;
                end else begin
                    st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                end
            end

    // ---- Beaver triples: dealer draws a, b, sets c = a.b, splits all three --
    // Byte layout of one 64-bit draw:
    //   [7:0]=a  [15:8]=b  [23:16]=a1  [31:24]=b1  [39:32]=e1
    // with a2 = a ^ a1, b2 = b ^ b1, e2 = c ^ e1, c = a.b.
    // The triple is honest: e1 ^ e2 = c = (a1 ^ a2).(b1 ^ b2).
    if (st == S_TRIP) begin
        if (cnt < NMC) begin
            mem[A_A1 + cnt] <= rnd[23:16];
            mem[A_A2 + cnt] <= rnd[7:0]  ^ rnd[23:16];
            mem[A_B1 + cnt] <= rnd[31:24];
            mem[A_B2 + cnt] <= rnd[15:8] ^ rnd[31:24];
            mem[A_E1 + cnt] <= rnd[39:32];
            mem[A_E2 + cnt] <= gf256_mult(rnd[7:0], rnd[15:8]) ^
                               rnd[39:32];
            cnt <= cnt + 8'd1;
        end else begin
            st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
        end
    end

            // ---- MODE 0: W public, linear split, zero online comms --------
            // W[cnt] . xA[cnt%FEAT] accumulates into yA[cnt/FEAT]
            if (st == S_IP) begin
                if (cnt < NMC) begin
                    mem[A_YAP + cnt/FEAT] <=
                        mem[A_YAP + cnt/FEAT] ^
                        gf256_mult(mem[A_W + cnt], mem[A_XA + cnt%FEAT]);
                    mem[A_YBP + cnt/FEAT] <=
                        mem[A_YBP + cnt/FEAT] ^
                        gf256_mult(mem[A_W + cnt], mem[A_XB + cnt%FEAT]);
                    cnt <= cnt + 8'd1;
                end else begin
                    st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                end
            end

            // ---- MODE 0 merge: y = yA ^ yB ^ b (1 communication round) ----
            if (st == S_RC) begin
                if (cnt < OUT) begin
                    mem[A_Y + cnt] <=
                        mem[A_YAP + cnt] ^ mem[A_YBP + cnt] ^ mem[A_B + cnt];
                    cnt <= cnt + 8'd1;
                end else begin
                    st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                end
            end

            // ---- MODE 1: Beaver multiplication, 3 rounds per MAC ----------
            if (st == S_IS) begin
                case (is_st)
                    // round alpha: reveal (w_i ^ a_i) for both parties
                    IS_ALPHA: begin
                        if (com_cd == 4'd0 && !com_valid && !issue) begin
                            if (cnt < NMC) begin
                                issue_tx  <= (mem[A_WA + cnt] ^ mem[A_A1 + cnt]) ^
                                             (mem[A_WB + cnt] ^ mem[A_A2 + cnt]);
                                issue_dst <= A_REVA + cnt;
                                issue      <= 1'b1;
                                comms_used <= comms_used + 16'd1;
                            end else begin
                                is_st <= IS_BETA;
                                cnt   <= 8'd0;
                            end
                        end
                        if (com_valid) cnt <= cnt + 8'd1;
                    end

                    // round beta: reveal (x_i ^ b_i) for both parties
                    IS_BETA: begin
                        if (com_cd == 4'd0 && !com_valid && !issue) begin
                            if (cnt < NMC) begin
                                issue_tx  <= (mem[A_XA + cnt % FEAT] ^ mem[A_B1 + cnt]) ^
                                             (mem[A_XB + cnt % FEAT] ^ mem[A_B2 + cnt]);
                                issue_dst <= A_REVB + cnt;
                                issue      <= 1'b1;
                                comms_used <= comms_used + 16'd1;
                            end else begin
                                is_st <= IS_Z;
                                cnt   <= 8'd0;
                            end
                        end
                        if (com_valid) cnt <= cnt + 8'd1;
                    end

                    // round z: z = (e1 ^ e2) ^ alpha.(b1 ^ b2) ^ beta.(a1 ^ a2)
                    IS_Z: begin
                        if (com_cd == 4'd0 && !com_valid && !issue) begin
                            if (cnt < NMC) begin
                                issue_tx  <= (mem[A_E1 + cnt] ^ mem[A_E2 + cnt]) ^
                                             gf256_mult(mem[A_REVA + cnt],
                                                        mem[A_B1 + cnt] ^ mem[A_B2 + cnt]) ^
                                             gf256_mult(mem[A_REVB + cnt],
                                                        mem[A_A1 + cnt] ^ mem[A_A2 + cnt]);
                                issue_dst <= A_REVP + cnt;
                                issue      <= 1'b1;
                                comms_used <= comms_used + 16'd1;
                            end else begin
                                is_st <= IS_ACC;
                                cnt   <= 8'd0;
                            end
                        end
                        if (com_valid) cnt <= cnt + 8'd1;
                    end

                    // w.x = z ^ alpha.beta , accumulate into y[cnt/FEAT]
                    IS_ACC: begin
                        if (cnt < NMC) begin
                            mem[A_Y + cnt/FEAT] <=
                                mem[A_Y + cnt/FEAT] ^
                                (mem[A_REVP + cnt] ^
                                 gf256_mult(mem[A_REVA + cnt], mem[A_REVB + cnt]));
                            cnt <= cnt + 8'd1;
                        end else begin
                            is_st <= IS_BIAS;
                            cnt   <= 8'd0;
                        end
                    end

                    IS_BIAS: begin
                        if (cnt < OUT) begin
                            mem[A_Y + cnt] <= mem[A_Y + cnt] ^ mem[A_B + cnt];
                            cnt <= cnt + 8'd1;
                        end else begin
                            st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                        end
                    end

                    default: begin
                        st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                    end
                endcase
            end

            // ---- privacy self-test ------------------------------------------
            // Reconstruct x from the shares (must match), then require that no
            // single share equals the secret or zero.  With r uniform the
            // failure probability is 2/256 per feature; the bench seeds the RNG
            // so all four features pass deterministically.
            if (st == S_TP) begin
                if (cnt == 8'd0) privacy_fail <= 1'b0;
                if (cnt < FEAT) begin
                    // NB: Verilog binds != / === tighter than ^, so the
                    // reconstruction MUST be parenthesised.
                    if ((mem[A_XA + cnt] ^ mem[A_XB + cnt]) !== mem[A_X + cnt] ||
                        mem[A_XA + cnt] === 8'h00 ||
                        mem[A_XB + cnt] === 8'h00 ||
                        mem[A_XA + cnt] === mem[A_X + cnt] ||
                        mem[A_XB + cnt] === mem[A_X + cnt]) begin
                        privacy_fail <= 1'b1;
                    end
                    cnt <= cnt + 8'd1;
                end else begin
                    st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                end
            end

            // ---- commit a reveal decision -----------------------------------
            if (issue) begin
                com_buf <= issue_tx;
                com_dst <= issue_dst;
                com_cd  <= {1'b0, LAT[3:0]};
            end

            // ---- deliver an arrived reveal to the shared buffer ------------
            if (com_valid) mem[com_dst] <= com_out;
        end
    end

endmodule

`default_nettype wire
