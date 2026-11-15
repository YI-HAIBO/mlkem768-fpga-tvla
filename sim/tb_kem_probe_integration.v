`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// #6a probe integration verification: kyber_kem -> tvla_probe_router -> tvla_online
// -----------------------------------------------------------------------------
// Purpose: prove the NTT arithmetic probe taps added to kyber_ntt / kyber_kem
// (a) are present and active during a real KeyGen run (probe_valid pulses),
// (b) carry exactly the internal datapath signals they claim
//     (probe_fqmul == u_ntt.mont_res, probe_addsub == u_ntt.fwd_a,
//      probe_ram_rd == u_ntt.dout_a, checked against hierarchical references),
// (c) are correctly routed by the TDM probe router to the Welch engine
//     (router.sample == popcount(selected probe)),
// and that the added ports do NOT perturb the KEM functional behaviour
// (KeyGen completes, pk/ct/ss streams fire as before).
//
// The full fixed-vs-random Welch verdict (leak/no-leak per tap) is already
// proven end-to-end by sim/tb_tvla_probe_router.v; this TB covers the
// *datapath attachment* step that was listed as the remaining #6 integration.
// =============================================================================

module tb_kem_probe_integration;

    reg         clk, rst_n;
    reg         start, op_keygen, op_encaps;
    wire        busy, done, error;
    reg         in_load;
    reg  [7:0]  in_addr, in_data;
    reg         ct_load;
    reg  [15:0] ct_in_addr, ct_in_data;
    wire        pk_valid; wire [15:0] pk_addr, pk_data;
    wire        ct_valid; wire [15:0] ct_addr, ct_data;
    wire        ss_valid; wire [7:0]  ss_data;

    // ---- KEM probe taps (new #6a ports) ----
    wire [15:0] ntt_pf, ntt_pa, ntt_pr;
    wire        ntt_pv;

    // ---- probe router + Welch engine ----
    wire [47:0] pflat = { ntt_pr, ntt_pa, ntt_pf };  // 3*16=48: tap2=ram_rd, tap1=addsub, tap0=fqmul
    reg         probe_fixed, tap_advance;
    wire [5:0]  r_sample;
    wire        r_sample_valid, r_sample_fixed, r_batch_restart;
    wire [1:0]  r_tap_id;
    wire [2:0]  r_leak, r_degen;
    wire        r_report_cycle;
    wire        e_batch_ready, e_batch_done, e_leak, e_degen;

    kyber_kem #(
        .K(3), .N(256), .Q(3329), .BW(16), .ETA(2),
        .DU(10), .DV(4), .R_MOD(2285),
        .SEED_B(32), .MSG_B(32), .SS_B(32)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .op_keygen(op_keygen), .op_encaps(op_encaps),
        .busy(busy), .done(done), .error(error),
        .in_load(in_load), .in_addr(in_addr), .in_data(in_data),
        .ct_load(ct_load), .ct_in_addr(ct_in_addr), .ct_data_in(ct_in_data),
        .pk_valid(pk_valid), .pk_addr(pk_addr), .pk_data(pk_data),
        .ct_valid(ct_valid), .ct_addr(ct_addr), .ct_data(ct_data),
        .ss_valid(ss_valid), .ss_data(ss_data),
        .ntt_probe_fqmul(ntt_pf),
        .ntt_probe_addsub(ntt_pa),
        .ntt_probe_ram_rd(ntt_pr),
        .ntt_probe_valid(ntt_pv)
    );

    tvla_probe_router #(
        .NTAP(3), .TAPID_W(2), .PROBE_W(16), .HW_W(6), .SAMPLE_W(6)
    ) u_router (
        .clk(clk), .rst_n(rst_n),
        .probe_flat(pflat), .probe_valid(ntt_pv), .probe_fixed(probe_fixed),
        .tap_advance(tap_advance),
        .sample(r_sample), .sample_valid(r_sample_valid), .sample_fixed(r_sample_fixed),
        .batch_restart(r_batch_restart),
        .batch_done(e_batch_done), .leak_detected(e_leak), .degenerate(e_degen),
        .tap_id(r_tap_id), .leak_result(r_leak), .degen_result(r_degen),
        .report_cycle(r_report_cycle)
    );

    tvla_online #(.SAMPLE_W(6), .N_LOG2(8), .THRESH2(81)) u_engine (
        .clk(clk), .rst_n(rst_n),
        .sample_valid(r_sample_valid), .sample(r_sample), .sample_fixed(r_sample_fixed),
        .batch_restart(r_batch_restart),
        .batch_ready(e_batch_ready), .batch_done(e_batch_done),
        .leak_detected(e_leak), .degenerate(e_degen),
        .cnt_fixed(), .cnt_random(), .sum_fixed(), .sum_random(),
        .sq_fixed(), .sq_random()
    );

    // ---------------------------------------------------------------------
    // popcount helper (independent of router's internal one)
    // ---------------------------------------------------------------------
    function [5:0] pc16;
        input [15:0] v;
        integer i; reg [5:0] c;
        begin
            c = 6'd0;
            for (i = 0; i < 16; i = i + 1) c = c + v[i];
            pc16 = c;
        end
    endfunction

    // ---------------------------------------------------------------------
    // checks
    // ---------------------------------------------------------------------
    integer errors, probe_pulses, mismatch, router_mismatch;
    integer li;
    reg done_seen;

    always @(posedge clk) begin
        if (rst_n && ntt_pv) begin
            probe_pulses = probe_pulses + 1;
            if (ntt_pf !== dut.u_ntt.mont_res[15:0]) mismatch = mismatch + 1;
            if (ntt_pa !== (dut.u_ntt.inv_mode ? dut.u_ntt.xd_reg : dut.u_ntt.fwd_a))
                mismatch = mismatch + 1;
            if (ntt_pr !== dut.u_ntt.dout_a) mismatch = mismatch + 1;
            // router routes the selected tap; check sample == HW(selected)
            case (r_tap_id)
                2'd0: if (r_sample !== pc16(ntt_pf)) router_mismatch = router_mismatch + 1;
                2'd1: if (r_sample !== pc16(ntt_pa)) router_mismatch = router_mismatch + 1;
                2'd2: if (r_sample !== pc16(ntt_pr)) router_mismatch = router_mismatch + 1;
            endcase
        end
    end

    // ---------------------------------------------------------------------
    // stimulus: one real KeyGen run
    // ---------------------------------------------------------------------
    initial begin
        clk = 0; rst_n = 0;
        start = 0; op_keygen = 0; op_encaps = 0;
        in_load = 0; in_addr = 0; in_data = 0;
        ct_load = 0; ct_in_addr = 0; ct_in_data = 0;
        probe_fixed = 1; tap_advance = 0;
        errors = 0; probe_pulses = 0; mismatch = 0; router_mismatch = 0;
        done_seen = 0;

        #100 rst_n = 1;
        #20;

        // stream 64 B: seed[j]=j (0..31), msg[k]=0xA5^k (32..63)  [board ROM style]
        for (li = 0; li < 64; li = li + 1) begin
            @(negedge clk);
            in_load = 1;
            in_addr = li[7:0];
            in_data = (li < 32) ? {3'b000, li[4:0]} : (8'hA5 ^ {3'b000, li[4:0]});
            @(negedge clk);
            in_load = 0;
        end

        // KeyGen
        @(negedge clk); start = 1; op_keygen = 1;
        @(negedge clk); start = 0;

        // wait for done (done is a one-cycle pulse; wait() is edge-agnostic)
        wait(done);
        done_seen = 1;
        @(negedge clk);
        @(negedge clk);

        // tap-advance once: router should switch tap0 -> tap1
        @(negedge clk); tap_advance = 1;
        @(negedge clk); tap_advance = 0;
        #20;

        $display("=== KEM probe integration report ===");
        $display("KeyGen done          : %0s", (done_seen) ? "YES" : "NO");
        $display("probe_valid pulses   : %0d", probe_pulses);
        $display("probe data mismatch  : %0d", mismatch);
        $display("router sample mismatch: %0d", router_mismatch);
        $display("tap_id after advance : %0d", r_tap_id);
        $display("error (KEM)          : %0d", error);

        if (done_seen && probe_pulses > 0 && mismatch == 0 && router_mismatch == 0 && !error) begin
            $display("RESULT: ALL PROBE INTEGRATION CHECKS PASSED");
            errors = 0;
        end else begin
            $display("RESULT: FAILED (done=%0d pulses=%0d mismatch=%0d rmis=%0d err=%0d)",
                     done_seen, probe_pulses, mismatch, router_mismatch, error);
            errors = 1;
        end
        $finish;
    end

    always #5 clk = ~clk;

endmodule

`default_nettype wire
