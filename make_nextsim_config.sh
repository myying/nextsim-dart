#!/bin/bash

. $CONFIG_FILE

cat << EOF
[mesh]
filename=shom_5km.msh

[setup]
ice-type=topaz_forecast #cs2_smos
ocean-type=topaz_forecast
atmosphere-type=era5
bathymetry-type=etopo
use_assimilation=false
dynamics-type=bbm #free_drift #mevp # free_drift #bbm

[simul]
spinup_duration=0
timestep=450
time_init=${DATE:0:4}-${DATE:4:2}-${DATE:6:2}
duration=`expr $CYCLE_PERIOD / 1440`

[thermo]
use_assim_flux=false
assim_flux_exponent=4
diffusivity_sss=0
diffusivity_sst=0
ocean_nudge_timeS=1296000
ocean_nudge_timeT=1296000

[damage]
clip=0
disc_scheme=explicit
[dynamics]
time_relaxation_damage=15
compression_factor=10e3
C_lab=1.5e6    # 1-5
substeps=120
use_temperature_dependent_healing=true
ECMWF_quad_drag_coef_air=0.0016

[restart]
start_from_restart=false
type=extend
write_initial_restart=false
write_interval_restart=true
output_interval=1
write_final_restart=true
input_path=.
basename=final

[output]
output_per_day=`expr $CYCLE_PERIOD / $OUTPUT_INTERVAL`
datetime_in_filename=true
exporter_path=run

[moorings]
use_moorings=true
grid_type=regular
spacing=5
output_timestep=0.125
output_time_step_units=days
file_length=daily
variables=conc
variables=thick
variables=velocity
variables=wind
variables=tau
variables=damage

[solver]
mat-package-type=mumps

[debugging]
check_fields_fast=false

EOF
