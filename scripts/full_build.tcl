set_db information_level 9
set_db hdl_vhdl_read_version 2008
set_db init_hdl_search_path $::env(SRC_DIR)
set_db init_lib_search_path [list $::env(FE_TIM_LIB) $::env(BE_QRC_LIB) $::env(BE_LEF_LIB)]
read_libs -max_libs slow_vdd1v0_basicCells.lib -min_libs fast_vdd1v0_basicCells.lib
read_physical -lef gsclib045_tech.lef
read_qrc gpdk045.tch
set_db interconnect_mode ple
read_hdl -vhdl { riscv_pkg.vhd riscv_half_adder.vhd riscv_adder.vhd riscv_logic.vhd riscv_alu.vhd riscv_pc.vhd riscv_rf.vhd riscv_if.vhd riscv_id.vhd riscv_ex.vhd riscv_me.vhd riscv_wb.vhd riscv_core.vhd }
elaborate riscv_core
check_design -unresolved
read_sdc $::env(CONST_DIR)/timing.sdc
report_timing -lint > $::env(SYN_REP_DIR)/riscv_core.timing_lint.rpt
report_clocks > $::env(SYN_REP_DIR)/riscv_core.clk.rpt
report_clocks -generated >> $::env(SYN_REP_DIR)/riscv_core.clk.rpt
set_db syn_generic_effort high
syn_generic riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_gen.v
set_db syn_map_effort high
syn_map compteur
syn_map riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_map.v
set_db syn_opt_effort high
syn_opt riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_opt.v
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn.v
write_sdf -nonegchecks -setuphold split -version 2.1 > $::env(SYN_NET_DIR)/riscv_core.syn.sdf
write_sdc > $::env(CONST_DIR)/riscv_core.syn.sdc
report_timing > $::env(SYN_REP_DIR)/riscv_core.syn.timing.rpt
report_timing -lint > $::env(SYN_REP_DIR)/riscv_core.syn.timing.rpt
report_area > $::env(SYN_REP_DIR)/riscv_core.syn.area.rpt
report_gates > $::env(SYN_REP_DIR)/riscv_core.syn.gates.rpt
report_power > $::env(SYN_REP_DIR)/riscv_core.syn.power.rpt

