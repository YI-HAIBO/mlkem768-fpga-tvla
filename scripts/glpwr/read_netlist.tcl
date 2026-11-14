# Test reading the cleaned funcsim netlist as a design.
# Usage: vivado -mode batch -source read_netlist.tcl -tclargs <netlist> <outfile>
set netlist [lindex $argv 0]
set out [lindex $argv 1]
read_verilog $netlist
link_design -part xc7a100tcsg324-1 -top ipx_aoi_sec_board_top
set fh [open $out w]
puts $fh "top: [get_property TOP [current_design]]"
puts $fh "cells_hier: [llength [get_cells -hier -quiet *]]"
set u [get_cells -hier -quiet u_kem]
puts $fh "u_kem: [llength $u]"
if {$u ne ""} {
    puts $fh "u_kem FULL=[get_property FULL_NAME $u] NAME=[get_property NAME $u] REF=[get_property REF_NAME $u]"
}
# can we resolve the SAIF-style net by hierarchy?
set n [get_nets -hier -quiet u_kem/sc_va2_reg_i_1311_n_0]
puts $fh "get_nets -hier u_kem/sc_va2_reg_i_1311_n_0: [llength $n]"
if {$n ne ""} { puts $fh "  FULL=[get_property FULL_NAME $n] NAME=[get_property NAME $n]" }
# how many nets have nonempty FULL?
set fullcnt 0
foreach nn [get_nets -hier -quiet *] {
    if {[get_property FULL_NAME $nn] ne ""} { incr fullcnt }
}
puts $fh "nets with nonempty FULL_NAME: $fullcnt"
close $fh
puts "READ_NETLIST_TEST_DONE"
exit
