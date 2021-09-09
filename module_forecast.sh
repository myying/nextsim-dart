#!/bin/bash

. $CONFIG_FILE

rundir=$WORK_DIR/run/$DATE/forecast
if [[ ! -d $rundir ]]; then mkdir -p $rundir; echo waiting > $rundir/stat; fi

cd $rundir
if [[ `cat stat` == "complete" ]]; then exit; fi

#Check dependency
#wait_for_module ../icbc
#if [ $DATE == $DATE_START ]; then wait_for_module ../perturb_ic; fi
#if [ $DATE -gt $DATE_START ]; then wait_for_module ../enkf; fi

echo running > stat

echo running ensemble forecast...

ncnt=0
ntot=$SLURM_NNODES
for m in `seq 1 $NUM_ENS`; do
    mm=`expr 100 + $m |cut -c2-`
    echo $mm
    mkdir -p $mm
    cd $mm

    mkdir -p data
    cd data
    ln -fs /cluster/projects/nn2993k/sim/data/BATHYMETRY/* .
    ln -fs $DATA_DIR/ERA5/$mm/* .
    ln -fs /cluster/projects/nn2993k/sim/sukun_test/nextsim_data_dir/TOPAZ4RC_daily .
    cd ..

    source $HOME/nextsim.intel.src
    export NEXTSIM_DATA_DIR=`pwd`/data
    $SCRIPT_DIR/make_nextsim_config.sh > nextsim.cfg
    $SCRIPT_DIR/job_submit.sh 1 32 $((ncnt-1)) $CODE_DIR/nextsim/model/bin/nextsim.exec --config-files=nextsim.cfg &
    cd ..

    ncnt=$((ncnt+1))
    if [[ $ncnt == $ntot ]]; then
        ncnt=0
        wait
    fi
done
wait

#if $CLEAN; then
#  for NE in `seq 1 $NUM_ENS`; do
#    id=`expr $NE + 1000 |cut -c2-`
#  done
#fi

echo complete > stat
