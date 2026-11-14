// =============================================================================
// TB for B4 mpc_private_infer.v (2-of-2 additive sharing + Beaver, GF(2^8))
// -----------------------------------------------------------------------------
// Golden: verify/mpc_private_infer_golden.py (41 scenarios, ALL PASS), whose
// gf() is cross-checked bit-exact against the galois library field
// GF(2^8)/0x11B on all 65536 pairs.  Reference vector: 0x57 * 0x83 = 0xC1.
//
//   T0  bad command latches error
//   T1  gf256 comb: 0x57 * 0x83 = 0xC1
//   T2  C_TRIPLE produces HONEST triples: e1^e2 == (a1^a2).(b1^b2) for all 8
//   T3  C_KEYGEN_X: xa ^ xb == x for all 4 features, and no share is 0
//   T4  C_KEYGEN_W: wa ^ wb == w for all 8 weights
//   T5  C_TEST_PRIV clean on the real RNG draw
//   T6  MODE 0 (W public): y == 0x33, 0x95 (golden-computed)
//   T7  MODE 1 (Beaver, W shared): y == 0x33, 0x95, comms_used == 3*8 = 24
//   T8  busy is asserted for the whole INFER_PUB run
//   T9  C_TEST_PRIV catches a forged share equal to the secret
//
// Iron rule: every DUT input is driven on the negedge, one-cycle pulses are
// sampled on the negedge after the posedge that set them.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_mpc_private_infer;

  localparam FEAT = 4;
  localparam OUT  = 2;
  localparam NMC  = FEAT * OUT;       // 8

  // ---- address map (mirrors the RTL localparams) ---------------------------
  localparam [7:0]
    A_X = 8'h00, A_W = 8'h04, A_B = 8'h0C, A_Y = 8'h0E,
    A_XA = 8'h20, A_WA = 8'h24, A_A1 = 8'h2C, A_B1 = 8'h34, A_E1 = 8'h3C,
    A_XB = 8'h54, A_WB = 8'h58, A_A2 = 8'h60, A_B2 = 8'h68, A_E2 = 8'h70,
    A_REVA = 8'h90, A_REVB = 8'h98, A_REVP = 8'hA0,
    A_YAP = 8'hB8, A_YBP = 8'hC0;

  localparam [3:0]
    C_KEYGEN_X = 4'h0, C_KEYGEN_W = 4'h1, C_TRIPLE = 4'h2,
    C_INFER_PUB = 4'h3, C_INFER_SHR = 4'h4, C_RECOMBINE = 4'h5,
    C_TEST_PRIV = 4'h6;

  reg         clk, rst_n;
  reg         cmd_valid, wr_valid, rd_valid;
  reg  [3:0]  cmd;
  reg  [7:0]  wr_addr, wr_data, rd_addr;
  wire [7:0]  rd_data;
  wire        busy, done, error, privacy_fail;
  wire [15:0] comms_used;

  mpc_private_infer #(.FEAT(FEAT), .OUT(OUT), .LAT(2)) dut(
    .clk(clk), .rst_n(rst_n),
    .cmd_valid(cmd_valid), .cmd(cmd),
    .wr_valid(wr_valid), .wr_addr(wr_addr), .wr_data(wr_data),
    .rd_valid(rd_valid), .rd_addr(rd_addr), .rd_data(rd_data),
    .busy(busy), .done(done), .error(error),
    .privacy_fail(privacy_fail), .comms_used(comms_used)
  );

  initial begin clk = 1'b0; forever #5 clk = ~clk; end

  integer errors = 0;

  task chk;
    input [1023:0] name;
    input         cond;
    begin
      if (cond) $display("PASS %0s", name);
      else begin
        $display("FAIL %0s", name);
        errors = errors + 1;
      end
    end
  endtask

  // ---- GF(2^8) multiply, identical comb to the RTL function ----------------
  function [7:0] gf256;
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
      gf256 = acc;
    end
  endfunction

  // ---- host write: drive on negedge, hold one posedge ----------------------
  task wr;
    input [7:0] a, d;
    begin
      @(negedge clk);
      wr_valid <= 1'b1; wr_addr <= a; wr_data <= d;
      @(posedge clk);
      @(negedge clk);
      wr_valid <= 1'b0;
    end
  endtask

  // ---- host read: combinational, settled during the low phase --------------
  task rd;
    input  [7:0] a;
    output [7:0] d;
    begin
      @(negedge clk);
      rd_valid <= 1'b1; rd_addr <= a;
      @(negedge clk);
      d = rd_data;
      rd_valid <= 1'b0;
    end
  endtask

  // ---- issue a command and wait for the one-cycle done pulse ---------------
  task run_cmd;
    input [3:0] c;
    begin
      @(negedge clk);
      cmd_valid <= 1'b1; cmd <= c;
      @(posedge clk);
      @(negedge clk);
      cmd_valid <= 1'b0;
      while (done !== 1'b1) @(negedge clk);
    end
  endtask

  reg [7:0] v, xa, xb, wa, wb, a1, a2, b1, b2, e1, e2;
  reg [7:0] x0 [0:3], w0 [0:7], b0 [0:1];
  reg [7:0] exp_y [0:1];
  integer k, bitok;
  reg [7:0] acc;

  initial begin
    cmd_valid = 0; wr_valid = 0; rd_valid = 0;
    cmd = 0; wr_addr = 0; wr_data = 0; rd_addr = 0;
    rst_n = 0;
    @(negedge clk); @(negedge clk); @(negedge clk);
    rst_n = 1;
    @(negedge clk);

    x0[0]=8'h11; x0[1]=8'h22; x0[2]=8'h33; x0[3]=8'h44;
    w0[0]=8'h57; w0[1]=8'h83; w0[2]=8'h2B; w0[3]=8'h94;
    w0[4]=8'hD6; w0[5]=8'h3E; w0[6]=8'h7C; w0[7]=8'hA1;
    b0[0]=8'h05; b0[1]=8'h0A;
    // golden-model values, galois-verified gf():
    //   y[o] = XOR_i gf(w[o*4+i], x[i]) ^ b[o]
    exp_y[0]=8'h33; exp_y[1]=8'h95;

    // ---- load x, W, b ------------------------------------------------------
    for (k = 0; k < FEAT; k = k + 1) wr(A_X + k, x0[k]);
    for (k = 0; k < NMC;  k = k + 1) wr(A_W + k, w0[k]);
    for (k = 0; k < OUT;  k = k + 1) wr(A_B + k, b0[k]);

    // ---- T1: comb reference vector ----------------------------------------
    chk("T1 gf256(0x57,0x83) == 0xC1", gf256(8'h57, 8'h83) === 8'hC1);
    chk("T1 gf256(0x53,0xCA) == 0x01 (AES inv)", gf256(8'h53, 8'hCA) === 8'h01);
    chk("T1 gf256(0x57,0xBF) == 0x01 (AES inv)", gf256(8'h57, 8'hBF) === 8'h01);

    // ---- T3: share the feature vector -------------------------------------
    run_cmd(C_KEYGEN_X);
    bitok = 1;
    for (k = 0; k < FEAT; k = k + 1) begin
      rd(A_XA + k, xa); rd(A_XB + k, xb);
      $display("   x[%0d]=%02h xa=%02h xb=%02h", k, x0[k], xa, xb);
      if ((xa ^ xb) !== x0[k]) bitok = 0;
      if (xa === 8'h00 || xb === 8'h00) bitok = 0;
    end
    chk("T3 KEYGEN_X: xa^xb == x for all features, no zero share", bitok);

    // ---- T4: share the weights --------------------------------------------
    run_cmd(C_KEYGEN_W);
    bitok = 1;
    for (k = 0; k < NMC; k = k + 1) begin
      rd(A_WA + k, wa); rd(A_WB + k, wb);
      if ((wa ^ wb) !== w0[k]) bitok = 0;
    end
    chk("T4 KEYGEN_W: wa^wb == w for all weights", bitok);

    // ---- T2: honest Beaver triples -----------------------------------------
    run_cmd(C_TRIPLE);
    bitok = 1;
    for (k = 0; k < NMC; k = k + 1) begin
      rd(A_A1 + k, a1); rd(A_A2 + k, a2);
      rd(A_B1 + k, b1); rd(A_B2 + k, b2);
      rd(A_E1 + k, e1); rd(A_E2 + k, e2);
      // honest triple: e1 ^ e2 == (a1 ^ a2) . (b1 ^ b2)
      if ((e1 ^ e2) !== gf256(a1 ^ a2, b1 ^ b2)) begin
        bitok = 0;
        $display("   MAC %0d: a=%02h b=%02h e1^e2=%02h gf(a,b)=%02h",
                 k, a1 ^ a2, b1 ^ b2, e1 ^ e2, gf256(a1 ^ a2, b1 ^ b2));
      end
      if (a1 === a2 || b1 === b2) begin
        bitok = 0;
        $display("   MAC %0d: degenerate shares a1==a2=%02h b1==b2=%02h",
                 k, a1, b1);
      end
    end
    chk("T2 TRIPLE: e1^e2 == (a1^a2).(b1^b2) honest for all 8", bitok);

    // ---- T5: privacy self-test clean ---------------------------------------
    run_cmd(C_TEST_PRIV);
    chk("T5 TEST_PRIV clean on the real RNG draw", privacy_fail === 1'b0);

    // ---- T6: MODE 0, W public, zero online comms ---------------------------
    // T8 rides along: busy must be high on every cycle of the INFER_PUB run
    // except the final one (which sets done and drops busy).
    @(negedge clk);
    cmd_valid <= 1'b1; cmd <= C_INFER_PUB;
    @(posedge clk);
    @(negedge clk);
    cmd_valid <= 1'b0;
    bitok = 1;
    while (done !== 1'b1) begin
      if (busy !== 1'b1) bitok = 0;
      @(negedge clk);
    end
    chk("T8 busy held high for the whole INFER_PUB run", bitok);

    run_cmd(C_RECOMBINE);
    bitok = 1;
    for (k = 0; k < OUT; k = k + 1) begin
      rd(A_Y + k, v);
      if (v !== exp_y[k]) bitok = 0;
    end
    chk("T6 MODE 0 y == 0x33,0x95 (== plaintext reference)", bitok);
    chk("T6 MODE 0 comms_used still 0 (no online rounds)", comms_used === 16'd0);

    // ---- T7: MODE 1, Beaver, 3 rounds per MAC -------------------------------
    for (k = 0; k < OUT; k = k + 1) wr(A_Y + k, 8'h00);   // erase MODE 0 result
    run_cmd(C_INFER_SHR);
    bitok = 1;
    for (k = 0; k < OUT; k = k + 1) begin
      rd(A_Y + k, v);
      if (v !== exp_y[k]) bitok = 0;
    end
    chk("T7 MODE 1 (Beaver) y == 0x33,0x95 (== plaintext reference)", bitok);
    $display("   comms_used = %0d", comms_used);
    chk("T7 comms_used == 3*8 = 24", comms_used === 16'd24);

    // independent re-derivation of the expected output from the reveals:
    // w.x = z ^ alpha.beta should hold per MAC; recompute y from REVA/REVB/REVP
    acc = 8'h00;
    for (k = 0; k < NMC; k = k + 1) begin
      rd(A_REVA + k, xa);   // alpha
      rd(A_REVB + k, xb);   // beta
      rd(A_REVP + k, v);    // z
      acc = acc ^ (v ^ gf256(xa, xb));
      if (k % FEAT == FEAT-1) begin
        // acc now holds row (k/FEAT) before bias
        if (k / FEAT == 0) chk("T7 z^alpha.beta recomputes row 0 pre-bias",
                               acc === (exp_y[0] ^ b0[0]));
        else               chk("T7 z^alpha.beta recomputes row 1 pre-bias",
                               acc === (exp_y[1] ^ b0[1]));
        acc = 8'h00;
      end
    end

    // ---- T9: tamper a share, privacy self-test must catch it ----------------
    rd(A_X, v);
    wr(A_XA, v);                 // forge share A0 = secret
    run_cmd(C_TEST_PRIV);
    chk("T9 TEST_PRIV flags a share equal to the secret", privacy_fail === 1'b1);

    // ---- T0: illegal command latches error (run last: error is sticky) -----
    // A bad command leaves st in S_IDLE, so `done` never pulses; wait a
    // bounded number of cycles instead of hanging on the done handshake.
    @(negedge clk);
    cmd_valid <= 1'b1; cmd <= 4'h7;
    @(posedge clk);
    @(negedge clk);
    cmd_valid <= 1'b0;
    for (k = 0; k < 8; k = k + 1) @(negedge clk);
    chk("T0 illegal command latches error", error === 1'b1);

    if (errors == 0) $display("\n=== ALL TESTS PASSED ===");
    else             $display("\n=== %0d FAILURES ===", errors);
    $finish;
  end

  // ---- independent watchdog ------------------------------------------------
  initial begin
    #2000000;
    $display("FAIL TIMEOUT");
    $finish;
  end

endmodule

`default_nettype wire
