# 2026-10-24: the synth helper processes (shared-memory IPC) are flaky on this
# host -- runs die silently mid-flow at a phase that moves between attempts,
# and orphan helpers from dead runs corrupt later runs.  Allowed values for
# synth.enableParallelHelperSpawn are all|none|linux|windows (NOT 0/1).
catch {set_param synth.enableParallelHelperSpawn none}
set PROJ "C:/tmp_impl_unified_ntt_sign_t73c_20261024_184714"
set RTL  "$PROJ/rtl"
set XDC  "$PROJ/one.xdc"
set PART "xc7a100tcsg324-1"
set MARK "C:/tmp_impl_unified_ntt_sign_t73c_20261024_184714/mark"
set WORK "$PROJ/proj"
set RPT  "$PROJ/rpt"
set TOP  "unified_ntt_sign"
set BIT  "C:/tmp_impl_unified_ntt_sign_t73c_20261024_184714/impl.bit"

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
add_files "$RTL/unified_ntt.v"
add_files "$RTL/$TOP.v"
read_xdc $XDC
mk 10_project

synth_design -top $TOP -part $PART -directive default
mk 20_synth_done

opt_design
mk 25_opt_done

place_design -directive Explore
mk 30_place_done

# Pre-route timing: tells us whether placement itself already broke timing
report_timing_summary -file "$RPT/pre_route_timing.rpt" -delay_type min_max -max_paths 5
mk 35_pre_route_timing

route_design
mk 40_route_done

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
