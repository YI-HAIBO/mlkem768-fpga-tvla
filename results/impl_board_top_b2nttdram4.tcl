# Board-top implementation.  Host workarounds (params preamble) are injected
# on the first executable lines below.
catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set PROJ "C:/tmp_impl_board_b2nttdram4_20261108_103559"
set RTL  "$PROJ/rtl"
set CORE "$PROJ/core"
set XDC  "$PROJ/board.xdc"
set PART "xc7a100tcsg324-1"
set MARK "C:/tmp_impl_board_b2nttdram4_20261108_103559/mark"
set WORK "$PROJ/proj"
set RPT  "$PROJ/rpt"
set TOP  "ipx_aoi_sec_board_top"
set BIT  "C:/tmp_impl_board_b2nttdram4_20261108_103559/board.bit"

proc mk {name} {
    global MARK
    set fh [open "$MARK/$name.txt" w]
    puts $fh "[clock format [clock seconds]]"
    close $fh
}

file mkdir $MARK
file mkdir $RPT
mk 00_start

puts "=== impl $TOP ==="
if {[file exists $WORK]} { file delete -force $WORK }
file mkdir $WORK
create_project -force $TOP $WORK -part $PART
foreach f [glob -nocomplain "$CORE/*.v"] { add_files $f }
foreach f [glob -nocomplain "$RTL/$TOP.v"] { add_files $f }
read_xdc $XDC
# Real board pinout constrains every port, but keep NSTD-1/UCIO-1 demoted so a
# stray unconstrained net cannot abort write_bitstream (rc=1) on an otherwise
# clean flow.
set_property SEVERITY {Warning} [get_drc_checks {NSTD-1 UCIO-1}]
mk 10_project

synth_design -top $TOP -part $PART -directive default
mk 20_synth_done

opt_design
mk 25_opt_done

place_design -directive Explore
mk 30_place_done

# Save the placed design so route_design can be retried standalone.
# The host runs other projects whose runners do a GLOBAL taskkill of
# vivado.exe at irregular intervals (~40-85 min), killing our route;
# the checkpoint lets a route-only retry skip the ~20 min synth+place.
write_checkpoint -force "$PROJ/placed.dcp"
mk 31_checkpoint

report_utilization -file "$RPT/pre_route_util.rpt"
catch {set_param general.maxThreads 1}
report_timing_summary -file "$RPT/pre_route_timing.rpt" -delay_type min_max -max_paths 5
mk 35_pre_route_timing



# route_design died in "Phase 5.1 Global Iteration 0" on this host twice (t75d
# at 100 MHz, t75e at 12.5 MHz) with 27898 overlaps at that point -- not random
# machine jitter but a systematic route-stage failure, so route single-threaded
# and restore the thread cap afterwards for the reports/bitstream.
catch {set_param general.maxThreads 1}
route_design 
mk 40_route_done
catch {set_param general.maxThreads 4}
catch {set_param general.maxThreads 1}
report_timing_summary -file "$RPT/post_route_timing.rpt" -delay_type min_max -max_paths 5
mk 50_post_timing

report_utilization -file "$RPT/util.rpt"
mk 55_post_util

report_drc -file "$RPT/drc.rpt"
mk 60_drc

write_bitstream -force $BIT
mk 70_bitstream

puts "=== done ==="
exit
