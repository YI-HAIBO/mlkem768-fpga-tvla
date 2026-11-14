`timescale 1ns / 1ps
// =============================================================================
// Testbench: kyber_poly (add/sub), poly_mul (NTT->basemul->INTT), kyber_sampler
// Compares RTL to golden vectors from gen_poly_golden.py (uses the proven
// kyber_ref_exact reference that mirrors pq-crystals/kyber).
//
// NOTE on wait_done: iverilog (IEEE 1364) copies task `input` ports by VALUE
// at entry, so a task like `wait_done(done)` never sees `done` rise and always
// times out. We therefore use a parameterless task that reads module-level
// `done` wires live, selected by the module-level `wsel` register.
// =============================================================================

module tb_kyber_poly;
    reg clk = 0;
    always #5 clk = ~clk;

    // ---------------------------------------------------------------- golden
    reg [15:0] g_a [0:255];
    reg [15:0] g_b [0:255];
    reg [15:0] g_add [0:255];
    reg [15:0] g_sub [0:255];
    reg [15:0] g_mul [0:255];
    reg [7:0]  g_sbytes [0:127];
    reg [15:0] g_samp [0:255];
    initial begin
        $readmemh("sim/gold_a.hex", g_a);
        $readmemh("sim/gold_b.hex", g_b);
        $readmemh("sim/gold_add.hex", g_add);
        $readmemh("sim/gold_sub.hex", g_sub);
        $readmemh("sim/gold_mul.hex", g_mul);
        $readmemh("sim/gold_sbytes.hex", g_sbytes);
        $readmemh("sim/gold_samp.hex", g_samp);
    end

    integer i, k, errors;
    // Selector so the parameterless wait task reads the right module-level
    // `done` wire directly (iverilog copies task `input` ports by value).
    reg [1:0] wsel;
    task wait_done;
        integer guard;
        begin
            guard = 0;
            case (wsel)
                2'd0: while (!p_done  && guard < 100000) begin @(posedge clk); guard = guard + 1; end
                2'd1: while (!n_done  && guard < 100000) begin @(posedge clk); guard = guard + 1; end
                2'd2: while (!bm_done && guard < 100000) begin @(posedge clk); guard = guard + 1; end
                2'd3: while (!s_done  && guard < 100000) begin @(posedge clk); guard = guard + 1; end
                default: begin @(posedge clk); guard = guard + 1; end
            endcase
            if (guard >= 100000) begin $display("ERROR: timeout"); errors = errors + 1; end
        end
    endtask

    // ---------------------------------------------------------- kyber_poly
    reg p_start=0, p_opadd=0, p_busy, p_done;
    reg p_aload=0, p_bload=0; reg [7:0] p_aaddr=0, p_baddr=0; reg [15:0] p_adata=0, p_bdata=0;
    reg [7:0] p_raddr=0; wire [15:0] p_rdata;
    kyber_poly pmod (.clk(clk),.rst_n(rst_n),.start(p_start),.op_add(p_opadd),
        .busy(p_busy),.done(p_done),
        .a_load(p_aload),.a_addr(p_aaddr),.a_data(p_adata),
        .b_load(p_bload),.b_addr(p_baddr),.b_data(p_bdata),
        .r_addr(p_raddr),.r_data(p_rdata));

    // ---------------------------------------------------------- kyber_ntt (single, reused)
    reg n_start=0, n_inv=0, n_busy, n_done;
    reg n_load=0; reg [7:0] n_laddr=0; reg [15:0] n_ldata=0;
    reg [7:0] n_raddr=0; wire [15:0] n_rdata;
    kyber_ntt nmod (.clk(clk),.rst_n(rst_n),.start(n_start),.inverse(n_inv),
        .busy(n_busy),.done(n_done),
        .load(n_load),.load_addr(n_laddr),.load_data(n_ldata),
        .read_addr(n_raddr),.read_data(n_rdata));

    // ---------------------------------------------------------- kyber_basemul
    reg bm_start=0, bm_busy, bm_done;
    reg bm_aload=0, bm_bload=0; reg [7:0] bm_aaddr=0, bm_baddr=0; reg [15:0] bm_adata=0, bm_bdata=0;
    reg [7:0] bm_raddr=0; wire [15:0] bm_rdata;
    kyber_basemul bmod (.clk(clk),.rst_n(rst_n),.start(bm_start),
        .busy(bm_busy),.done(bm_done),
        .a_load(bm_aload),.a_addr(bm_aaddr),.a_data(bm_adata),
        .b_load(bm_bload),.b_addr(bm_baddr),.b_data(bm_bdata),
        .r_addr(bm_raddr),.r_data(bm_rdata));

    // ---------------------------------------------------------- kyber_sampler
    reg s_start=0, s_busy, s_done;
    reg s_load=0; reg [6:0] s_laddr=0; reg [7:0] s_ldata=0;
    reg [7:0] s_raddr=0; wire [15:0] s_rdata;
    kyber_sampler smod (.clk(clk),.rst_n(rst_n),.start(s_start),
        .busy(s_busy),.done(s_done),
        .load(s_load),.load_addr(s_laddr),.load_data(s_ldata),
        .coeff_addr(s_raddr),.coeff_data(s_rdata));

    reg rst_n = 0;
    reg [15:0] buf_a [0:255];
    reg [15:0] buf_b [0:255];
    reg [15:0] buf_c [0:255];

    function [31:0] modq;
        input [15:0] v;
        reg [31:0] r;
        begin
            r = ((($signed(v) % 3329) + 3329) % 3329);
            modq = r;
        end
    endfunction

    initial begin
        errors = 0;
        rst_n = 0; repeat (5) @(posedge clk); rst_n = 1; repeat (2) @(posedge clk);

        // ============================ poly_add / poly_sub ===================
        $display("=== poly_add / poly_sub ===");
        for (i=0;i<256;i=i+1) begin
            p_aaddr=i[7:0]; p_adata=g_a[i]; p_aload=1; @(posedge clk);
            p_baddr=i[7:0]; p_bdata=g_b[i]; p_bload=1; @(posedge clk);
        end
        p_aload=0; p_bload=0;
        // add
        p_opadd=1; p_start=1; @(posedge clk); p_start=0; wsel = 2'd0; wait_done();
        for (i=0;i<256;i=i+1) begin
            p_raddr=i[7:0]; @(posedge clk);
            if (modq(p_rdata) != modq(g_add[i])) begin
                if (errors<6) $display("ADD ERR [%0d] got %0d exp %0d", i, modq(p_rdata), modq(g_add[i]));
                errors=errors+1;
            end
        end
        // sub (polys a,b still loaded)
        p_opadd=0; p_start=1; @(posedge clk); p_start=0; wsel = 2'd0; wait_done();
        for (i=0;i<256;i=i+1) begin
            p_raddr=i[7:0]; @(posedge clk);
            if (modq(p_rdata) != modq(g_sub[i])) begin
                if (errors<6) $display("SUB ERR [%0d] got %0d exp %0d", i, modq(p_rdata), modq(g_sub[i]));
                errors=errors+1;
            end
        end
        if (errors==0) $display("  PASS poly_add/sub vs golden");

        // ============================ poly_mul =============================
        // forward a
        for (i=0;i<256;i=i+1) begin n_laddr=i[7:0]; n_ldata=g_a[i]; n_load=1; @(posedge clk); end
        n_load=0; n_inv=0; n_start=1; @(posedge clk); n_start=0; wsel = 2'd1; wait_done();
        for (i=0;i<256;i=i+1) begin n_raddr=i[7:0]; @(posedge clk); buf_a[i]=n_rdata; end
        // forward b
        for (i=0;i<256;i=i+1) begin n_laddr=i[7:0]; n_ldata=g_b[i]; n_load=1; @(posedge clk); end
        n_load=0; n_inv=0; n_start=1; @(posedge clk); n_start=0; wsel = 2'd1; wait_done();
        for (i=0;i<256;i=i+1) begin n_raddr=i[7:0]; @(posedge clk); buf_b[i]=n_rdata; end
        // basemul(a_ntt, b_ntt)
        for (i=0;i<256;i=i+1) begin bm_aaddr=i[7:0]; bm_adata=buf_a[i]; bm_aload=1; @(posedge clk);
                                 bm_baddr=i[7:0]; bm_bdata=buf_b[i]; bm_bload=1; @(posedge clk); end
        bm_aload=0; bm_bload=0; bm_start=1; @(posedge clk); bm_start=0; wsel = 2'd2; wait_done();
        for (i=0;i<256;i=i+1) begin bm_raddr=i[7:0]; @(posedge clk); buf_c[i]=bm_rdata; end
        // inverse
        for (i=0;i<256;i=i+1) begin n_laddr=i[7:0]; n_ldata=buf_c[i]; n_load=1; @(posedge clk); end
        n_load=0; n_inv=1; n_start=1; @(posedge clk); n_start=0; wsel = 2'd1; wait_done();
        for (i=0;i<256;i=i+1) begin n_raddr=i[7:0]; @(posedge clk); buf_c[i]=n_rdata; end
        // compare to golden mul
        $display("=== poly_mul (NTT->basemul->INTT) ===");
        for (i=0;i<256;i=i+1) begin
            if (modq(buf_c[i]) != modq(g_mul[i])) begin
                if (errors<6) $display("MUL ERR [%0d] got %0d exp %0d", i, modq(buf_c[i]), modq(g_mul[i]));
                errors=errors+1;
            end
        end

        // ============================ kyber_sampler ========================
        $display("=== kyber_sampler (CBD eta=2) ===");
        for (i=0;i<128;i=i+1) begin s_laddr=i[6:0]; s_ldata=g_sbytes[i]; s_load=1; @(posedge clk); end
        s_load=0; s_start=1; @(posedge clk); s_start=0; wsel = 2'd3; wait_done();
        for (i=0;i<256;i=i+1) begin s_raddr=i[7:0]; @(posedge clk);
            if ($signed(s_rdata) != $signed(g_samp[i])) begin
                if (errors<6) $display("SAMP ERR [%0d] got %0d exp %0d", i, $signed(s_rdata), $signed(g_samp[i]));
                errors=errors+1;
            end
        end

        // ============================ summary =============================
        if (errors==0) $display("ALL POLY/SAMPLER TESTS PASSED");
        else $display("TOTAL ERRORS: %0d", errors);
        $finish;
    end
endmodule
