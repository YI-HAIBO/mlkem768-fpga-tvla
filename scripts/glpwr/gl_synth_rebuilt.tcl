catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set OUT "C:/tmp/glpwr_1794120391"
puts "=== gl_synth_rebuilt board_top ==="
read_verilog [list \
    "$OUT/core/kyber_kem.v" \
    "$OUT/core/kyber_poly.v" \
    "$OUT/core/kyber_ntt.v" \
    "$OUT/core/kyber_sampler.v" \
    "$OUT/core/shake.v" \
    "$OUT/core/keccak_perm.v" \
    "$OUT/rtl/ipx_aoi_sec_board_top.v"]
# DEFAULT flatten_hierarchy (rebuilt) — the reference flow that read_saif works with
synth_design -top ipx_aoi_sec_board_top -part xc7a100tcsg324-1
write_checkpoint -force $OUT/gl_synth_rebuilt.dcp
write_verilog -mode funcsim -force $OUT/gl_synth_rebuilt.v
puts "GL_SYNTH_REBUILT_OK"
exit
