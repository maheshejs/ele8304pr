defOutBySection $::env(PNR_NET_DIR)/compteur.place.scandef -noNets -noComps -scanChains
set_ccopt_property buffer_cells [list CLKBUFX20 CLKBUFX16 CLKBUFX12 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX2]
set_ccopt_property inverter_cells [list CLKINVX20 CLKINVX6 CLKINVX8 CLKINVX16 CLKINVX12 CLKINVX4 CLKINVX3 CLKINVX2 CLKINVX1]
set_ccopt_property use_inverters true
set_ccopt_property clock_gating_cells TLATNTSCA*
ccopt_design
optDesign -postCTS
timeDesign -postCTS -outDir $::env(PNR_REP_DIR)/timing
timeDesign -hold -postCTS -outDir $::env(PNR_REP_DIR)/timing
addFiller -cell FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -routeWithSIDriven true
routeDesign -globalDetail
setExtractRCMode -engine postRoute
extractRC
setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both
optDesign -postRoute -setup -hold -outDir $::env(PNR_DIR)/opt
set_verify_drc_mode -report $::env(PNR_REP_DIR)/riscv_core.drc.rpt
verify_drc
verifyConnectivity -type all -report $::env(PNR_REP_DIR)/riscv_core.con.rpt
timeDesign -postRoute -outDir $::env(PNR_REP_DIR)/timing
report_timing > $::env(PNR_REP_DIR)/riscv_core.tim.rpt
cd $::env(PNR_DIR)
createLib riscv_core_oa -attachTech gsclib045_tech
saveDesign -cellview {riscv_core_oa riscv_core layout}
saveNetlist $::env(PNR_NET_DIR)/riscv_core.pnr.v
write_sdf -version 2.1 -target_application verilog -interconn noport $::env(PNR_NET_DIR)/riscv_core.pnr.sdf
