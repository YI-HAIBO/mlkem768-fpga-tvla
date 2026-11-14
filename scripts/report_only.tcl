# Read existing project and generate reports
open_project "C:/tmp_top_kem2_1792291206/proj/top_kem.xpr"
report_timing -max_paths 5 -file "C:/tmp_top_kem2_1792291206/timing.rpt"
report_utilization -file "C:/tmp_top_kem2_1792291206/util.rpt"
report_timing_summary -file "C:/tmp_top_kem2_1792291206/timing_summary.rpt"
puts "REPORTS_GENERATED"
exit
