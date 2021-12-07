 
 
# Template script intended to jumpstart the user to run Modus Automatic Test Pattern Generation (ATPG) software.
 
#  Generated by Genus(TM) Synthesis Solution 18.10-p003_1
 
# Modus ATPG Script
 
#-------------------------------------------------------------------------------
# INITIALIZE VARIABLES
#-------------------------------------------------------------------------------
# "set_db workdir" is recommended to be set first to initialize where the Database is to be located
# WORKDIR Tcl variable can be used in the script to reference file locations
set    WORKDIR /users/Cours/ele8304/12/Labs/implement/lab2/implementation/atpg/syn;                                         # Define Tcl variable
set_db workdir $WORKDIR;                                  # Specify the directory for the ATPG database
 
# Configure the database
set_option stdout     summary;                                # Only print a summary for each command to the terminal
                                                          # Logs contain the complete command output
set ::env(CDS_LIC_REPORT) yes
# test_checks.tcl provides check_log proc to stop script on message severity
source  $::env(Install_Dir)/bin/64bit/test_checks.tcl;    # Load test_checks.tcl from Modus installation - provides check_log below
set STOP_ON_MSG_SEV ERROR;                                # Messagee severity for check_log to stop at (ERROR, WARNING_SEVERE, WARNING)
set LOGDIR          $WORKDIR/testresults/logs;            # Location of logs for check_log
 
file delete -force $WORKDIR/tbdata;                       # Delete Test Database
file delete -force $WORKDIR/testresults;                  # Delete Test Output Files/Logs
 
 
 
#-------------------------------------------------------------------------------
# BUILD THE LOGIC MODEL
#-------------------------------------------------------------------------------
build_model \
    -cell	 riscv_core \
    -techlib	 /CMC/kits/GPDK45/gsclib045/gsclib045/verilog/*.v \
    -designsource	 $WORKDIR/riscv_core.test_netlist.v \
    -allowmissingmodules	 no \

check_log log_build_model
 
#-------------------------------------------------------------------------------
# BUILD THE TEST MODEL
#-------------------------------------------------------------------------------
build_testmode \
    -testmode	 FULLSCAN \
    -assignfile	 $WORKDIR/riscv_core.FULLSCAN.pinassign \
    -modedef	 FULLSCAN \
 
check_log log_build_testmode_FULLSCAN
 
#-------------------------------------------------------------------------------
# REPORT THE TEST MODEL
#-------------------------------------------------------------------------------
report_test_structures \
    -testmode	 FULLSCAN \
 
check_log log_report_test_structures_FULLSCAN
 
#-------------------------------------------------------------------------------
# VERIFY THE TEST MODEL
#-------------------------------------------------------------------------------
verify_test_structures \
    -messagecount	 TSV-016=10,TSV-024=10,TSV-315=10,TSV-027=10 \
    -testmode	 FULLSCAN \
 
check_log log_verify_test_structures_FULLSCAN
 
#-------------------------------------------------------------------------------
# BUILD THE FAULT MODEL
#-------------------------------------------------------------------------------
build_faultmodel \
    -includedynamic	 no \
 
check_log log_build_faultmodel
 
#-------------------------------------------------------------------------------
# ATPG - TEST GENERATION
#-------------------------------------------------------------------------------
create_logic_tests \
    -experiment	 riscv_core_atpg \
    -testmode	 FULLSCAN \

check_log log_create_logic_tests_FULLSCAN_riscv_core_atpg

#-------------------------------------------------------------------------------
# ATPG - Report the Scan and Capture Switching
#-------------------------------------------------------------------------------
write_toggle_gram \
    -experiment	 riscv_core_atpg \
    -testmode	 FULLSCAN \

#-------------------------------------------------------------------------------
# VERILOG VECTORS - For PARALLEL Simulation
#-------------------------------------------------------------------------------
write_vectors \
    -inexperiment	 riscv_core_atpg \
    -testmode	 FULLSCAN \
    -language	 verilog \
    -scanformat	 parallel \

check_log log_write_vectors_FULLSCAN_riscv_core_atpg

#-------------------------------------------------------------------------------
# ATPG - Save Experiment to the Master Database for the Testmode
#-------------------------------------------------------------------------------
commit_tests \
    -inexperiment	 riscv_core_atpg \
    -testmode	 FULLSCAN 

check_log log_commit_tests_FULLSCAN_riscv_core_atpg

exit
