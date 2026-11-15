// =============================================================================
// CRYSTALS-Kyber CBD Sampler (Centered Binomial Distribution)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Ring     : Zq[X]/(X^256+1),  q = 3329
//
// CBDη sampler: B^{(η·n)/4} → Rq
//   For Kyber-768: η = 2,  n = 256
//   Input : 128 bytes  (256 × 4 bits = 1024 bits)
//   Output: 256 coefficients, each in {-2, -1, 0, 1, 2}
//
// Algorithm (Kyber spec Algorithm 2):
//   For i = 0..255:
//     a = bits[4i+0] + bits[4i+1]
//     b = bits[4i+2] + bits[4i+3]
//     coeff[i] = a - b
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module kyber_sampler #(
    parameter N  = 256,
    parameter Q  = 3329,
    parameter BW = 16,
    parameter ETA = 2              // η = 2 for Kyber-768
)(
    input  wire                clk,
    input  wire                rst_n,

    input  wire                start,
    output reg                 busy,
    output reg                 done,

    // Byte-array input: (ETA * N / 4) = 128 bytes
    input  wire                load,
    input  wire [6:0]          load_addr,     // 0..127
    input  wire [7:0]          load_data,

    // Coefficient output
    input  wire [7:0]          coeff_addr,
    output wire [BW-1:0]       coeff_data
);

    // Input byte array (128 bytes)
    reg [7:0] bytes [0:127];

    // Output coefficient register file (256 × 16-bit)
    reg [BW-1:0] coeff [0:N-1];

    // FSM
    localparam [1:0] S_IDLE = 2'd0,
                     S_OP   = 2'd1,
                     S_DONE = 2'd2;

    reg [1:0]  state;
    reg [8:0]  idx;            // 9-bit: 0..255 (must NOT wrap at 256)
    reg [6:0]  byte_idx;       // byte index within current coefficient (unused)

    // Module-scope scratch regs for S_OP block (moved out of unnamed begin/end
    // for Vivado Verilog-2005 compatibility)
    reg [7:0]  b0;
    reg [3:0]  a_bits, b_bits;
    reg [2:0]  a_sum, b_sum;
    reg [BW-1:0] result;

    integer gi;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= S_IDLE;
            busy   <= 1'b0;
            done   <= 1'b0;
            idx    <= 9'd0;
            byte_idx <= 7'd0;
            for (gi = 0; gi < 128; gi = gi + 1)
                bytes[gi] <= 8'd0;
            for (gi = 0; gi < N; gi = gi + 1)
                coeff[gi] <= {BW{1'b0}};
        end else begin
            done <= 1'b0;

            // Load interface
            if (load) begin
                bytes[load_addr] <= load_data;
            end

            case (state)
                S_IDLE: begin
                    if (start) begin
                        busy  <= 1'b1;
                        idx   <= 9'd0;
                        state <= S_OP;
                    end
                end

                S_OP: begin
                    if (idx < N) begin
                        // Each coefficient uses 4 bits from 1 byte:
                        //   coeff i uses bits 4i..4i+3
                        //   byte index = i / 2  (2 coefficients per byte)
                        //   For i=0: byte 0, bits 0..3
                        //   For i=1: byte 0, bits 4..7
                        //   For i=2: byte 1, bits 0..3
                        //   For i=3: byte 1, bits 4..7
                        // ...

                        b0 = bytes[idx[7:1]];  // byte index = idx / 2 (= idx >> 1)
                        if (idx[0] == 1'b0) begin
                            a_bits = b0[3:0];   // Even coeff: bits 0..3
                        end else begin
                            a_bits = b0[7:4];   // Odd coeff: bits 4..7
                        end

                        // For η=2: a = bit0 + bit1, b = bit2 + bit3
                        a_sum = 3'b000;
                        b_sum = 3'b000;
                        a_sum = a_sum + a_bits[0];
                        a_sum = a_sum + a_bits[1];
                        b_sum = b_sum + a_bits[2];
                        b_sum = b_sum + a_bits[3];
                        result = $signed(a_sum) - $signed(b_sum);

                        // Sign-extend to BW bits
                        coeff[idx] <= {{BW-3{result[2]}}, result};

                        idx <= idx + 9'd1;
                    end else begin
                        state <= S_DONE;
                    end
                end

                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    assign coeff_data = coeff[coeff_addr];

endmodule

`default_nettype wire
