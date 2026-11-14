// =============================================================================
// C4 — PUF-Bound, Unclonable Model (per-chip weight binding)
// -----------------------------------------------------------------------------
// A deployed model can be copied bit-for-bit to another chip.  B/C3 protect the
// computation and the outputs, but nothing stops a weights file from being
// physically cloned.  A PUF fixes that: every chip has a manufacturing-variation
// seed no adversary can reproduce, and the weight file is only readable on the
// chip it was sealed on.
//
// Construction:
//   die_seed[31:0]   the physical variation seed (a real PUF measures its cells;
//                    this module abstracts the PUF as a seed — see the honesty
//                    notes in docs/innovation_C4_puf_bind.md)
//   id = prf(die_seed)                        chip identity, per-chip unique
//   keystream[i] = byte(i & 3) of prf(id ^ i) weighted-file stream
//   seal:  enc[i] = w[i] ^ keystream(i),   tag = id[7:0]
//   open:  w[i]   = enc[i] ^ keystream(i)
//   verify: ram[0x020] == id[7:0] ?
//
// A copy-out attack clones ram[] to another chip whose die_seed differs, so
// its id differs, so its keystream differs, so open returns garbage and
// verify latches verify_fail.  Nothing in the file can be corrected in
// software — the difference is in the silicon.
// =============================================================================
module puf_model_bind (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        cmd_valid,
    input  wire [3:0]  cmd,
    output reg         busy,
    output reg         done,
    output reg         error,          // illegal command (sticky)
    input  wire        wr_valid,
    input  wire [11:0] wr_addr,
    input  wire [7:0]  wr_data,
    input  wire        rd_valid,
    input  wire [11:0] rd_addr,
    output wire [7:0]  rd_data,
    output wire [31:0] id,           // chip identity (continuous from id_r)
    output reg         verify_fail     // sealed blob was not made on this chip
);

    localparam [3:0]
        C_RESET   = 4'h0,
        C_SET_DIE = 4'h1,
        C_ID      = 4'h2,
        C_SEAL    = 4'h3,
        C_OPEN    = 4'h4,
        C_VERIFY  = 4'h5;

    localparam [11:0]
        R_DIE0    = 12'hF00,
        R_ID0     = 12'hF04,
        R_SEALTAG = 12'hF10,
        R_STATUS  = 12'hF11,
        R_N       = 12'hF12;

    localparam [11:0] W_BASE = 12'h000;   // 32-byte weight blob
    localparam [11:0] TAG_A  = 12'h020;   // 1-byte seal tag
    localparam        NB     = 32;

    reg [31:0] die_seed;
    reg [31:0] id_r;
    assign id = id_r;
    reg [7:0]  ram  [0:4095];
    reg [4:0]  i;
    reg        mode;         // 0 = open, 1 = seal
    reg        verify_fail_r;
    localparam [2:0] S_IDLE = 3'd0, S_LOOP = 3'd1, S_TAG = 3'd2;
    reg [2:0] st;
    integer   k;

    // ---- GF(2^8) multiply, 0x11B (shift method, same as B4/C3) -------------
    function [7:0] gf256;
        input [7:0] a, b;
        reg  [7:0] acc, ai;
        integer j;
        begin
            acc = 8'd0; ai = a;
            for (j = 0; j < 8; j = j + 1) begin
                if (b[j]) acc = acc ^ ai;
                if (ai[7]) ai = (ai << 1) ^ 8'h1B;
                else       ai = ai << 1;
                ai = ai & 8'hFF;
            end
            gf256 = acc;
        end
    endfunction

    // ---- PRF: 12 rounds of MixColumn + AddRoundConstant + RotateLeft1 ------
    // NB: b must be a byte ARRAY (reg [7:0] b[0:3]).  A single reg [31:0] b
    // with b[q] = <byte> truncates each MixColumn byte to its LSB.
    function [31:0] prf;
        input [31:0] s;
        reg [31:0] x;
        reg [7:0]  b [0:3];
        integer    r, q;
        begin
            x = s;
            for (r = 0; r < 12; r = r + 1) begin
                for (q = 0; q < 4; q = q + 1) begin
                    b[q] = gf256(8'h02, x[q*8 +: 8]) ^
                           gf256(8'h03, x[((q+1)%4)*8 +: 8]) ^
                           x[((q+2)%4)*8 +: 8] ^
                           x[((q+3)%4)*8 +: 8];
                end
                x = {b[3], b[2], b[1], b[0]};
                // round constant: r mixed into a pseudo-random 32-bit word
                x = x ^ {8'h1B ^ r[7:0], 8'h6C ^ r[7:0], 8'h96 ^ r[7:0], 8'hE8 ^ r[7:0]};
                x = {x[30:0], x[31]};          // rotate left by 1
            end
            prf = x;
        end
    endfunction

    // ---- keystream byte for position i (combinational) ----------------------
    wire [31:0] ks_word;
    wire [7:0]  ks_byte;
    assign ks_word = prf(id_r ^ {27'd0, i});
    assign ks_byte = ks_word[(i & 4'd3) * 8 +: 8];

    // ---- register map -------------------------------------------------------
    reg [7:0] rd_mux;
    assign rd_data = rd_mux;
    always @(*) begin
        rd_mux = 8'd0;
        if (rd_valid) begin
            if (rd_addr < 12'hF00) rd_mux = ram[rd_addr[11:0]];
            else if (rd_addr == R_DIE0)    rd_mux = die_seed[7:0];
            else if (rd_addr == R_DIE0 + 1) rd_mux = die_seed[15:8];
            else if (rd_addr == R_DIE0 + 2) rd_mux = die_seed[23:16];
            else if (rd_addr == R_DIE0 + 3) rd_mux = die_seed[31:24];
            else if (rd_addr == R_ID0)     rd_mux = id_r[7:0];
            else if (rd_addr == R_ID0 + 1) rd_mux = id_r[15:8];
            else if (rd_addr == R_ID0 + 2) rd_mux = id_r[23:16];
            else if (rd_addr == R_ID0 + 3) rd_mux = id_r[31:24];
            else if (rd_addr == R_SEALTAG) rd_mux = ram[TAG_A];
            else if (rd_addr == R_STATUS)  rd_mux = {7'b0, verify_fail_r};
            else if (rd_addr == R_N)       rd_mux = {5'b0, i};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            die_seed <= 32'd0;
            id_r <= 32'd0;
            i <= 5'd0; st <= S_IDLE; mode <= 1'b0;
            busy <= 1'b0; done <= 1'b0; error <= 1'b0;
            verify_fail <= 1'b0; verify_fail_r <= 1'b0;
            for (k = 0; k < 32; k = k + 1) ram[W_BASE + k] <= 8'd0;
            ram[TAG_A] <= 8'd0;
        end else begin
            if (wr_valid) begin
                if (wr_addr < 12'hF00)
                    ram[wr_addr[11:0]] <= wr_data;
                else if (wr_addr == R_DIE0) die_seed[7:0]   <= wr_data;
                else if (wr_addr == R_DIE0 + 1) die_seed[15:8]  <= wr_data;
                else if (wr_addr == R_DIE0 + 2) die_seed[23:16] <= wr_data;
                else if (wr_addr == R_DIE0 + 3) die_seed[31:24] <= wr_data;
            end

            if (cmd_valid && !busy) begin
                case (cmd)
                    C_RESET: begin
                        st <= S_IDLE; i <= 5'd0; mode <= 1'b0;
                        busy <= 1'b0; done <= 1'b1; error <= 1'b0;
                        verify_fail <= 1'b0; verify_fail_r <= 1'b0;
                    end
                    C_SET_DIE: begin
                        id_r <= prf(die_seed);
                        done <= 1'b1;
                    end
                    C_ID: begin
                        id_r <= prf(die_seed);
                        done <= 1'b1;
                    end
                    C_SEAL: begin
                        id_r <= prf(die_seed);
                        i    <= 5'd0;
                        mode <= 1'b1;
                        st   <= S_LOOP;
                        busy <= 1'b1;
                        done <= 1'b0;
                    end
                    C_OPEN: begin
                        id_r <= prf(die_seed);
                        i    <= 5'd0;
                        mode <= 1'b0;
                        st   <= S_LOOP;
                        busy <= 1'b1;
                        done <= 1'b0;
                    end
                    C_VERIFY: begin
                        if (ram[TAG_A] !== id_r[7:0]) begin
                            verify_fail_r <= 1'b1;
                            verify_fail   <= 1'b1;
                        end else begin
                            verify_fail_r <= 1'b0;
                            verify_fail   <= 1'b0;
                        end
                        done <= 1'b1;
                    end
                    default: begin
                        error <= 1'b1;
                    end
                endcase
            end else begin
                // ---- sequential keystream walk (XOR is its own inverse,
                // so SEAL and OPEN share one code path) ----------------------
                if (st == S_LOOP) begin
                    ram[W_BASE + i] <= ram[W_BASE + i] ^ ks_byte;
                    if (i == NB - 1) begin
                        if (mode) begin
                            st <= S_TAG;
                        end else begin
                            st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                        end
                    end else begin
                        i <= i + 5'd1;
                    end
                end else if (st == S_TAG) begin
                    ram[TAG_A] <= id_r[7:0];
                    st <= S_IDLE; busy <= 1'b0; done <= 1'b1;
                end else if (!cmd_valid) begin
                    done <= 1'b0;
                end
            end
        end
    end

endmodule
