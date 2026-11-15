`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// 周期计数 TB：kyber_kem 的 KeyGen/Encaps/Decaps 各操作周期数（#9）
// 仅测周期（FSM 状态数不依赖数据），带 5M 周期超时保护。
// =============================================================================
module tb_cycle_count;
    reg clk, rst_n;
    reg start, op_keygen, op_encaps;
    reg in_load;
    reg [7:0] in_addr, in_data;
    reg ct_load;
    reg [15:0] ct_in_addr, ct_data_in;
    wire busy, done, error;
    wire pk_valid; wire [15:0] pk_addr; wire [15:0] pk_data;
    wire ct_valid; wire [15:0] ct_addr; wire [15:0] ct_data;
    wire ss_valid; wire [7:0] ss_data;

    integer cyc, n;

    kyber_kem #(.K(3),.N(256),.Q(3329),.BW(16),.ETA(2),.DU(10),.DV(4),
                .R_MOD(2285),.SEED_B(32),.MSG_B(32),.SS_B(32)) dut (
        .clk(clk),.rst_n(rst_n),.start(start),.op_keygen(op_keygen),
        .op_encaps(op_encaps),.busy(busy),.done(done),.error(error),
        .in_load(in_load),.in_addr(in_addr),.in_data(in_data),
        .ct_load(ct_load),.ct_in_addr(ct_in_addr),.ct_data_in(ct_data_in),
        .pk_valid(pk_valid),.pk_addr(pk_addr),.pk_data(pk_data),
        .ct_valid(ct_valid),.ct_addr(ct_addr),.ct_data(ct_data),
        .ss_valid(ss_valid),.ss_data(ss_data));

    always #5 clk = ~clk;

    // 一次操作：pulse start，等待 done，返回周期数（含超时 -1/-2）
    task run_op(input kg, input enc, output integer cycles);
        reg got_busy;
        begin
            got_busy = 0;
            cyc = 0;
            start = 0; op_keygen = kg; op_encaps = enc;
            @(negedge clk); start = 1; @(negedge clk); start = 0;
            while (!busy && cyc < 200000) begin @(negedge clk); cyc = cyc + 1; end
            got_busy = busy;
            if (got_busy) begin
                cyc = 0;
                while (!done && cyc < 5000000) begin @(negedge clk); cyc = cyc + 1; end
                cycles = (done) ? cyc : -1;
            end else begin
                cycles = -2;
            end
        end
    endtask

    initial begin
        clk = 0; rst_n = 0; start = 0; op_keygen = 0; op_encaps = 0;
        in_load = 0; in_addr = 0; in_data = 0;
        ct_load = 0; ct_in_addr = 0; ct_data_in = 0;
        repeat (4) @(negedge clk); rst_n = 1;
        repeat (4) @(negedge clk);

        n = 0;
        run_op(1, 0, n);  // KeyGen
        $display("CYCLES_KEYGEN = %0d", n);

        run_op(0, 1, n);  // Encaps
        $display("CYCLES_ENCAPS = %0d", n);

        run_op(0, 0, n);  // Decaps
        $display("CYCLES_DECAPS = %0d", n);

        $finish;
    end
endmodule
`default_nettype wire
