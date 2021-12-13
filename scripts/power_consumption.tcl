read_design -cellview [list riscv_core_oa riscv_core layout] -physical_data
set_time_unit -picoseconds
set_analysis_view -update_timing
set_pg_library_mode -extraction_tech_file $::env(BE_QRC_LIB)/gpdk045.tch \
                              -celltype techonly -default_area_cap 0.5   \
                              -decap_cells DECAP* -filler_cells FILL*    \
                              -power_pins {VDD 1.1} -ground_pins VSS
generate_pg_library -output $::env(PNR_DFT_REP_DIR)/power
set_power_analysis_mode -reset
set_power_analysis_mode -method dynamic_vectorbased                                             \
                                  -power_grid_library $::env(PNR_DFT_REP_DIR)/power/techonly.cl \
                                  -corner max                                                   \
                                  -report_stat true                                             \
                                  -create_binary_db true                                        \
                                  -write_static_currents true                                   \
                                  -report_missing_flop_outputs false
set_default_switching_activity -reset
read_activity_file -reset
read_activity_file -format VCD ../../build/riscv_core.pnr.vcd \
                             -scope riscv_top_tb/X_TOP -start 0ps -end 5000000ps
set_dynamic_power_simulation -resolution 100ps
report_power -output $::env(PNR_DFT_REP_DIR)/power -format detailed -report_prefix riscv_core_stat
