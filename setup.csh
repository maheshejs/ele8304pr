#!/usr/bin/env tcsh
#-----------------------------------------------------------------------------
# Project  ELE8304 : Circuits intégrés à très grande échelle
#-----------------------------------------------------------------------------
# File     setup.csh
# Authors  Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# Lab      GRM - Polytechnique Montréal
# Date     <2019-10-01 Tue>
#-----------------------------------------------------------------------------
# Brief    Script de configuration de l'environnement
#          - Environnement CMC
#          - Hiérarchie du projet
#          - kit GPDK45
#          - Outils Cadence & Mentor
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# CONFIGURATION
#-----------------------------------------------------------------------------
setenv CMC_CONFIG   "/CMC/scripts/cmc.2017.12.csh"
setenv PROJECT_HOME `pwd`

# setup.csh doit être lancé depuis la racine du projet
if ( ! -f ${PROJECT_HOME}/setup.csh ) then
    echo "ERROR: setup.csh doit être lancé depuis la racine du projet"
    exit 1
endif

# Vérification de l'environnment CMC
if ( ! -f ${CMC_CONFIG} ) then
    echo "ERROR: L'environnement n'est pas configuré pour les outils de CMC"
    exit 1
endif

source ${CMC_CONFIG}

#-----------------------------------------------------------------------------
# HIERARCHIE DU PROJET
#-----------------------------------------------------------------------------
setenv DOC_DIR      ${PROJECT_HOME}/doc
setenv ASM_DIR      ${PROJECT_HOME}/asm
setenv SRC_DIR      ${PROJECT_HOME}/sources
setenv CONST_DIR    ${PROJECT_HOME}/constraints
setenv SCRIPTS_DIR  ${PROJECT_HOME}/scripts
setenv SIM_DIR      ${PROJECT_HOME}/simulation
setenv IMP_DIR      ${PROJECT_HOME}/implementation
setenv SYN_DIR      ${IMP_DIR}/syn
setenv SYN_NET_DIR  ${SYN_DIR}/netlist
setenv SYN_REP_DIR  ${SYN_DIR}/reports
setenv SYN_LOG_DIR  ${SYN_DIR}/logs
setenv ATPG_DIR     ${IMP_DIR}/atpg
setenv PNR_DIR      ${IMP_DIR}/pnr
setenv PNR_NET_DIR  ${PNR_DIR}/netlist
setenv PNR_REP_DIR  ${PNR_DIR}/reports

#-----------------------------------------------------------------------------
# CONFIGURATION DU KIT GPDK045
#-----------------------------------------------------------------------------
setenv KIT_HOME   ${CMC_HOME}/kits/GPDK45
setenv KIT_SCLIB  ${KIT_HOME}/gsclib045
setenv KIT_IOLIB  ${KIT_HOME}/giolib045
setenv KIT_GPDK   ${KIT_HOME}/gpdk045
setenv KIT_SIMLIB ${CMC_HOME}/simlib/gpdk45

# Front-End
setenv FE_DIR      ${KIT_SCLIB}/gsclib045
setenv FE_VER_LIB  ${FE_DIR}/verilog
setenv FE_VHD_LIB  ${FE_DIR}/vhdl
setenv FE_TIM_LIB  ${FE_DIR}/timing

# Back-End
setenv BE_DIR       ${KIT_SCLIB}/gsclib045
setenv BE_LEF_LIB   ${BE_DIR}/lef
setenv BE_CDB_LIB   ${BE_DIR}/celtic
setenv BE_OA_LIB    ${BE_DIR}/oa22/gsclib045
setenv BE_QRC_LIB   ${BE_DIR}/qrc/qx
setenv BE_GDS_LIB   ${BE_DIR}/gds
setenv BE_SPICE_LIB ${BE_DIR}/spectre/gsclib045

# I/O
setenv IO_DIR      ${KIT_IOLIB}/giolib045
setenv IO_VHDL_LIB ${IO_DIR}/vhdl
setenv IO_VER_LIB  ${IO_DIR}/vlog
setenv IO_LEF_LIB  ${IO_DIR}/lef
setenv IO_OA_LIB   ${IO_DIR}/oa22/giolib045

#-----------------------------------------------------------------------------
# CONFIGURATION DES OUTILS
#-----------------------------------------------------------------------------

# GCC
if ( `echo $PATH | grep -c gcc-9.2.0-mips32` == 0 ) then
    source /users/support/config/gcc/gcc920-mips
endif
if ( `echo $PATH | grep -c gcc-9.2.0-rv32im` == 0 ) then
    source /users/support/config/gcc/gcc920-riscv
endif

# MODELSIM
source ${CMC_HOME}/scripts/mentor.modelsim.10.7c.csh
alias vsim "vsim -64"
alias vsim_help "${MGC_HTML_BROWSER} ${CMC_MNT_MSIM_HOME}/docs/index.html"

# CADENCE
source ${CMC_HOME}/scripts/cadence.2014.12.csh
if ( ! -e /export/tmp/$user ) then
     mkdir -p /export/tmp/$user
endif
setenv DRCTEMPDIR /export/tmp/$user

# GENUS
source ${CMC_HOME}/scripts/cadence.genus18.10.000.csh
alias genus "genus -overwrite"
alias genus_help "${CMC_CDS_GENUS_HOME}/bin/cdnshelp"

# MODUS
source ${CMC_HOME}/scripts/cadence.modus19.12.000.csh
alias modus "modus -overwrite"
alias modus_help "${CMC_CDS_MODUS_HOME}/bin/cdnshelp"

# XCELIUM
source ${CMC_HOME}/scripts/cadence.xceliummain19.03.011.csh
alias xcelium_help "${CMC_CDS_XCELIUM_HOME}/bin/cdnshelp"

# INNOVUS
source ${CMC_HOME}/scripts/cadence.innovus18.10.000.csh
alias innovus "innovus -overwrite -no_logv"
alias innovus_help "${CMC_CDS_INNOVUS_HOME}/bin/cdnshelp"

# VOLTUS & TEMPUS
source ${CMC_HOME}/scripts/cadence.ssv16.16.000.csh
alias voltus "voltus -overwrite -no_logv"
alias tempus "tempus -overwrite -no_logv"
alias voltus_help "${CMC_CDS_SSV_HOME}/bin/cdnshelp"
alias tempus_help "${CMC_CDS_SSV_HOME}/bin/cdnshelp"

# QUANTUS QRC
source ${CMC_HOME}/scripts/cadence.ext19.10.000.csh

# CONFORMAL
source ${CMC_HOME}/scripts/cadence.conformal18.10.100.csh

# PVS
source ${CMC_HOME}/scripts/cadence.pvs16.15.000.csh
