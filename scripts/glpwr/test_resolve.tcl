# Test if get_nets can resolve the SAIF-style name.
# Usage: vivado -mode batch -source test_resolve.tcl -tclargs <dcp>
set dcp [lindex $argv 0]
open_checkpoint -part xc7a100tcsg324-1 $dcp
set n [get_nets -hier -quiet "u_kem/sc_va2_reg_i_1311_n_0"]
puts "get_nets -hier exact: [llength $n]"
if {$n ne ""} {
    puts "  NAME=[get_property NAME $n] FULL=[get_property FULL_NAME $n]"
}
set n2 [get_nets -quiet "u_kem/sc_va2_reg_i_1311_n_0"]
puts "get_nets (no -hier) exact: [llength $n2]"
# also check a cell pin resolution
set c [get_cells -hier -quiet "u_kem"]
puts "u_kem cell: [llength $c]"
if {$c ne ""} { puts "  u_kem FULL=[get_property FULL_NAME $c] NAME=[get_property NAME $c] REF=[get_property REF_NAME $c]" }
# does the net have an object path? try -of_objects on the cell
puts "nets connected to u_kem: [llength [get_nets -quiet -of_objects $c]]"
puts "RESOLVE_TEST_DONE"
exit
