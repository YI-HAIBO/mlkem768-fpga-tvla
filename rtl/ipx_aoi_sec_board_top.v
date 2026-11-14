`timescale 1ns / 1ps

// =============================================================================
// IPX-AOI-Sec  Nexys 4 DDR 板级功能验证顶层  (Phase 5 / Task 78)
// -----------------------------------------------------------------------------
// 目标器件：Digilent Nexys 4 DDR (Artix-7 XC7A100T-1CSG324)，100 MHz (E3)。
//
// 上电自检 (POST)：
//   用硬编码的 32 B 种子 d 与 32 B 消息 m，在片内跑完整 ML-KEM 往返：
//       KeyGen(d) -> Encaps(m) -> ss_enc
//       Decaps(自产 ct)        -> ss_dec
//   若 ss_enc == ss_dec (32 B) 则 LED[0]=PASS，否则 LED[1]=FAIL。
//   KEM 是确定性的：给定 (d,m)，正确性 ⟺ Encaps 与 Decaps 得到同一 ss，
//   因此无需外部黄金向量即可在板上完成端到端功能验证。
//
// 驱动方式：本顶层用一个同步状态机 (posedge clk_slow) 产生 kyber_kem 的全部
//   控制信号 (start/op_*/in_load/...)。所有 DUT 输入均来自本模块的寄存器
//   输出，与 kyber_kem 同钟域、同 posedge 采样 —— 无 TB 式 @(posedge) 竞争。
//
// 时钟域（2026-10-25 t75d 实测后加入）：
//   完整 ML-KEM 数据通路 (shake/sampler/NTT/poly 全链) place 后关键路径
//   ~44.4 ns / 47-50 逻辑级 (results/impl_board_top_t75d_pre_route_timing.rpt,
//   u_kem/u_basemul/poly_r_reg -> acc_reg)，无法闭合 100 MHz。
//   板级 POST 是功能演示（正确性已由 iverilog 证明，时钟快慢只影响演示
//   速度），故 100 MHz 晶振经 CLK_DIV=8 分频 -> 12.5 MHz (80 ns) 驱动 DUT
//   与 FSM。XDC 的 create_clock -period 10 保持不动（真实晶振频率），
//   clk_slow 由寄存器分频产生，Vivado 自动推导 generated clock (80 ns)，
//   STA 检查的是物理正确的周期。
//   TB 以 #(.CLK_DIV(1)) 实例化 -> clk_slow 跟随 clk，仿真行为与此前一致。
//
// LED 映射：
//   [15:8] Encaps 共享密钥低 8 位 (ss_enc[7:0])
//   [7]    ct_valid 活动   [6] ss_valid 活动
//   [5]    error_seen       [4] kem done    [3] kem busy
//   [2]    测试运行中        [1] POST FAIL  [0] POST PASS
//
//   SW15=1 时 LED 切换到 TVLA 健康页 (Path A 集成):
//   [15:12] fixed-group 计数高半字节  [11:8] random-group 计数高半字节
//   [4] batch_ready(评估中) [3] 至少完成一次评估 [2] degenerate
//   [1] leak_detected (|t|>4.5 粘性健康位)       [0] 采样活动(busy)
//   SW0 = 固定/随机分组选择 (1=固定密钥运行, 0=随机密钥运行)
//   SW1 = batch_restart (两次独立运行之间清批)
//
// 按钮：BTN0 = 完成后软重触发 (重新跑一遍 POST)。
// 版本：v3.0 | 2026-11-09 | Path A: 片上整数 Welch t 检索引擎真正实例化进板级网表
//   v2.0 | 2026-10-25 | Dr. Haibo Yi
// =============================================================================

module ipx_aoi_sec_board_top #(
    parameter integer CLK_DIV = 8   // 100 MHz / CLK_DIV 必须为偶数; 1 = 直通 (仿真)
) (
    input  wire        clk,       // 100 MHz (E3)
    input  wire        rst_n,     // CPU reset (C12), active low
    output reg  [15:0] test_led,  // 16 LEDs
    input  wire [15:0] test_sw,   // 16 slide switches (reserved)
    input  wire [4:0]  test_btn   // 5 push buttons (BTN0 = re-run)
);

    // -------------------------------------------------------------------------
    // 时钟域：100 MHz 晶振 -> CLK_DIV 分频 -> clk_slow (板上 12.5 MHz / 80 ns)
    // -------------------------------------------------------------------------
    // rst_n 的释放在 clk (快) 域同步化，避免 clk_slow 域异步释放。
    reg  rst_s1, rst_s2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_s1 <= 1'b0;
            rst_s2 <= 1'b0;
        end else begin
            rst_s1 <= 1'b1;
            rst_s2 <= rst_s1;
        end
    end
    wire rst_sync = rst_s2;        // 高有效，clk 域同步释放

    // rst_sync 再同步进 clk_slow 域 (第一级异步清零, 之后同步释放)
    reg rst_t1, rst_t2;
    always @(posedge clk_slow or negedge rst_n) begin
        if (!rst_n) begin
            rst_t1 <= 1'b0;
            rst_t2 <= 1'b0;
        end else begin
            rst_t1 <= rst_sync;
            rst_t2 <= rst_t1;
        end
    end
    wire rst_slow_sync = rst_t2;   // clk_slow 域同步复位 (高有效)

    // 偶数分频器 (CLK_DIV/2 拍翻转一次 -> 50% 占空比)。
    // CLK_DIV<=1 (仿真快速模式) 时 clk_slow 直接等于 clk (wire 直连 —— 不可
    // 用 "clk_slow_r <= clk" 延时做法: posedge clk 采样到的 clk 恒为 1,
    // clk_slow 会卡死成常量, 状态机永不推进, 2026-10-25 实测 TIMEOUT)。
    reg [31:0] div_cnt;
    reg        clk_slow_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt    <= 32'd0;
            clk_slow_r <= 1'b0;
        end else if (div_cnt == (CLK_DIV >> 1) - 1) begin
            div_cnt    <= 32'd0;
            clk_slow_r <= ~clk_slow_r;
        end else begin
            div_cnt <= div_cnt + 32'd1;
        end
    end
    wire clk_slow = (CLK_DIV <= 1) ? clk : clk_slow_r;

    // BTN0 同步进 clk_slow 域 (人工按钮，慢信号，两级同步足够)
    reg btn0_s1, btn0_s2;
    always @(posedge clk_slow or negedge rst_n) begin
        if (!rst_n) begin
            btn0_s1 <= 1'b0;
            btn0_s2 <= 1'b0;
        end else begin
            btn0_s1 <= test_btn[0];
            btn0_s2 <= btn0_s1;
        end
    end
    wire btn0 = btn0_s2;

    // -------------------------------------------------------------------------
    // POST 状态机
    // -------------------------------------------------------------------------
    localparam [3:0]
        S_INIT = 4'd0,
        S_LOAD = 4'd1,   // 流式装入 64 B (seed 0..31, msg 32..63)
        S_KG   = 4'd2,   // 发起 KeyGen (1 拍 start 脉冲)
        S_KGW  = 4'd3,   // 等 KeyGen done
        S_ENC  = 4'd4,   // 发起 Encaps
        S_ENCW = 4'd5,   // 等 Encaps done (期间捕获 ss_enc)
        S_DEC  = 4'd6,   // 发起 Decaps (两 op 皆 0 -> 自产 ct)
        S_DECW = 4'd7,   // 等 Decaps done (期间捕获 ss_dec)
        S_CMP  = 4'd8,   // 比较 ss_enc vs ss_dec
        S_DONE = 4'd9;   // 保持结果

    reg [3:0]  st;
    reg [6:0]  li;         // 字节装载索引 0..63
    reg [5:0]  ss_idx;     // ss 字节索引 (6 位以便观察溢出)
    reg        ss_phase;   // 0 = 捕获 Encaps ss, 1 = 捕获 Decaps ss
    reg [7:0]  ss_enc [0:31];
    reg [7:0]  ss_dec [0:31];
    reg        post_pass;
    reg        post_fail;
    reg        error_seen;
    reg [31:0] wdog;       // 全局看门狗 (clk_slow 拍, 防挂死)

    // -------------------------------------------------------------------------
    // kyber_kem 控制信号 (寄存器输出 -> 与 DUT 无竞争)
    // -------------------------------------------------------------------------
    reg        start, op_keygen, op_encaps;
    reg        in_load;
    reg  [7:0] in_addr, in_data;
    reg        ct_load;
    reg  [15:0] ct_in_addr, ct_in_data;
    wire       busy, done, error;
    wire       pk_valid; wire [15:0] pk_addr, pk_data;
    wire       ct_valid; wire [15:0] ct_addr, ct_data;
    wire       ss_valid; wire [7:0]  ss_data;

    // -------------------------------------------------------------------------
    // 片上 ROM：seed[j]=j (0..31)；msg[k]=8'hA5^k (k=0..31)
    //   in_addr 直接等于装载索引 (seed 用 0..31, msg 用 32..63)
    // -------------------------------------------------------------------------
    wire is_seed = (li < 7'd32);
    wire [4:0] k5 = li[4:0];
    always @(*) begin
        in_addr = {1'b0, li};
        in_data = is_seed ? {3'b000, k5} : (8'hA5 ^ {3'b000, k5});
    end

    // -------------------------------------------------------------------------
    // DUT: ML-KEM-768 (kyber_kem) -- 跑 clk_slow (12.5 MHz on board)
    // -------------------------------------------------------------------------
    kyber_kem #(
        .K(3), .N(256), .Q(3329), .BW(16), .ETA(2),
        .DU(10), .DV(4), .R_MOD(2285),
        .SEED_B(32), .MSG_B(32), .SS_B(32)
    ) u_kem (
        .clk        (clk_slow),
        .rst_n      (rst_slow_sync),
        .start      (start),
        .op_keygen  (op_keygen),
        .op_encaps  (op_encaps),
        .busy       (busy),
        .done       (done),
        .error      (error),
        .in_load    (in_load),
        .in_addr    (in_addr),
        .in_data    (in_data),
        .ct_load    (ct_load),
        .ct_in_addr (ct_in_addr),
        .ct_data_in (ct_in_data),
        .pk_valid   (pk_valid),
        .pk_addr    (pk_addr),
        .pk_data    (pk_data),
        .ct_valid   (ct_valid),
        .ct_addr    (ct_addr),
        .ct_data    (ct_data),
        .ss_valid   (ss_valid),
        .ss_data    (ss_data)
    );

    // -------------------------------------------------------------------------
    // v3.0 / Path A: on-chip integer Welch t-test leakage self-monitoring engine
    // -------------------------------------------------------------------------
    // This engine is a genuine leaf of the synthesized board-level netlist; it
    // is no longer testbench-only. It samples an eight-bit Hamming-weight power
    // proxy from the protected (key-dependent) KEM output buses, one sample per
    // clock while the KEM is busy, and publishes a sticky leakage health bit on
    // the LED bank (display page selected by test_sw[15]).
    //
    // Grouping follows Sec. III-D: the host selects the group with test_sw[0]
    // (1 = fixed-secret key-establishment run, 0 = random-secret run) and
    // clears the partial batch with test_sw[1] between runs. The board POST is
    // a deterministic single-vector self-test and therefore does not by itself
    // provide a physical fixed-versus-random trace; as stated in Sec. IV-E the
    // on-chip health bit demonstrates the integer decision logic, not a silicon
    // power measurement. No board current/voltage trace is acquired here.
    // The engine never feeds back into the KEM datapath, so it cannot perturb
    // the POST or the arithmetic critical path.
    // -------------------------------------------------------------------------
    wire [7:0] sc_mon_byte =
          ss_valid ? ss_data[7:0]
        : ct_valid ? ct_data[7:0]
        : pk_valid ? pk_data[7:0]
        : 8'h00;

    // combinational population count -> 8-bit power proxy (0..8)
    reg [3:0] sc_hw;
    integer bi;
    always @(*) begin
        sc_hw = 4'd0;
        for (bi = 0; bi < 8; bi = bi + 1)
            sc_hw = sc_hw + sc_mon_byte[bi];
    end
    wire [5:0] tvla_sample = {2'b0, sc_hw};

    wire        tvla_batch_ready, tvla_batch_done;
    wire        tvla_leak, tvla_degenerate;
    wire [12:0] tvla_cnt_fixed, tvla_cnt_random;
    wire [17:0] tvla_sum_fixed, tvla_sum_random;
    wire [23:0] tvla_sq_fixed,  tvla_sq_random;

    tvla_online #(
        .SAMPLE_W(6),
        .N_LOG2  (12)
    ) u_tvla (
        .clk            (clk_slow),
        .rst_n          (rst_slow_sync),   // 0 = reset in both domains
        .sample_valid   (busy),
        .sample         (tvla_sample),
        .sample_fixed   (test_sw[0]),
        .batch_restart  (test_sw[1]),
        .batch_ready    (tvla_batch_ready),
        .batch_done     (tvla_batch_done),
        .leak_detected  (tvla_leak),
        .degenerate     (tvla_degenerate),
        .cnt_fixed      (tvla_cnt_fixed),
        .cnt_random     (tvla_cnt_random),
        .sum_fixed      (tvla_sum_fixed),
        .sum_random     (tvla_sum_random),
        .sq_fixed       (tvla_sq_fixed),
        .sq_random      (tvla_sq_random)
    );

    // Sticky "at least one evaluation completed" flag for host readout.
    reg tvla_eval_seen;
    always @(posedge clk_slow) begin
        if (!rst_slow_sync)
            tvla_eval_seen <= 1'b0;
        else if (tvla_batch_done)
            tvla_eval_seen <= 1'b1;
    end

    // -------------------------------------------------------------------------
    // 共享密钥捕获：ss_valid 每拍一个字节，按序写入 ss_enc / ss_dec
    // -------------------------------------------------------------------------
    always @(posedge clk_slow) begin
        if (!rst_slow_sync) begin
            ss_idx   <= 6'd0;
            ss_phase <= 1'b0;
        end else begin
            if (st == S_ENC) begin
                ss_phase <= 1'b0;
                ss_idx   <= 6'd0;
            end else if (st == S_DEC) begin
                ss_phase <= 1'b1;
                ss_idx   <= 6'd0;
            end else if (ss_valid && (ss_idx < 6'd32)) begin
                if (ss_phase == 1'b0)
                    ss_enc[ss_idx[4:0]] <= ss_data;
                else
                    ss_dec[ss_idx[4:0]] <= ss_data;
                ss_idx <= ss_idx + 6'd1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 组合比较：diff==0 ⟺ ss_enc == ss_dec (32 B)
    // -------------------------------------------------------------------------
    reg [7:0] diff;
    integer ci;
    always @(*) begin
        diff = 8'h00;
        for (ci = 0; ci < 32; ci = ci + 1)
            diff = diff | (ss_enc[ci] ^ ss_dec[ci]);
    end

    // -------------------------------------------------------------------------
    // 主状态机
    // -------------------------------------------------------------------------
    always @(posedge clk_slow) begin
        if (!rst_slow_sync) begin
            st          <= S_INIT;
            start       <= 1'b0;
            op_keygen   <= 1'b0;
            op_encaps   <= 1'b0;
            in_load     <= 1'b0;
            ct_load     <= 1'b0;
            ct_in_addr  <= 16'd0;
            ct_in_data  <= 16'd0;
            li          <= 7'd0;
            post_pass   <= 1'b0;
            post_fail   <= 1'b0;
            error_seen  <= 1'b0;
            wdog        <= 32'd0;
        end else begin
            // 默认：所有脉冲/装载信号拉低 (单拍语义)
            start     <= 1'b0;
            op_keygen <= 1'b0;
            op_encaps <= 1'b0;
            in_load   <= 1'b0;
            ct_load   <= 1'b0;
            if (error)
                error_seen <= 1'b1;
            wdog <= wdog + 32'd1;

            // BTN0：完成后软重触发
            if (btn0 && (st == S_DONE)) begin
                st         <= S_INIT;
                post_pass  <= 1'b0;
                post_fail  <= 1'b0;
                error_seen <= 1'b0;
                li         <= 7'd0;
                wdog       <= 32'd0;
            end else begin
                case (st)
                    S_INIT: begin
                        li <= 7'd0;
                        st <= S_LOAD;
                    end
                    S_LOAD: begin
                        in_load <= 1'b1;
                        if (li == 7'd63) begin
                            li <= 7'd0;
                            st <= S_KG;
                        end else begin
                            li <= li + 7'd1;
                        end
                    end
                    S_KG: begin
                        start     <= 1'b1;
                        op_keygen <= 1'b1;
                        st        <= S_KGW;
                    end
                    S_KGW: begin
                        if (done)
                            st <= S_ENC;
                    end
                    S_ENC: begin
                        start     <= 1'b1;
                        op_encaps <= 1'b1;
                        st        <= S_ENCW;
                    end
                    S_ENCW: begin
                        if (done)
                            st <= S_DEC;
                    end
                    S_DEC: begin
                        start <= 1'b1;   // op_keygen=0, op_encaps=0 -> Decaps
                        st    <= S_DECW;
                    end
                    S_DECW: begin
                        if (done)
                            st <= S_CMP;
                    end
                    S_CMP: begin
                        if (error_seen) begin
                            post_pass <= 1'b0;
                            post_fail <= 1'b1;
                        end else if (diff == 8'h00) begin
                            post_pass <= 1'b1;
                            post_fail <= 1'b0;
                        end else begin
                            post_pass <= 1'b0;
                            post_fail <= 1'b1;
                        end
                        st <= S_DONE;
                    end
                    S_DONE: begin
                        // 保持结果，等待 BTN0 重触发
                    end
                    default: st <= S_INIT;
                endcase

                // 看门狗：25 M clk_slow 拍 (板上 12.5 MHz -> 2 s) 仍未完成 -> 判失败
                if (wdog > 32'd25_000_000) begin
                    post_pass <= 1'b0;
                    post_fail <= 1'b1;
                    st        <= S_DONE;
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // LED 输出
    // -------------------------------------------------------------------------
    always @(posedge clk_slow) begin
        if (!rst_slow_sync)
            test_led <= 16'd0;
        else if (test_sw[15])
            // TVLA health page (host-selectable; default page is unchanged POST)
            test_led <= {
                tvla_cnt_fixed[11:8],        // [15:12] fixed-group count
                tvla_cnt_random[11:8],       // [11:8]  random-group count
                3'b000,                      // [7:5]   reserved
                tvla_batch_ready,            // [4]     evaluating
                tvla_eval_seen,              // [3]     >=1 evaluation completed
                tvla_degenerate,             // [2]     D == 0
                tvla_leak,                   // [1]     |t| > 4.5 (sticky health bit)
                busy                         // [0]     sampling active
            };
        else
            test_led <= {
                ss_enc[0],                  // [15:8]  Encaps 共享密钥首字节
                ct_valid, ss_valid,          // [7:6]   活动指示
                error_seen, done, busy,      // [5:3]
                (st != S_DONE),              // [2]     测试运行中
                post_fail,                   // [1]     POST FAIL
                post_pass                    // [0]     POST PASS
            };
    end

endmodule
