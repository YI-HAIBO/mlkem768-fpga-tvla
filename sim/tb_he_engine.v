// =============================================================================
// TB for B1 he_engine.v (BGV-style integer-slot HE inference engine)
// -----------------------------------------------------------------------------
// Golden vectors: verify/he_engine_golden.py  (seed 0x1111)
//   pk_a = 0xe04b, pk_b = 0x1fb5, sk s = 1
//   messages 10..80, weights 1..8, bias 17, plaintext result = 9
//
// T0 bad command -> cmd_err
// T1 keygen -> golden public/secret key
// T2 encrypt x8 -> golden ciphertexts + enc/dec roundtrip
// T3 homomorphic add        (m0 + m1)
// T4 homomorphic sub        (m2 - m1)
// T5 homomorphic plain mul  (7 * m3)
// T6 mod-switch             (m4 survives q=2^16 -> q'=2^15)
// T7 encrypted inference    -> 9
//
// Iron rule: ALL DUT inputs are driven on the negedge so the DUT's posedge
// sampling never races the bench.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_he_engine;

  reg         clk, rst_n;
  reg         reg_wr, reg_rd;
  reg  [7:0]  reg_waddr, reg_raddr;
  reg  [15:0] reg_wdata;
  wire [15:0] reg_rdata;
  reg  [3:0]  cmd;
  reg         cmd_start;
  wire        cmd_busy, cmd_done, cmd_err;

  he_engine dut(
    .clk(clk), .rst_n(rst_n),
    .reg_wr(reg_wr), .reg_waddr(reg_waddr), .reg_wdata(reg_wdata),
    .reg_rd(reg_rd), .reg_raddr(reg_raddr), .reg_rdata(reg_rdata),
    .cmd(cmd), .cmd_start(cmd_start),
    .cmd_busy(cmd_busy), .cmd_done(cmd_done), .cmd_err(cmd_err)
  );

  // 100 MHz clock
  initial begin clk = 1'b0; forever #5 clk = ~clk; end

  integer errors = 0;
  reg busy_violation = 1'b0;

  // ---- golden ciphertexts (from verify/he_engine_golden.py, seed 0x1111) ----
  reg [15:0] gc0 [0:7];
  reg [15:0] gc1 [0:7];
  reg [15:0] ct0v [0:7];   // ciphertexts produced by RTL during T2
  reg [15:0] ct1v [0:7];
  reg [15:0] msgs [0:7];
  reg [15:0] wts  [0:7];

  initial begin
    gc0[0]=16'h29b5; gc1[0]=16'he04b;
    gc0[1]=16'h1400; gc1[1]=16'h0000;
    gc0[2]=16'h3db5; gc1[2]=16'he04b;
    gc0[3]=16'h47b5; gc1[3]=16'he04b;
    gc0[4]=16'h51b5; gc1[4]=16'he04b;
    gc0[5]=16'h3c00; gc1[5]=16'h0000;
    gc0[6]=16'h4600; gc1[6]=16'h0000;
    gc0[7]=16'h6fb5; gc1[7]=16'he04b;
    msgs[0]=16'd10; msgs[1]=16'd20; msgs[2]=16'd30; msgs[3]=16'd40;
    msgs[4]=16'd50; msgs[5]=16'd60; msgs[6]=16'd70; msgs[7]=16'd80;
    wts[0]=16'd1; wts[1]=16'd2; wts[2]=16'd3; wts[3]=16'd4;
    wts[4]=16'd5; wts[5]=16'd6; wts[6]=16'd7; wts[7]=16'd8;
  end

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------
  task wr;            // register write pulse (negedge-aligned)
    input [7:0]  a;
    input [15:0] d;
    begin
      @(negedge clk);
      reg_wr <= 1'b1; reg_waddr <= a; reg_wdata <= d;
      @(posedge clk);
      @(negedge clk);
      reg_wr <= 1'b0;
    end
  endtask

  task rd;            // register read (combinatorial rdata)
    input  [7:0]  a;
    output [15:0] d;
    begin
      @(negedge clk);
      reg_rd <= 1'b1; reg_raddr <= a;
      @(posedge clk);
      #1 d = reg_rdata;
      @(negedge clk);
      reg_rd <= 1'b0;
    end
  endtask

  task start_cmd;     // pulse cmd_start for one posedge
    input [3:0] c;
    begin
      @(negedge clk);
      cmd <= c; cmd_start <= 1'b1;
      @(posedge clk);
      @(negedge clk);
      cmd_start <= 1'b0;
    end
  endtask

  task wait_done;     // wait for the one-cycle cmd_done, checking busy
    begin
      @(negedge clk);
      while (cmd_done !== 1'b1) begin
        if (cmd_busy !== 1'b1) busy_violation = 1'b1;
        @(negedge clk);
      end
    end
  endtask

  task chk;
    input [255:0] name;
    input         cond;
    begin
      if (cond) $display("PASS %0s", name);
      else begin
        $display("FAIL %0s", name);
        errors = errors + 1;
      end
    end
  endtask

  // sw=1 decryption performed in the bench (mirrors he_dec switched path)
  task dec_sw1;
    input [15:0] c0, c1, s;
    output [15:0] m;
    reg [15:0] v;
    begin
      v = (c0 + (s ? c1 : 16'd0)) & 16'h7FFF;
      m = ((v + 16'd64) >> 7) & 16'h00FF;
    end
  endtask

  integer i;
  reg [15:0] tmp, tmp2, a_r, b_r, s_r, m_r, c0_r, c1_r, r0, r1;

  initial begin
    reg_wr = 1'b0; reg_rd = 1'b0;
    reg_waddr = 8'd0; reg_raddr = 8'd0; reg_wdata = 16'd0;
    cmd = 4'd0; cmd_start = 1'b0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    @(negedge clk); rst_n = 1'b1;
    $display("=== B1 he_engine testbench start ===");

    // ---------------- T0: bad command -> cmd_err --------------------------
    @(negedge clk); cmd <= 4'd15; cmd_start <= 1'b1;
    @(posedge clk);
    @(negedge clk); cmd_start <= 1'b0; tmp = cmd_err;
    @(posedge clk);
    chk("T0 bad command sets cmd_err", tmp === 1'b1);

    // ---------------- T1: keygen (seed 0x1111) ----------------------------
    wr(8'h20, 16'h1111);
    start_cmd(4'd1); wait_done;
    rd(8'h22, a_r);
    rd(8'h23, b_r);
    rd(8'h21, s_r);
    $display("   keygen: a=%h b=%h s=%0d", a_r, b_r, s_r);
    chk("T1a pk_a == 0xe04b", a_r === 16'he04b);
    chk("T1b pk_b == 0x1fb5", b_r === 16'h1fb5);
    chk("T1c sk s == 1",      s_r === 16'd1);

    // ---------------- T2: encrypt x8, golden compare + roundtrip ---------
    for (i = 0; i < 8; i = i + 1) begin
      wr(8'h24, msgs[i]);
      start_cmd(4'd2); wait_done;
      rd(8'h25, c0_r);
      rd(8'h26, c1_r);
      ct0v[i] = c0_r;
      ct1v[i] = c1_r;
      // store into CT RAM as (c0, c1) pair at 2i / 2i+1
      wr(i[7:0] << 1,     c0_r);
      wr((i[7:0] << 1) + 8'd1, c1_r);
      // enc/dec roundtrip (C_DEC uses rc0/rc1, sw=0, no LCG consumed)
      start_cmd(4'd3); wait_done;
      rd(8'h27, m_r);
      if (c0_r !== gc0[i] || c1_r !== gc1[i]) begin
        $display("   T2 enc[%0d] mismatch: got (%h,%h) want (%h,%h)",
                 i, c0_r, c1_r, gc0[i], gc1[i]);
      end
      if (m_r !== msgs[i]) begin
        $display("   T2 dec[%0d] mismatch: got %0d want %0d", i, m_r, msgs[i]);
      end
    end
    tmp = 1'b1;
    tmp2 = 1'b1;
    for (i = 0; i < 8; i = i + 1) begin
      if (ct0v[i] !== gc0[i] || ct1v[i] !== gc1[i]) tmp = 1'b0;
      // decrypt each ciphertext again and verify the message roundtrip
      // (C_DEC operates on the rc0/rc1 result registers, so load them)
      wr(8'h25, ct0v[i]);
      wr(8'h26, ct1v[i]);
      start_cmd(4'd3); wait_done;   // C_DEC consumes no LCG state
      rd(8'h27, m_r);
      if (m_r !== msgs[i]) tmp2 = 1'b0;
    end
    chk("T2a all 8 ciphertexts bit-exact vs golden", tmp);
    chk("T2b all 8 enc/dec roundtrips recover message", tmp2);

    // ---------------- T3: homomorphic add  m0 + m1 = 30 -------------------
    // CT RAM layout for the ALU ops: [0]=c0A [1]=c0B [2]=c1A [3]=c1B
    wr(8'd0, ct0v[0]); wr(8'd1, ct0v[1]);
    wr(8'd2, ct1v[0]); wr(8'd3, ct1v[1]);
    start_cmd(4'd4); wait_done;     // C_ADD
    start_cmd(4'd3); wait_done;     // C_DEC
    rd(8'h27, m_r);
    $display("   he_add dec: %0d (want 30)", m_r);
    chk("T3 homomorphic add -> 30", m_r === 16'd30);

    // ---------------- T4: homomorphic sub  m2 - m1 = 10 -------------------
    wr(8'd0, ct0v[2]); wr(8'd1, ct0v[1]);
    wr(8'd2, ct1v[2]); wr(8'd3, ct1v[1]);
    start_cmd(4'd5); wait_done;     // C_SUB
    start_cmd(4'd3); wait_done;     // C_DEC
    rd(8'h27, m_r);
    $display("   he_sub dec: %0d (want 10)", m_r);
    chk("T4 homomorphic sub -> 10", m_r === 16'd10);

    // ---------------- T5: homomorphic plain mul  7 * m3 = 280 mod 256 = 24
    wr(8'd0, ct0v[3]);
    wr(8'd2, ct1v[3]);
    wr(8'h24, 16'd7);
    start_cmd(4'd6); wait_done;     // C_PMUL
    start_cmd(4'd3); wait_done;     // C_DEC
    rd(8'h27, m_r);
    $display("   he_pmul dec: %0d (want 24)", m_r);
    chk("T5 homomorphic pmul -> 24", m_r === 16'd24);

    // ---------------- T6: mod-switch  q=2^16 -> q'=2^15, m4 = 50 ---------
    wr(8'd0, ct0v[4]);
    wr(8'd2, ct1v[4]);
    start_cmd(4'd7); wait_done;     // C_MODSW
    rd(8'h25, r0);
    rd(8'h26, r1);
    // golden modsw: ((c+1)>>1) & 0x7FFF
    tmp  = ((ct0v[4] + 16'd1) >> 1) & 16'h7FFF;
    tmp2 = ((ct1v[4] + 16'd1) >> 1) & 16'h7FFF;
    chk("T6a modsw c0 bit-exact", r0 === tmp);
    chk("T6b modsw c1 bit-exact", r1 === tmp2);
    dec_sw1(r0, r1, s_r, m_r);
    $display("   modsw+dec(sw=1): %0d (want 50)", m_r);
    chk("T6c message survives mod-switch -> 50", m_r === 16'd50);

    // ---------------- T7: encrypted inference -> 9 -------------------------
    for (i = 0; i < 8; i = i + 1) begin
      wr(i[7:0] << 1,         ct0v[i]);
      wr((i[7:0] << 1) + 8'd1, ct1v[i]);
    end
    for (i = 0; i < 8; i = i + 1)
      wr(8'h10 + i[7:0], wts[i]);
    wr(8'h18, 16'd17);              // bias
    start_cmd(4'd8); wait_done;     // C_INFER
    rd(8'h27, m_r);
    $display("   inference result: %0d (want 9, plaintext w.x+b mod 256)", m_r);
    chk("T7 encrypted inference -> 9", m_r === 16'd9);

    // ---------------- busy protocol ----------------------------------------
    chk("TB cmd_busy held during all ops", busy_violation === 1'b0);

    // -----------------------------------------------------------------------
    if (errors == 0) $display("=== ALL TESTS PASSED (B1 he_engine) ===");
    else             $display("=== %0d FAILURES ===", errors);
    $finish;
  end

  // watchdog
  initial begin
    #200000;
    $display("FAIL: timeout");
    $finish;
  end

endmodule

`default_nettype wire
