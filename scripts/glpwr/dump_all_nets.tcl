# Dump ALL net names (NAME + FULL_NAME) from the DCP.
# Usage: vivado -mode batch -source dump_all_nets.tcl -tclargs <dcp> <outfile>
set dcp [lindex $argv 0]
set out [lindex $argv 1]
open_checkpoint -part xc7a100tcsg324-1 $dcp
set fh [open $out w]
puts $fh "count=[llength [get_nets -hier -quiet *]]"
set nfull 0
set nflat 0
set total 0
foreach n [get_nets -hier -quiet *] {
    set nm [get_property NAME $n]
    set fn [get_property FULL_NAME $n]
    puts $fh "$nm || $fn"
    incr total
    if {$fn ne ""} { incr nfull }
    if {[string match "*/*" $nm]} { incr nflat }
}
puts $fh "SUMMARY total=$total nonempty_full=$nfull slash_name=$nflat"
close $fh
puts "DUMP_ALL_DONE"
exit
