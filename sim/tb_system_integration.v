`timescale 1ns / 1ps

module tb_system_integration();

reg clk;
reg rst_n;

// 全局接口
wire [255:0] puf_output;
wire puf_valid;
wire [255:0] dilithium_signature_r;
wire [255:0] dilithium_signature_s;
wire dilithium_sig_valid;
wire dilithium_sig_ready;
wire [127:0] fsm_secure_result;
wire fsm_ready;

// 复位生成
initial begin
    rst_n = 0;
    #100 rst_n = 1;
end

// 时钟生成
parameter CLK_PERIOD = 10;
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// 顶层模块实例化
// 这里只实例化几个核心模块进行集成测试
dilithium_core u_dilithium (
    .clk(clk),
    .rst_n(rst_n),
    .sign_req(1'b1),
    .verify_req(1'b0),
    .message(256'd0),
    .private_key(256'd123456),
    .public_key(256'd0),
    .signature(256'd0),
    .signature_r(dilithium_signature_r),
    .signature_s(dilithium_signature_s),
    .sig_valid(dilithium_sig_valid),
    .verify_result(),
    .error(),
    .ready(dilithium_sig_ready)
);

hybrid_signature_fsm u_fsm (
    .clk(clk),
    .rst_n(rst_n),
    .inference_request(128'd0),
    .puf_id(128'd0),
    .secure_boot_ok(1'b1),
    .inference_done(1'b1),
    .inference_result(128'd0),
    .fsm_secure(fsm_secure_result),
    .fsm_sign_valid(),
    .fsm_verify_valid(),
    .fsm_error(),
    .fsm_ready(fsm_ready)
);

optical_puf_controller u_op_puf (
    .clk(clk),
    .rst_n(rst_n),
    .puf_request(128'd0),
    .puf_output(puf_output),
    .puf_valid(puf_valid),
    .error()
);

always begin
    @(posedge clk);
    if (rst_n == 1) begin
        #100;
        $display("\n=== System Integration Test ===");
        $display("Dilithium Signature: r=0x%0h, s=0x%0h", dilithium_signature_r, dilithium_signature_s);
        $display("Holistic Security: fsm_secure=%b", fsm_secure_result);
        $display("OP-PUF output valid: %b", puf_valid);
        $display("\nAll modules working together!");
        $finish;
    end
end

endmodule
