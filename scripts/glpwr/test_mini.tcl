# Minimal read_saif test on the DCP with a one-net SAIF.
# Usage: vivado -mode batch -source test_mini.tcl -tclargs <dcp> <saif>
set dcp [lindex $argv 0]
set saif [lindex $argv 1]
open_checkpoint -part xc7a100tcsg324-1 $dcp
create_clock -name clk -period 10.000 [get_ports clk]
# also probe: can we find the net at all?
puts "get_nets -hier *sc_va2_reg_i_1311* : [llength [get_nets -hier -quiet *sc_va2_reg_i_1311*]]"
puts "get_nets u_kem/sc_va2_reg_i_1311_n_0 : [llength [get_nets -quiet u_kem/sc_va2_reg_i_1311_n_0]]"
read_saif -no_strip -out_file [file rootname $saif].mini_unmatched.txt $saif
puts "MINI_TEST_DONE"
exit
