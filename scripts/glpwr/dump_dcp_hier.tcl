# Dump DCP hierarchy: top module, cells, all hierarchical net names.
# Usage: vivado -mode batch -source dump_dcp_hier.tcl -tclargs <dcp> <outfile>
set dcp [lindex $argv 0]
set out [lindex $argv 1]
open_checkpoint -part xc7a100tcsg324-1 $dcp

set fh [open $out w]
puts $fh "TOP: [get_property TOP [current_design]]"
puts $fh "=== all hierarchical cells ==="
foreach c [get_cells -hier -quiet *] {
    puts $fh "CELL: [get_property FULL_NAME $c] :: [get_property REF_NAME $c]"
}
puts $fh "=== u_kem exists? ==="
puts $fh [llength [get_cells -hier -quiet -filter {NAME =~ *u_kem*}]]
puts $fh "=== nets matching sc_va2_reg_i_1311 (raw) ==="
foreach n [get_nets -hier -quiet *] {
    set fn [get_property NAME $n]
    if {[string match "*sc_va2_reg_i_1311*" $fn]} {
        puts $fh "NET: $fn | full=[get_property FULL_NAME $n] | hier=[get_property HIERARCHICAL_NAME $n]"
    }
}
close $fh
puts "DUMP_DONE"
exit
