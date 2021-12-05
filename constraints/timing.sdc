#-----------------------------------------------------------------------------
# Project    : ELE8304 : Circuits intégrés à très grande échelle 
#-----------------------------------------------------------------------------
# File       : timing.sdc
# Author     : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# Lab        : grm@polymtl
# Created    : 2018-06-22
# Last update: 2018-09-07
#-----------------------------------------------------------------------------
# Description: Fichier de contraintes
#-----------------------------------------------------------------------------

# Unités par défaut
set_time_unit -picoseconds
set_load_unit -femtofarads

# Point de fonctionnement
set_operating_conditions -max_library PVT_1P1V_0C -min_library PVT_0P9V_125C

# Horloge principale: 65 MHz
set clk "clk"
create_clock -period 15385 -name $clk [get_ports i_clk]

# Incertitudes sur l'horloge: setup = 100ps, hold = 30ps 
set_db [get_clocks $clk] .clock_setup_uncertainty 100
set_db [get_clocks $clk] .clock_hold_uncertainty  30

# Entrées
set_input_delay 300 -clock [get_clocks $clk] [all_inputs]
set_db [all_inputs] .external_driver [vfind [vfind / -libcell BUFX20] -libpin Y]

# Sorties
set_output_delay 300 -clock [get_clocks $clk] [all_outputs]
set_db [all_outputs] .external_pin_cap 1000
