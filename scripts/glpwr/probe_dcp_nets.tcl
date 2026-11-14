# Dump DCP net names around sc_va2_reg_i_1311 to compare with funcsim netlist.
# Usage: vivado -mode batch -source probe_dcp_nets.tcl -tclargs <dcp> <outfile>
set dcp [lindex $argv 0]
set out [lindex $argv 1]
open_checkpoint -part xc7a100tcsg324-1 $dcp

set fh [open $out w]
puts $fh "=== all nets under u_kem matching sc_va2_reg_i_1311 ==="
foreach n [get_nets -hier -quiet *sc_va2_reg_i_1311*] {
    puts $fh [get_property FULL_NAME $n]
}
puts $fh "=== count: all hier nets matching sc_va2_reg_i_1311 ==="
puts $fh [llength [get_nets -hier -quiet *sc_va2_reg_i_1311*]]
puts $fh "=== sample: 20 nets under u_kem ==="
set cnt 0
foreach n [get_nets -hier -quiet *] {
    set fn [get_property FULL_NAME $n]
    if {[string match "u_kem/*" $fn]} {
        puts $fh $fn
        incr cnt
        if {$cnt >= 20} break
    }
}
puts $fh "=== total u_kem nets ==="
puts $fh [llength [get_nets -hier -quiet u_kem/*]]
close $fh
puts "PROBE_DONE"
exit
