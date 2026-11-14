# Power report annotating SAIF on the FUNCSIM NETLIST read as the design.
# The SAIF net names come from simulating this exact netlist, so they should
# match 1:1 (no DCP-vs-funcsim rename mismatch).
# Usage: vivado -mode batch -source gl_power_funcsim.tcl \
#           -tclargs <netlist.v> <saif> <outbase>
set netlist [lindex $argv 0]
set saif    [lindex $argv 1]
set rpt     [lindex $argv 2]

read_verilog $netlist
link_design -part xc7a100tcsg324-1 -top ipx_aoi_sec_board_top

# 100 MHz signoff / TB frequency.
if {[llength [get_ports -quiet clk]] > 0} {
    create_clock -name clk -period 10.000 [get_ports clk]
} else {
    puts "ERROR: no clk port"; exit 1
}

# Vector-less baseline (worst-case switching on every net).
report_power -no_propagation -file ${rpt}_default.rpt

# Extract design name from SAIF header for -strip_path.
set unmatched [file rootname $saif].unmatched_funcsim.txt
set saif_design ""
set fh [open $saif r]
while {[gets $fh line] >= 0} {
    if {[string match "*DESIGN*" $line]} {
        set parts [split $line " "]
        foreach p $parts {
            if {[string match {*\"*} $p]} {
                set saif_design [string trim $p {\"\t\r\n()}]
                break
            }
        }
        break
    }
}
close $fh
if {$saif_design eq ""} { puts "ERROR: no DESIGN in SAIF"; exit 1 }
puts "SAIF design: $saif_design"

read_saif -strip_path $saif_design -out_file $unmatched $saif

report_power -file $rpt -hierarchical_depth 0 -hier all -l 40
report_power -file ${rpt}_hier3.rpt -hierarchical_depth 3 -hier all -l 40
puts "GL_POWER_FUNCSIM_OK"
exit
