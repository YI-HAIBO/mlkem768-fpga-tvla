set PROJ "C:/tmp_unified_ntt_kem__1792753686"
set RTL  "$PROJ/rtl"
set XDC  "$PROJ/one.xdc"
set PART "xc7a100tcsg324-1"
set MARK "C:/tmp_unified_ntt_kem__1792753686/mark"
set WORK "$PROJ/proj"
set TOP  "unified_ntt_kem"

proc mk {name} {
    global MARK
    set fh [open "$MARK/$name.txt" w]
    puts $fh "[clock format [clock seconds]]"
    close $fh
}

file mkdir $MARK
mk 00_start

puts "=== Phase A: synth $TOP ==="
if {[file exists $WORK]} { file delete -force $WORK }
file mkdir $WORK
create_project -force $TOP $WORK -part $PART
add_files "$RTL/unified_ntt.v"
add_files "$RTL/$TOP.v"
read_xdc $XDC
mk 10_project

synth_design -top $TOP -part $PART -directive default
mk 20_synth_done

write_checkpoint -force "C:/tmp_unified_ntt_kem__1792753686/synth.dcp"
mk 30_checkpoint

puts "=== Phase A done ==="
exit
