# Part 2 of the SAIF power flow: open the synthesized board DCP and run
# report_power with/without SAIF annotation. Vivado v2026.1 report_power
# supports only -file (no -details); activity comes from read_saif.
set WORK "%s"
puts "=== SAIF power part2 ==="
open_checkpoint $WORK/board_synth.dcp
report_power -file $WORK/power_baseline.rpt
set rc [catch {read_saif -no_strip $WORK/power_activity.saif} err]
puts "READ_SAIF_NO_STRIP_RC: $rc $err"
if {$rc != 0} {
  set rc2 [catch {read_saif $WORK/power_activity.saif} err2]
  puts "READ_SAIF_DEFAULT_RC: $rc2 $err2"
}
report_power -file $WORK/power_saif.rpt
puts "=== power part2 done ==="
exit
