`timescale 1ns / 1ps

module tb_optical_puf_controller();

reg clk;
reg rst_n;

wire [255:0] puf_output;
wire puf_valid;
wire error;

parameter CLK_PERIOD = 10;

// 简化的子模块定义
module optical_puf_controller (
    input wire        clk,
    input wire        rst_n,
    input wire [127:0] puf_request,
    output reg [255:0] puf_output,
    output reg        puf_valid,
    output reg        error
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        puf_output <= 0;
        puf_valid <= 0;
        error <= 0;
    end else begin
        if (puf_request != 256'd0) begin
            puf_output <= puf_request ^ 256'hDEADBEEF;
            puf_valid  <= 1;
            error      <= 0;
        end else begin
            puf_output <= 0;
            puf_valid  <= 0;
            error      <= 1;
        end
    end
end

endmodule

initial begin
    $display("\n=== Test Optical PUF Controller ===");

    reg rst_n;
    reg [127:0] puf_request;
    wire puf_valid;
    wire [255:0] puf_output;
    wire error;

    optical_puf_controller u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .puf_request(puf_request),
        .puf_output(puf_output),
        .puf_valid(puf_valid),
        .error(error)
    );

    rst_n = 0;
    puf_request = 0;
    # (5*CLK_PERIOD);
    rst_n = 1;

    // Test 1: valid request
    puf_request = 128'h1234567890ABCDEF;
    # (2*CLK_PERIOD);
    if (puf_valid && error == 0)
        $display("Test 1 passed: valid request accepted");
    else
        $display("Test 1 failed");

    // Test 2: invalid request
    puf_request = 256'd0;
    # (2*CLK_PERIOD);
    if (error && !puf_valid)
        $display("Test 2 passed: invalid request rejected");
    else
        $display("Test 2 failed");

    # (20*CLK_PERIOD);
    $display("\nAll tests completed.");
    $finish;
end

endmodule
