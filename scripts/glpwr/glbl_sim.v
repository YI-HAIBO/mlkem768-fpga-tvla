//-----------------------------------------------------------------------------
// Minimal glbl stub for Icarus gate-level simulation (ML-KEM board_top).
//
// Vivado's write_verilog -mode funcsim emits a `module glbl` (JTAG/startup)
// that does NOT declare GSR/GTS; the UNISIM models bind onto `glbl.GSR` /
// `glbl.GTS`, so Icarus aborts with "Unable to bind wire/reg/memory `glbl.GSR'".
// run_gl_sim.py renames the netlist's glbl to glbl_xilinx_startup and compiles
// this file instead.
//
// GSR: MUST pulse 1 -> 0 at time 0.  The FDRE/FDCE/FDSE/FDPE funcsim models do
//   `tri0 glblGSR = glbl.GSR;  always @(glblGSR) if (glblGSR) assign Q_out=INIT;
//    else deassign Q_out;`
//   With GSR held LOW (the old ML-DSA recipe), `deassign Q_out` leaves every
//   FF UNINITIALISED -> Q_out = X -> X floods the datapath -> the KEM FSM hangs
//   (busy=1 forever, done/post_pass never assert; observed 304k X lines).
//   A power-up GSR pulse 1->0 forces every FF to its INIT value (real hardware
//   does exactly this at power-on).  #100 (1ns/1ps timescale -> 100 ns) covers
//   the TB's 5-cycle rst_n window (50 ns) and releases after reset is done.
//
// GTS: held LOW (outputs enabled).
//-----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module glbl;

    reg  GSR;   // global set/reset: power-up pulse, then released
    reg  GTS;   // global output tri-state, held low

    initial begin
        GSR = 1'b1;          // power-on: force all FFs to INIT (0)
        GTS = 1'b0;
        #100 GSR = 1'b0;     // release after the 5-cycle rst_n window
    end

endmodule
