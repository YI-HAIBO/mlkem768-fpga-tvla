`timescale 1ns / 1ps
// Isolate arithmetic: expose the SAME functions as kyber_ntt.v and compare to Python.
module arith_dbg;
    parameter BW = 16;
    parameter Q = 3329;

    function [BW-1:0] montgomery_reduce;
        input [31:0] a;
        reg [15:0]  t_low;
        reg [31:0]  t_signed;
        reg [31:0]  result;
        begin
            t_low    = (a[15:0] * 16'd62209) & 16'hFFFF;
            t_signed = { {16{t_low[15]}}, t_low };
            result   = ($signed(a) - (t_signed * 32'd3329)) >>> 16;
            montgomery_reduce = result[BW-1:0];
        end
    endfunction

    function [BW-1:0] fqmul;
        input [BW-1:0] a;
        input [BW-1:0] b;
        reg [31:0] prod;
        begin
            prod = $signed(a) * $signed(b);
            fqmul = montgomery_reduce(prod);
        end
    endfunction

    function [BW-1:0] barrett_reduce;
        input [BW-1:0] a;
        reg [31:0] v_a;
        reg [31:0] t;
        reg [31:0] result;
        begin
            v_a    = 32'd20159 * $signed(a);
            t      = (v_a + 32'd33554432) >>> 26;
            result = $signed(a) - (t * 32'd3329);
            barrett_reduce = result[BW-1:0];
        end
    endfunction

    integer fd;
    integer i, a, b;
    reg [15:0] ra, rb;
    initial begin
        fd = $fopen("arith_dump.txt", "w");
        // Test fqmul over a grid of signed pairs
        for (a = -2000; a <= 2000; a = a + 137) begin
            for (b = -2000; b <= 2000; b = b + 211) begin
                ra = a[15:0]; rb = b[15:0];
                $fdisplay(fd, "FQ %0d %0d %0d", a, b, $signed(fqmul(ra, rb)));
            end
        end
        // Test barrett
        for (a = -5000; a <= 5000; a = a + 53) begin
            ra = a[15:0];
            $fdisplay(fd, "BR %0d %0d", a, $signed(barrett_reduce(ra)));
        end
        $fclose(fd);
        $display("arith dump done");
        $finish;
    end
endmodule
