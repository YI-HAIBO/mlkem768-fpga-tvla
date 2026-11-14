`timescale 1ns / 1ps

module tb_hybrid_signature_fsm();

reg clk;
reg rst_n;
reg [127:0] inference_request;
reg [127:0] puf_id;
reg secure_boot_ok;
reg inference_done;
reg [127:0] inference_result;

wire fsm_secure;
wire fsm_sign_valid;
wire fsm_verify_valid;
wire fsm_error;
wire fsm_ready;

parameter CLK_PERIOD = 10;

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

hybrid_signature_fsm u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .inference_request(inference_request),
    .puf_id(puf_id),
    .secure_boot_ok(secure_boot_ok),
    .inference_done(inference_done),
    .inference_result(inference_result),
    .fsm_secure(fsm_secure),
    .fsm_sign_valid(fsm_sign_valid),
    .fsm_verify_valid(fsm_verify_valid),
    .fsm_error(fsm_error),
    .fsm_ready(fsm_ready)
);

initial begin
    $display("\n=== Test Hybrid Signature FSM ===");

    // Init
    rst_n = 0;
    secure_boot_ok = 0;
    inference_done = 0;
    # (5*CLK_PERIOD);
    rst_n = 1;

    // Test 1: secure boot ok
    secure_boot_ok = 1;
    # (20*CLK_PERIOD);
    if (fsm_ready && fsm_secure && fsm_sign_valid && fsm_verify_valid)
        $display("Test 1 passed: FSM ready + secure");
    else
        $display("Test 1 failed: fsm_ready=%b fsm_secure=%b fsm_sign_valid=%b fsm_verify_valid=%b", fsm_ready, fsm_secure, fsm_sign_valid, fsm_verify_valid);

    // Test 2: remove secure boot
    secure_boot_ok = 0;
    # (20*CLK_PERIOD);
    if (fsm_error)
        $display("Test 2 passed: error detected");
    else
        $display("Test 2 failed: no error");

    # (20*CLK_PERIOD);
    $display("\nAll tests completed.");
    $finish;
end

endmodule
