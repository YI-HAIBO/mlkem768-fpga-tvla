# Determine hierarchy state of the DCP.
# Usage: vivado -mode batch -source probe_hier.tcl -tclargs <dcp> <outfile>
set dcp [lindex $argv 0]
set out [lindex $argv 1]
open_checkpoint -part xc7a100tcsg324-1 $dcp
set fh [open $out w]

puts $fh "current_design: [current_design]"
puts $fh "top: [get_property TOP [current_design]]"
puts $fh "cells_no_hier: [llength [get_cells -quiet *]]"
puts $fh "cells_hier:    [llength [get_cells -hier -quiet *]]"

puts $fh "=== u_kem cell (NAME/FULL) ==="
foreach c [get_cells -hier -quiet -filter {NAME =~ *u_kem*}] {
    puts $fh "  NAME=[get_property NAME $c] FULL=[get_property FULL_NAME $c] REF=[get_property REF_NAME $c]"
}
puts $fh "=== get_cells u_kem (non-hier, exact) ==="
foreach c [get_cells -quiet -filter {NAME == u_kem}] {
    puts $fh "  NAME=[get_property NAME $c] FULL=[get_property FULL_NAME $c] REF=[get_property REF_NAME $c]"
}
puts $fh "=== nets of u_kem via -of_objects ==="
set uc [get_cells -quiet -filter {NAME == u_kem}]
if {$uc ne ""} {
    puts $fh "  u_kem net count: [llength [get_nets -quiet -of_objects $uc]]"
    puts $fh "  sample:"
    foreach n [get_nets -quiet -of_objects $uc] {
        puts $fh "    NAME=[get_property NAME $n] FULL=[get_property FULL_NAME $n]"
    }
} else {
    puts $fh "  (no u_kem cell found)"
}
close $fh
puts "PROBE_HIER_DONE"
exit
