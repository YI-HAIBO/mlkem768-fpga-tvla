// =============================================================================
// Keccak-f[1600] permutation — 2-way pipelined (2 clocks per round)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Standard : FIPS 202 Keccak-p[1600, 24]
// State    : 25 lanes of 64 bits (lane index = x + 5*y, x,y in 0..4)
// Used by  : SHAKE-128 / SHAKE-256 (sponge) for ML-KEM-768 KEM
//
// Rotation offsets (x,y) and round constants follow the FIPS 202 / pq-crystals
// fips202 reference. Verified against Python hashlib in tb_shake.v.
//
// PIPELINE (2026-10-16): each round is split into two clock cycles:
//   S_RUN_THETA  : theta (C, D, tA) + rho+pi (B)   ->  store B[]
//   S_RUN_CHI    : chi (nA) + iota (RC)             ->  store A[]
//
// 24 rounds x 2 cycles = 48 cycles per permutation (was 24).
// The critical path of the chi step (3-level AND/XOR/OR tree) is now
// isolated in one cycle, closing the 1.07 ns setup gap at 100 MHz.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module keccak_perm #(
    parameter WIDTH = 1600
)(
    input  wire                clk,
    input  wire                rst_n,
    input  wire                start,
    input  wire [WIDTH-1:0]    state_in,
    output reg  [WIDTH-1:0]    state_out,
    output reg                 done
);

    // 25 lanes, lane[i] = x=i%5, y=i/5
    reg [63:0] A [0:24];
    // Pipeline register: intermediate after theta+rho+pi, before chi+iota
    reg [63:0] B [0:24];
    reg [4:0]  rnd;        // 0..23
    reg [2:0]  st;

    // Module-scope loop temporaries
    integer dst;
    integer src;

    localparam S_IDLE      = 3'd0,
               S_RUN_THETA = 3'd1,
               S_RUN_CHI   = 3'd2,
               S_DONE      = 3'd3;

    // ---- rotation offset for lane (x + 5*y) --------------------------------
    function [5:0] get_rot;
        input [4:0] lane;
        begin
            case (lane)
                5'd0:  get_rot = 6'd0;   5'd1:  get_rot = 6'd1;   5'd2:  get_rot = 6'd62;
                5'd3:  get_rot = 6'd28;  5'd4:  get_rot = 6'd27;
                5'd5:  get_rot = 6'd36;  5'd6:  get_rot = 6'd44;  5'd7:  get_rot = 6'd6;
                5'd8:  get_rot = 6'd55;  5'd9:  get_rot = 6'd20;
                5'd10: get_rot = 6'd3;   5'd11: get_rot = 6'd10;  5'd12: get_rot = 6'd43;
                5'd13: get_rot = 6'd25;  5'd14: get_rot = 6'd39;
                5'd15: get_rot = 6'd41;  5'd16: get_rot = 6'd45;  5'd17: get_rot = 6'd15;
                5'd18: get_rot = 6'd21;  5'd19: get_rot = 6'd8;
                5'd20: get_rot = 6'd18;  5'd21: get_rot = 6'd2;   5'd22: get_rot = 6'd61;
                5'd23: get_rot = 6'd56;  5'd24: get_rot = 6'd14;
                default: get_rot = 6'd0;
            endcase
        end
    endfunction

    // ---- round constant ------------------------------------------------
    function [63:0] get_rc;
        input [4:0] r;
        begin
            case (r)
                5'd0:  get_rc = 64'h0000000000000001;
                5'd1:  get_rc = 64'h0000000000008082;
                5'd2:  get_rc = 64'h800000000000808A;
                5'd3:  get_rc = 64'h8000000080008000;
                5'd4:  get_rc = 64'h000000000000808B;
                5'd5:  get_rc = 64'h0000000080000001;
                5'd6:  get_rc = 64'h8000000080008081;
                5'd7:  get_rc = 64'h8000000000008009;
                5'd8:  get_rc = 64'h000000000000008A;
                5'd9:  get_rc = 64'h0000000000000088;
                5'd10: get_rc = 64'h0000000080008009;
                5'd11: get_rc = 64'h000000008000000A;
                5'd12: get_rc = 64'h000000008000808B;
                5'd13: get_rc = 64'h800000000000008B;
                5'd14: get_rc = 64'h8000000000008089;
                5'd15: get_rc = 64'h8000000000008003;
                5'd16: get_rc = 64'h8000000000008002;
                5'd17: get_rc = 64'h8000000000000080;
                5'd18: get_rc = 64'h000000000000800A;
                5'd19: get_rc = 64'h800000008000000A;
                5'd20: get_rc = 64'h8000000080008081;
                5'd21: get_rc = 64'h8000000000008080;
                5'd22: get_rc = 64'h0000000080000001;
                5'd23: get_rc = 64'h8000000080008008;
                default: get_rc = 64'h0000000000000000;
            endcase
        end
    endfunction

    function [63:0] rotl;
        input [63:0] x;
        input [5:0]  n;
        begin
            if (n == 6'd0) rotl = x;
            else rotl = (x << n) | (x >> (64 - n));
        end
    endfunction

    integer gi;
    // P1-c + pipeline: clock-only sensitivity (synchronous reset).
    always @(posedge clk) begin
        if (!rst_n) begin
            st   <= S_IDLE;
            done  <= 1'b0;
            rnd   <= 5'd0;
        end else begin
            done <= 1'b0;
            case (st)
                S_IDLE: begin
                    if (start) begin
                        for (gi = 0; gi < 25; gi = gi + 1)
                            A[gi] <= state_in[gi*64 +: 64];
                        rnd <= 5'd0;
                        st  <= S_RUN_THETA;
                    end
                end

                // ---------------------------------------------------------
                // S_RUN_THETA : theta (C, D, tA) + rho+pi (B)
                //   Computes the intermediate B[] and stores it.
                //   Critical path: 5-input XOR tree (C) + rotate (D) +
                //   XOR (tA) + rotate+permute (B).  ~2.5 ns on Artix-7.
                // ---------------------------------------------------------
                S_RUN_THETA: begin
                    begin : theta_round
                        reg [63:0] C [0:4];
                        reg [63:0] D [0:4];
                        reg [63:0] tA [0:24];
                        integer x, y, i;
                        // theta
                        for (x = 0; x < 5; x = x + 1)
                            C[x] = A[x] ^ A[x+5] ^ A[x+10] ^ A[x+15] ^ A[x+20];
                        for (x = 0; x < 5; x = x + 1)
                            D[x] = C[(x+4)%5] ^ rotl(C[(x+1)%5], 6'd1);
                        for (i = 0; i < 25; i = i + 1)
                            tA[i] = A[i] ^ D[i%5];
                        // rho + pi : B[y][(2x+3y)%5] = rot(tA[x,y], ROT[x,y])
                        //   dst lane = y + 5*((2x+3y)%5)
                        for (x = 0; x < 5; x = x + 1)
                            for (y = 0; y < 5; y = y + 1) begin
                                src = x + 5*y;
                                dst = y + 5*((2*x + 3*y) % 5);
                                B[dst] <= rotl(tA[src], get_rot(src[4:0]));
                            end
                    end
                    st <= S_RUN_CHI;
                end

                // ---------------------------------------------------------
                // S_RUN_CHI : chi (nA) + iota (RC)
                //   Reads B[], computes nA[], applies round constant,
                //   writes back to A[].
                //   Critical path: NOT -> AND -> XOR (chi) + XOR (iota).
                //   ~1.8 ns on Artix-7.
                // ---------------------------------------------------------
                S_RUN_CHI: begin
                    begin : chi_round
                        reg [63:0] nA [0:24];
                        integer x, y, i;
                        // chi
                        for (x = 0; x < 5; x = x + 1)
                            for (y = 0; y < 5; y = y + 1) begin
                                dst = x + 5*y;
                                nA[dst] = B[dst] ^
                                    ((~B[((x+1)%5) + 5*y]) & B[((x+2)%5) + 5*y]);
                            end
                        // iota
                        nA[0] = nA[0] ^ get_rc(rnd);
                        for (i = 0; i < 25; i = i + 1)
                            A[i] <= nA[i];
                    end
                    if (rnd == 5'd23)
                        st <= S_DONE;
                    else begin
                        rnd <= rnd + 5'd1;
                        st  <= S_RUN_THETA;
                    end
                end

                S_DONE: begin
                    for (gi = 0; gi < 25; gi = gi + 1)
                        state_out[gi*64 +: 64] <= A[gi];
                    done <= 1'b1;
                    st   <= S_IDLE;
                end

                default: st <= S_IDLE;
            endcase
        end
    end

    // silence unused-wire lint
    wire _unused = 1'b0;

endmodule

`default_nettype wire
