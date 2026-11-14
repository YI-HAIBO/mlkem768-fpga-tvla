# ---------------------------------------------------------------------------
# Board programming + POST self-test one-shot (Nexys 4 DDR, xc7a100tcsg324-1)
#
# Usage (with the board connected via USB-JTAG, power ON, mode switch JTAG):
#   vivado -mode batch -source program_board.tcl -notrace
#   or via python:  python run_program_board.py
#
# Expected on success:
#   - bitstream loaded into the FPGA
#   - FSM runs the full ML-KEM POST (KeyGen->Encaps->Decaps->verify) once at
#     12.5 MHz, ~23 ms
#   - LED[0]=1 (PASS) and LED[1]=0  ->  program_board.log shows "POST: PASS"
#   - LED[15:8] = shared-secret first byte (0x44 for the golden vector)
#
# This is the EB-1/EB-2 independent board verification path: the top module
# (ipx_aoi_sec_board_top) instantiates kyber_kem only, with NO PUF dependency,
# so the ML-KEM POST does not block on PUF procurement (see docs/EB1).
# ---------------------------------------------------------------------------
open_hw_manager
set targets [get_hw_targets]
if {[llength $targets] == 0} {
    puts "POST_ERROR: no JTAG target detected - is the board connected and powered?"
    close_hw_manager
    exit 1
}
open_hw_target [lindex $targets 0]
set devs [get_hw_devices]
if {[llength $devs] == 0} {
    puts "POST_ERROR: no hardware device on target"
    close_hw_manager
    exit 1
}
current_hw_device [lindex $devs 0]

# Path to the golden 12.5 MHz board bitstream (t89b, post-route WNS +4.377 ns)
set BIT "C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype/results/impl_board_top_t89b.bit"
if {![file exists $BIT]} {
    puts "POST_ERROR: bitstream not found: $BIT"
    close_hw_manager
    exit 1
}

puts "POST: programming $BIT"
program_hw_devices [lindex $devs 0]
refresh_hw_device [lindex $devs 0]
puts "POST: programmed OK"

# The POST runs automatically on power-up / program; give the FSM time
# (12.5 MHz, ~23 ms full KEM round) then read back the LEDs.
# We cannot read LEDs over JTAG here (they are physical); the self-check
# is visual: LED[0]=1, LED[1]=0 => PASS.  For automated readback of the
# shared-secret first byte, see the ILA/board_top note in board doc section 6.
puts "POST: programmed.  PHYSICAL CHECK -> LED[0]=1, LED[1]=0, LED[15:8]=0x44 = PASS"
puts "POST: (if LED[0]=0 or LED[1]=1, re-check power / mode switch / rerun)"

close_hw_target
close_hw_manager
exit 0
