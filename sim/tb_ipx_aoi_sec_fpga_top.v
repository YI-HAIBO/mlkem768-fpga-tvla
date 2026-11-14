`timescale 1ns / 1ps

module tb_ipx_aoi_sec_fpga_top;

reg clk;
reg rst_n;
reg [255:0] puf_fingerprint;
reg puf_valid;
reg [127:0] model_id;
reg model_load_req;
wire model_load_done;
reg [127:0] inference_request;
wire inference_done;
wire [127:0] inference_result;
reg secure_boot_req;
wire secure_boot_done;
wire boot_verification_ok;
wire [256:0] derivated_key;
wire key_valid;
wire masking_enabled;
wire trng_output;
wire trng_valid;
wire [7:0] status_register;
wire error_flag;

// 实例化待测试模块
ipx_aoi_sec_fpga_top u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .puf_fingerprint(puf_fingerprint),
    .puf_valid(puf_valid),
    .model_id(model_id),
    .model_load_req(model_load_req),
    .model_load_done(model_load_done),
    .inference_request(inference_request),
    .inference_done(inference_done),
    .inference_result(inference_result),
    .secure_boot_req(secure_boot_req),
    .secure_boot_done(secure_boot_done),
    .boot_verification_ok(boot_verification_ok),
    .derivated_key(derivated_key),
    .key_valid(key_valid),
    .masking_enabled(masking_enabled),
    .trng_output(trng_output),
    .trng_valid(trng_valid),
    .status_register(status_register),
    .error_flag(error_flag)
);

// 时钟生成 (100 MHz)
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns周期 -> 100MHz
end

// 测试流程
initial begin
    // 初始化
    rst_n = 0;
    puf_fingerprint = 0;
    puf_valid = 0;
    model_id = 0;
    model_load_req = 0;
    secure_boot_req = 0;
    
    // 复位释放
    #100 rst_n = 1;
    
    // TODO: 添加测试用例
    
    // 结束测试
    #1000 $finish();
end

// 波形dump
initial begin
    $dumpfile("tb_ipx_aoi_sec_fpga_top.vcd");
    $dumpvars(0, tb_ipx_aoi_sec_fpga_top);
end

endmodule
