set_db information_level 9
set_db hdl_vhdl_read_version 2008
set_db max_cpus_per_server 4
set_db init_hdl_search_path $::env(SRC_DIR)
set_db init_lib_search_path [list $::env(FE_TIM_LIB) $::env(BE_QRC_LIB) $::env(BE_LEF_LIB)]
read_libs -max_libs fast_vdd1v0_basicCells.lib -min_libs fast_vdd1v0_basicCells.lib
read_physical -lef gsclib045_tech.lef
read_qrc gpdk045.tch
set_db interconnect_mode ple
set_db hdl_error_on_blackbox true
set_db hdl_error_on_latch true
read_hdl -vhdl { riscv_pkg.vhd riscv_half_adder.vhd riscv_adder.vhd riscv_logic.vhd riscv_alu.vhd riscv_pc.vhd riscv_rf.vhd riscv_if.vhd riscv_id.vhd riscv_ex.vhd riscv_me.vhd riscv_wb.vhd riscv_core.vhd }
elaborate riscv_core
check_design -all
read_sdc $::env(CONST_DIR)/timing.sdc
report_timing -lint > $::env(SYN_DFT_REP_DIR)/riscv_core.timing_lint.rpt
report_clocks > $::env(SYN_DFT_REP_DIR)/riscv_core.clk.rpt
report_clocks -generated >> $::env(SYN_DFT_REP_DIR)/riscv_core.clk.rpt
ungroup -all -simple
set_db dft_scan_style muxed_scan
define_shift_enable -active high -create_port i_scan_en
define_test_mode -active high -create_port i_test_mode
define_test_clock -name clk_scan -domain dom_1 -period 12500 i_clk
set_db dft_auto_identify_shift_register true
set_db dft_shift_register_max_length 32
set_db design:riscv_core .dft_scan_map_mode tdrc_pass
set_db design:riscv_core .dft_scan_output_preference auto
set_db design:riscv_core .dft_connect_scan_data_pins_during_mapping loopback
set_db design:riscv_core .dft_connect_shift_enable_during_mapping tie_off
set_db dft_prefix DFT_
report_scan_setup
report_scan_setup > $::env(SYN_DFT_REP_DIR)/dft_scan_setup.conf.rpt
check_dft_rules
check_dft_rules > $::env(SYN_DFT_REP_DIR)/dft_rules.conf.rpt
report_dft_violations > $::env(SYN_DFT_REP_DIR)/dft_violations.conf.rpt
set_db syn_generic_effort high
syn_generic riscv_core
write_hdl > $::env(SYN_DFT_NET_DIR)/riscv_core.syn_gen.v
set_db syn_map_effort high
syn_map riscv_core
write_hdl > $::env(SYN_DFT_NET_DIR)/riscv_core.syn_map.v
define_scan_chain -name chain1 -create_ports -sdi i_tdi -sdo o_tdo
set_db design:riscv_core .dft_min_number_of_scan_chains 1
set_db design:riscv_core .dft_mix_clock_edges_in_scan_chains true
set_db design:riscv_core .dft_max_length_of_scan_chains 10000
connect_scan_chains -auto_create_chains -preview
connect_scan_chains -auto_create_chains
read_sdc $::env(CONST_DIR)/dft_fullscan.non_scan_mode.sdc
set_db syn_opt_effort high
syn_opt riscv_core
write_hdl > $::env(SYN_DFT_NET_DIR)/riscv_core.syn_opt.v
write_hdl > $::env(SYN_DFT_NET_DIR)/riscv_core.syn.v
write_sdf -nonegchecks -setuphold split -version 2.1 > $::env(SYN_DFT_NET_DIR)/riscv_core.syn.sdf
write_sdc > $::env(CONST_DIR)/dft_riscv_core.syn.sdc
write_scandef > $::env(ATPG_DIR)/syn/riscv_core.syn.scandef
write_dft_atpg riscv_core -library $::env(FE_VER_LIB)/*.v \
    -directory $::env(ATPG_DIR)/syn
report_gates       > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.gates.rpt
report_area        > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.area.rpt
report_timing      > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.timing.rpt
report_power       > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.power.rpt
check_design -all  > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.check.rpt
report_clock_gating   > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.clock_gating.rpt
check_dft_rules       > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.dft_rules.rpt
report_dft_violations > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.dft_violations.rpt
report_scan_registers > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.dft_scan_registers.rpt
report_scan_setup     > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.dft_scan_setup.rpt
report_scan_chains    > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.dft_scan_chains.rpt
report_scan_registers > $::env(SYN_DFT_REP_DIR)/riscv_core.syn.dft_scan_registers.rpt
report_scan_chains -summary 
report_qor
