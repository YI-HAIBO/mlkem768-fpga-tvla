set PROJ "C:/tmp_unified_ntt_sign__1792758405"
set RTL  "$PROJ/rtl"
set XDC  "$PROJ/one.xdc"
set PART "xc7a100tcsg324-1"
set MARK "C:/tmp_unified_ntt_sign__1792758405/mark"
set WORK "$PROJ/proj"
set RPT  "$PROJ/rpt"
set TOP  "unified_ntt_sign"
set CKPT "C:/tmp_unified_ntt_sign__1792758405/synth.dcp"

proc mk {name} {
    global MARK
    set fh [open "$MARK/$name.txt" w]
    puts $fh "[clock format [clock seconds]]"
    close $fh
}

file mkdir $MARK
file mkdir $RPT
mk 00_start

puts "=== synth $TOP ==="
if {[file exists $WORK]} { file delete -force $WORK }
file mkdir $WORK
create_project -force $TOP $WORK -part $PART
add_files "$RTL/unified_ntt.v"
add_files "$RTL/$TOP.v"
read_xdc $XDC
mk 10_project

synth_design -top $TOP -part $PART -directive default
mk 20_synth_done

report_utilization -file "$RPT/util.rpt"
mk 30_util

report_timing_summary -file "$RPT/timing.rpt" -delay_type min_max -max_paths 5
mk 40_timing

report_timing -file "$RPT/path.rpt" -delay_type max -max_paths 5 -input_pins
mk 50_path

# checkpoint LAST -- if it stalls, the reports are already on disk
write_checkpoint -force $CKPT
mk 60_checkpoint

puts "=== done ==="
exit
