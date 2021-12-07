set init_oa_ref_lib [list gsclib045_tech gsclib045 gpdk045 giolib045]
set init_verilog $::env(SYN_DFT_NET_DIR)/riscv_core.syn.v
set init_design_settop 1
set init_top_cell riscv_core
set init_gnd_net VSS
set init_pwr_net VDD
set init_mmmc_file $::env(CONST_DIR)/mmmc.tcl
init_design
floorPlan -site CoreSite -r 0.9 0.6 1 1 1 1
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type tiehi -inst * -override
globalNetConnect VSS -type tielo -inst * -override
addStripe -nets VDD -layer Metal1 -direction vertical -width 0.6 -number_of_sets 1 -start_from left -start_offset -0.8
addStripe -nets VSS -layer Metal1 -direction vertical -width 0.6 -number_of_sets 1 -start_from right -start_offset -0.8
sroute -nets { VDD VSS } -connect { corePin floatingStripe }
setPinAssignMode -pinEditInBatch true
editPin -pin [list i_clk i_rstn ] -edge 1 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise \
	-pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list o_imem_en  o_imem_addr[0]  o_imem_addr[1]  o_imem_addr[2]  o_imem_addr[3]  o_imem_addr[4] \
	o_imem_addr[5]  o_imem_addr[6]  o_imem_addr[7]  o_imem_addr[8]] -edge 2 -layer 3 -spreadType SIDE \
	-offsetEnd 2 -offsetStart 2 -spreadDirection clockwise -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list o_dmem_en o_dmem_we  o_dmem_addr[0]  o_dmem_addr[1]  o_dmem_addr[2]  o_dmem_addr[3]  \
	o_dmem_addr[4]  o_dmem_addr[5]  o_dmem_addr[6]  o_dmem_addr[7]  o_dmem_addr[8]  o_dmem_write[0]  \
	o_dmem_write[1]  o_dmem_write[2]  o_dmem_write[3]  o_dmem_write[4] o_dmem_write[5]  o_dmem_write[6]  \
	o_dmem_write[7]  o_dmem_write[8]  o_dmem_write[9]  o_dmem_write[10]  o_dmem_write[11]  o_dmem_write[12]  \
	o_dmem_write[13]  o_dmem_write[14]  o_dmem_write[15]  o_dmem_write[16]  o_dmem_write[17]  o_dmem_write[18]  \
	o_dmem_write[19]  o_dmem_write[20]  o_dmem_write[21]  o_dmem_write[22]  o_dmem_write[23]  o_dmem_write[24]  \
	o_dmem_write[25]  o_dmem_write[26]  o_dmem_write[27]  o_dmem_write[28]  o_dmem_write[29]  o_dmem_write[30]  \
	o_dmem_write[31]] -edge 3 -layer 4 -spreadType SIDE -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise \
	-pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list i_dmem_read[0]  i_dmem_read[1]  i_dmem_read[2]  i_dmem_read[3]  i_dmem_read[4]  i_dmem_read[5]  \
	i_dmem_read[6]  i_dmem_read[7]  i_dmem_read[8]  i_dmem_read[9]  i_dmem_read[10]  i_dmem_read[11]  \
	i_dmem_read[12]  i_dmem_read[13]  i_dmem_read[14]  i_dmem_read[15]  i_dmem_read[16]  i_dmem_read[17]  \
	i_dmem_read[18]  i_dmem_read[19]  i_dmem_read[20]  i_dmem_read[21]  i_dmem_read[22]  i_dmem_read[23]  \
	i_dmem_read[24]  i_dmem_read[25]  i_dmem_read[26]  i_dmem_read[27]  i_dmem_read[28]  i_dmem_read[29]  \
	i_dmem_read[30]  i_dmem_read[31]  i_imem_read[1]  i_imem_read[2]  i_imem_read[3]  i_imem_read[4]  i_imem_read[5]  \
	i_imem_read[6]  i_imem_read[7]  i_imem_read[8]  i_imem_read[9]  i_imem_read[10]  i_imem_read[11]  i_imem_read[12]  \
	i_imem_read[13]  i_imem_read[14]  i_imem_read[15]  i_imem_read[16]  i_imem_read[17]  i_imem_read[18]  i_imem_read[19]  \
	i_imem_read[20]  i_imem_read[21]  i_imem_read[22]  i_imem_read[23]  i_imem_read[24]  i_imem_read[25]  i_imem_read[26]  \
	i_imem_read[27]  i_imem_read[28]  i_imem_read[29]  i_imem_read[30]  i_imem_read[31]] -edge 0 -layer 4 -spreadType SIDE \
	-offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
timeDesign -prePlace -outDir $::env(PNR_DFT_REP_DIR)/timing
setDesignMode -process 45 -flowEffort standard
setPlaceMode -timingDriven true -place_global_cong_effort auto -place_global_reorder_scan true
setPlaceMode -place_global_reorder_scan true
defIn $::env(SYN_DFT_NET_DIR)/riscv_core.syn.scandef
setScanReorderMode -compLogic true
setOptMode -drcMargin 0.5
place_opt_design
defOutBySection $::env(PNR_DFT_NET_DIR)/riscv_core.place.scandef -noNets -noComps -scanChains
set_ccopt_property buffer_cells [list CLKBUFX20 CLKBUFX16 CLKBUFX12 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX2]
set_ccopt_property inverter_cells [list CLKINVX20 CLKINVX6 CLKINVX8 CLKINVX16 CLKINVX12 CLKINVX4 CLKINVX3 CLKINVX2 CLKINVX1]
set_ccopt_property use_inverters true
set_ccopt_property clock_gating_cells TLATNTSCA*
ccopt_design
optDesign -postCTS
timeDesign -postCTS -outDir $::env(PNR_DFT_REP_DIR)/timing
timeDesign -hold -postCTS -outDir $::env(PNR_DFT_REP_DIR)/timing
addFiller -cell FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -routeWithSIDriven true
routeDesign -globalDetail
setExtractRCMode -engine postRoute
extractRC
setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both
optDesign -postRoute -setup -hold -outDir $::env(PNR_DFT_DIR)/opt
set_verify_drc_mode -report $::env(PNR_DFT_REP_DIR)/riscv_core.drc.rpt
verify_drc
verifyConnectivity -type all -report $::env(PNR_DFT_REP_DIR)/riscv_core.con.rpt
timeDesign -postRoute -outDir $::env(PNR_DFT_REP_DIR)/timing
report_timing > $::env(PNR_DFT_REP_DIR)/riscv_core.tim.rpt
cd $::env(PNR_DFT_DIR)
createLib riscv_core_oa -attachTech gsclib045_tech
saveDesign -cellview {riscv_core_oa riscv_core layout}
saveNetlist $::env(PNR_DFT_NET_DIR)/riscv_core.pnr.v
write_sdf -version 2.1 -target_application verilog -interconn noport $::env(PNR_DFT_NET_DIR)/riscv_core.pnr.sdf
