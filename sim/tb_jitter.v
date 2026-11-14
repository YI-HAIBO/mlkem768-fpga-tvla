`timescale 1ns / 1ps
// Verify jitter_ctrl: the 3-stage modv pipeline must produce the SAME delay
// value as the reference formula (op_id*7 + rnd*3) mod 17.
module tb_jitter;
    reg clk = 0;
    reg rst_n = 0;
    reg in_valid = 0;
    reg [7:0] rnd = 0;
    reg [15:0] op_id = 0;
    wire out_valid;
    wire [15:0] delay_cycles;

    jitter_ctrl #(.MAX_DELAY(16)) dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .rnd(rnd), .op_id(op_id),
        .out_valid(out_valid), .delay_cycles(delay_cycles)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer i;
    integer guard;
    reg done;

    task check;
        input [7:0] r;
        input [15:0] op;
        reg [23:0] raw;
        reg [15:0] expect_delay;
        begin
            // wait for idle
            guard = 0;
            while (dut.running !== 1'b0 && guard < 100) begin
                @(posedge clk);
                guard = guard + 1;
            end
            rnd = r;
            op_id = op;
            in_valid = 1;
            @(posedge clk);
            #1 in_valid = 0;   // deassert just after the edge, no posedge race
            // out_valid is a one-clock pulse. Scan every clock and sample
            // mid-clock with #1 so the posedge NBAs have settled first; this
            // also catches the delay==0 case where the pulse lands right
            // after the single running clock.
            guard = 0;
            done = 1'b0;
            while (!done && guard < 200) begin
                @(posedge clk);
                #1;
                guard = guard + 1;
                if (out_valid === 1'b1) done = 1'b1;
            end
            raw = (op * 16'd7) + (r * 24'd3);
            expect_delay = raw % 17;
            if (!done) begin
                errors = errors + 1;
                $display("NO-PULSE rnd=%h op=%h delay=%h", r, op, delay_cycles);
            end else if (delay_cycles !== expect_delay) begin
                errors = errors + 1;
                $display("MISMATCH rnd=%h op=%h : got %h expect %h",
                         r, op, delay_cycles, expect_delay);
            end else begin
                $display("OK rnd=%h op=%h : delay=%h (clk %0d)",
                         r, op, delay_cycles, guard);
            end
            @(posedge clk);
        end
    endtask

    initial begin
        // drive a real low pulse so the async negedge reset actually fires
        rst_n = 1;
        #1 rst_n = 0;
        #3 rst_n = 1;
        #3;
        check(8'h00, 16'h0000);
        check(8'hFF, 16'hFFFF);
        check(8'h37, 16'h1234);
        check(8'hA5, 16'h0042);
        check(8'h5A, 16'hBEEF);
        for (i = 0; i < 20; i = i + 1) begin
            check($urandom % 256, $urandom % 65536);
        end
        $display("=== errors=%0d ===", errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("TESTS FAILED");
        $finish;
    end

    initial begin
        #50000 $display("TIMEOUT");
        $finish;
    end
endmodule
