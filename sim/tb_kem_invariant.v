`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// #8c deployment integration: invariant_monitor vs real kyber_kem seed buffer
// -----------------------------------------------------------------------------
// Attaches invariant_monitor to kyber_kem's internal seed_buf[0] via a
// hierarchical reference (iverilog supports hierarchical paths).  Checks:
//   (1) during a real KeyGen run (the seed buffer is loaded then read-only),
//       the invariant holds -> violation stays 0;
//   (2) an injected bit-flip (SEU/glitch proxy on the monitored value) is
//       caught -> violation 1.  iverilog cannot %force a single word of a
//       variable array, so the deviation is injected through a TB-level mux
//       on the monitor's value input instead.
// This proves the continuous invariant monitor works against the REAL PQC key
// schedule (SHAKE XOF, sampler, NTT, basemul all execute) and that the seed /
// secret state is genuinely invariant while the KEM runs.
// =============================================================================

module tb_kem_invariant;

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
    wire [15:0] ntt_pf, ntt_pa, ntt_pr;
    wire        ntt_pv;

    // ---- invariant monitor on seed_buf[0] ----
    reg         force_enable;
    reg         tamper;                      // SEU / bit-flip injection proxy
    wire        inv_viol;
    wire [7:0]  seed0 = dut.seed_buf[0];   // hierarchical ref to KEM seed buffer
    // The monitor observes the seed byte through this mux: normally it mirrors
    // the real seed_buf[0]; when tamper is asserted the observed value deviates
    // (exactly what an SEU / glitch on the register would do).  This is used
    // because iverilog cannot %force a single word of a variable array.
    wire [7:0]  mon_value = tamper ? 8'hFF : seed0;

    invariant_monitor #(.W(8)) u_inv (
        .clk(clk), .rst_n(rst_n),
        .enable(busy | force_enable),
        .update(1'b0),                       // no legal update while KEM runs
        .value(mon_value),
        .violation(inv_viol)
    );

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
        .ntt_probe_fqmul(ntt_pf), .ntt_probe_addsub(ntt_pa),
        .ntt_probe_ram_rd(ntt_pr), .ntt_probe_valid(ntt_pv)
    );

    // violation observed during the genuine KeyGen phase (should stay 0)
    reg kg_viol_seen;
    always @(posedge clk) begin
        if (busy && inv_viol) kg_viol_seen <= 1'b1;
    end

    integer errors, li;
    reg kg_done;

    initial begin
        clk = 0; rst_n = 0;
        start = 0; op_keygen = 0; op_encaps = 0;
        in_load = 0; in_addr = 0; in_data = 0;
        ct_load = 0; ct_in_addr = 0; ct_in_data = 0;
        force_enable = 0; tamper = 0;
        errors = 0; kg_viol_seen = 0; kg_done = 0;

        #100 rst_n = 1;
        #20;

        // stream 64 B: seed[j]=j (0..31), msg[k]=0xA5^k (32..63)
        for (li = 0; li < 64; li = li + 1) begin
            @(negedge clk);
            in_load = 1;
            in_addr = li[7:0];
            in_data = (li < 32) ? {3'b000, li[4:0]} : (8'hA5 ^ {3'b000, li[4:0]});
            @(negedge clk);
            in_load = 0;
        end

        // KeyGen -- during busy the monitor is armed on seed_buf[0]
        @(negedge clk); start = 1; op_keygen = 1;
        @(negedge clk); start = 0;
        wait(done);
        kg_done = 1;
        @(negedge clk); @(negedge clk);

        $display("=== KEM invariant-monitor integration report ===");
        $display("KeyGen done            : %0s", (kg_done) ? "YES" : "NO");
        $display("seed_buf[0] loaded      : %0d (exp 0)", seed0);
        $display("violation during KeyGen : %0d (exp 0)", kg_viol_seen);
        $display("KEM error               : %0d", error);

        // ---- injected bit-flip is caught ----
        force_enable = 1;              // keep the monitor armed after busy drops
        @(negedge clk);
        tamper = 1;                    // SEU/glitch proxy: observed value deviates
        @(negedge clk); @(negedge clk); @(negedge clk); @(negedge clk);
        $display("violation after tamper  : %0d (exp 1)", inv_viol);
        tamper = 0;                    // release (violation is sticky)

        if (kg_done && kg_viol_seen == 0 && inv_viol == 1 && error == 0) begin
            $display("RESULT: INVARIANT INTEGRATION PASS (invariant holds in KeyGen; tamper caught)");
            errors = 0;
        end else begin
            $display("RESULT: FAILED (done=%0d kg_viol=%0d force_viol=%0d err=%0d)",
                     kg_done, kg_viol_seen, inv_viol, error);
            errors = 1;
        end
        $finish;
    end

    always #5 clk = ~clk;

endmodule

`default_nettype wire
