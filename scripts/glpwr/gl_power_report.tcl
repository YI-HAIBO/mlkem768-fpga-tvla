# Gate-level power report with SAIF annotation on the RTL-synthesis DCP.
#
# ML-KEM adaptation of reference gl_power_v7.tcl:
#   - open gl_synth.dcp (top = ipx_aoi_sec_board_top, xc7a100tcsg324-1)
#   - create_clock 10.000 ns (100 MHz, the signed board frequency; also the
#     TB clock period, so SAIF absolute toggle counts are on-frequency)
#   - report_power baseline (worst-case switching, no SAIF)
#   - read_saif -strip_path <design>  (design name from SAIF header)
#   - report_power annotated -> Design Nets Matched % + dynamic/static power
#
# Why RTL-synthesis DCP: funcsim netlist from the SAME synth run keeps the
# `_i_N_n_M` internal net names, so read_saif annotation reaches ~99%
# (Medium confidence). post_route DCP drops them -> ~6% (Low).
#
# Usage:
#   vivado -mode batch -source gl_power_report.tcl -tclargs <dcp> <saif> <out>

set dcp  [lindex $argv 0]
set saif [lindex $argv 1]
set rpt  [lindex $argv 2]

open_checkpoint -part xc7a100tcsg324-1 $dcp

# 100 MHz signoff / TB frequency.
if {[llength [get_ports -quiet clk]] > 0} {
    create_clock -name clk -period 10.000 [get_ports clk]
} else {
    puts "ERROR: no clk port found in $dcp"; exit 1
}

# Vector-less baseline (worst-case switching on every net).
report_power -no_propagation -file ${rpt}_default.rpt

# Extract design name from SAIF (DESIGN "...") header for -strip_path.
set unmatched [file rootname $saif].unmatched.txt
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
if {$saif_design eq ""} { puts "ERROR: could not read DESIGN from SAIF"; exit 1 }
puts "SAIF design: $saif_design"

read_saif -strip_path $saif_design -out_file $unmatched $saif

report_power -file $rpt -hierarchical_depth 0 -hier all -l 40
report_power -file ${rpt}_hier3.rpt -hierarchical_depth 3 -hier all -l 40

puts "GL_POWER_REPORT_OK"
exit
