set PROJ "C:/tmp_unified_ntt_kem__1792753686"
set PART "xc7a100tcsg324-1"
set MARK "C:/tmp_unified_ntt_kem__1792753686/mark"
set WORK "$PROJ/rproj"
set CKPT "C:/tmp_unified_ntt_kem__1792753686/synth.dcp"
set RPT  "$PROJ/rpt"

proc mk {name} {
    global MARK
    set fh [open "$MARK/$name.txt" w]
    puts $fh "[clock format [clock seconds]]"
    close $fh
}

file mkdir $MARK
file mkdir $RPT
mk 00_start

puts "=== Phase B: reports from checkpoint ==="
create_project -force reports_proj $WORK -part $PART
open_checkpoint $CKPT
mk 10_opened

report_utilization -file "$RPT/util.rpt"
mk 20_util

report_timing_summary -file "$RPT/timing.rpt" -delay_type min_max -max_paths 5
mk 30_timing

report_timing -file "$RPT/path.rpt" -delay_type max -max_paths 5 -input_pins
mk 40_path

puts "=== Phase B done ==="
exit
