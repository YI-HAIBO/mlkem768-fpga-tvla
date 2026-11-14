# Test read_saif with different strip options on the same DCP.
# Usage: vivado -mode batch -source test_saif_strip.tcl -tclargs <dcp> <saif>
set dcp [lindex $argv 0]
set saif [lindex $argv 1]
open_checkpoint -part xc7a100tcsg324-1 $dcp
create_clock -name clk -period 10.000 [get_ports clk]

puts "TEST: strip=ipx_aoi_sec_board_top"
read_saif -strip_path ipx_aoi_sec_board_top -out_file [file rootname $saif].u1.txt $saif

puts "TEST: no_strip"
read_saif -no_strip -out_file [file rootname $saif].u2.txt $saif

puts "TEST: strip empty ({} )"
read_saif -strip_path {} -out_file [file rootname $saif].u3.txt $saif

puts "SAIF_STRIP_TEST_DONE"
exit
