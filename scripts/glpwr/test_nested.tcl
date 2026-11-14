# Test read_saif with the NESTED SAIF on the re-elaborated design.
# Usage: vivado -mode batch -source test_nested.tcl -tclargs <netlist.v> <saif>
set netlist [lindex $argv 0]
set saif [lindex $argv 1]
read_verilog $netlist
link_design -part xc7a100tcsg324-1 -top ipx_aoi_sec_board_top
create_clock -name clk -period 10.000 [get_ports clk]
read_saif -no_strip -out_file [file rootname $saif].unmatched_nested.txt $saif
puts "NESTED_SAIF_TEST_DONE"
exit
