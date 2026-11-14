`timescale 1ns / 1ps

// Gate-level wrapper so tb_gl_board is an INSTANCE (not a root) and the glbl
// stub is instantiated at the root -- both required by Icarus:
//   - `-s tb_gl_board_top` makes the wrapper the elaborated root; `module glbl`
//     is then INSTANTIATED here (name `glbl`), which the UNISIMs' `glbl.GSR`
//     / `glbl.GTS` references bind to (otherwise "Unable to bind ... glbl.GSR").
//   - With the TB as an instance, $dumpvars(0, tb_gl_board.dut) paths resolve
//     and the VCD gets real dut toggles.

module tb_gl_board_top;

    tb_gl_board tb();
    glbl        glbl();

endmodule
