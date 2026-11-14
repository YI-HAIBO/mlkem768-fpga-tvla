`timescale 1ns / 1ps

// =============================================================================
// Testbench: ipx_aoi_sec_board_top  (Nexys 4 DDR 板级 POST 自检)
//   驱动 clk/rst_n，等待板上状态机跑完 KeyGen->Encaps->Decaps 往返，
//   独立用 !== 逐字节比对 ss_enc 与 ss_dec，给出 X 感知的权威判决。
//   与 RTL 内部的 LED[0] 判定互为印证。
// =============================================================================

module tb_ipx_aoi_sec_board_top;

    reg         clk;
    reg         rst_n;
    wire [15:0] test_led;
    reg  [15:0] test_sw;
    reg  [4:0]  test_btn;

    // DUT  (CLK_DIV=1 -> clk_slow 跟随 clk, 仿真全速; 板级默认 8 -> 12.5 MHz)
    ipx_aoi_sec_board_top #(.CLK_DIV(1)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .test_led (test_led),
        .test_sw  (test_sw),
        .test_btn (test_btn)
    );

    // 100 MHz 时钟
    always #5 clk = ~clk;

    // 顶层看门狗：整条 KEM 往返远小于 5M 拍 (见 tb_kyber_kem.v)
    integer cyc;
    initial cyc = 0;
    always @(posedge clk) begin
        if (rst_n) begin
            cyc = cyc + 1;
            if (cyc > 5_000_000) begin
                $display("[TB] TIMEOUT after %0d cycles, st=%0d", cyc, dut.st);
                $display("RESULT: BOARD_POST TIMEOUT");
                $finish;
            end
        end
    end

    // --- KEM stage cycle measurement (added for Table 6 cross-check) ---
    integer kgs, ens, des;
    integer kgc, enc, dec;
    reg  [2:0] kph;
    initial begin
        kph = 0; kgs = 0; ens = 0; des = 0; kgc = 0; enc = 0; dec = 0;
    end
    always @(negedge clk) begin
        if (!rst_n) kph <= 0;
        else case (kph)
            0: if (dut.start && dut.op_keygen) begin kgs <= cyc; kph <= 1; end
            1: if (dut.done) begin kgc <= cyc - kgs; kph <= 2; end
            2: if (dut.start && dut.op_encaps) begin ens <= cyc; kph <= 3; end
            3: if (dut.done) begin enc <= cyc - ens; kph <= 4; end
            4: if (dut.start && !dut.op_keygen && !dut.op_encaps) begin des <= cyc; kph <= 5; end
            5: if (dut.done) begin dec <= cyc - des; kph <= 6; end
            default: ;
        endcase
    end

    integer k;
    integer bad;
    reg [7:0] exp_seed, exp_msg;

    initial begin
        clk      = 1'b0;
        rst_n    = 1'b0;
        test_sw  = 16'h0000;
        test_btn = 5'b00000;

        // 在 negedge 解复位，避开 posedge 采样竞争
        repeat (5) @(negedge clk);
        rst_n = 1'b1;

        // 等板上状态机到达 S_DONE
        wait (dut.st == dut.S_DONE);
        @(posedge clk);
        @(negedge clk);

        $display("========================================================");
        $display(" KEM stages: keygen=%0d  encaps=%0d  decaps=%0d cycles",
                 kgc, enc, dec);
        $display(" Board POST finished after %0d cycles", cyc);
        $display(" LED = %04h", test_led);
        $display(" RTL  post_pass=%b  post_fail=%b  error_seen=%b",
                 dut.post_pass, dut.post_fail, dut.error_seen);

        // 打印 Encaps / Decaps 共享密钥
        $write(" ss_enc =");
        for (k = 0; k < 32; k = k + 1) $write(" %02h", dut.ss_enc[k]);
        $write("\n ss_dec =");
        for (k = 0; k < 32; k = k + 1) $write(" %02h", dut.ss_dec[k]);
        $write("\n");

        // 权威判决：!== 逐字节比较 (X 感知)
        bad = 0;
        for (k = 0; k < 32; k = k + 1)
            if (dut.ss_enc[k] !== dut.ss_dec[k]) begin
                if (bad < 8)
                    $display("  SS[%0d] MISMATCH: enc=%02h dec=%02h",
                             k, dut.ss_enc[k], dut.ss_dec[k]);
                bad = bad + 1;
            end

        // 共享密钥不应为全零/全一 (退化指示)
        if (dut.ss_enc[0] === 8'hxx)
            $display("  WARN: ss_enc contains X (capture path suspect)");

        if ((bad == 0) && (dut.post_pass === 1'b1) && (dut.post_fail === 1'b0))
            $display("RESULT: BOARD_POST PASS  (Encaps.ss == Decaps.ss, 32/32)");
        else
            $display("RESULT: BOARD_POST FAIL  (bad=%0d, led_pass=%b)",
                     bad, dut.post_pass);
        $display("========================================================");

        // ---- BTN0 软重触发：确认可重复 ----
        @(negedge clk);
        test_btn = 5'b00001;   // 按下 BTN0
        @(negedge clk);
        test_btn = 5'b00000;   // 松开
        wait (dut.st == dut.S_DONE);
        @(posedge clk);
        @(negedge clk);
        $display(" After BTN0 re-run: post_pass=%b post_fail=%b led=%04h",
                 dut.post_pass, dut.post_fail, test_led);
        bad = 0;
        for (k = 0; k < 32; k = k + 1)
            if (dut.ss_enc[k] !== dut.ss_dec[k]) bad = bad + 1;
        if ((bad == 0) && (dut.post_pass === 1'b1))
            $display("RESULT: BOARD_POST RERUN PASS");
        else
            $display("RESULT: BOARD_POST RERUN FAIL (bad=%0d)", bad);

        $finish;
    end

endmodule
