#!/bin/bash

n=$1
o=$2
shift 2
exe=$@

function get_nodefile {
    job_nodelist=$1
    nodefile=''
    if [[ ${job_nodelist:1:1} == '[' ]]; then
        pre=${job_nodelist:0:1}
        for id in `echo $job_nodelist |awk -F '[][]' '{print $2}' |tr ',' ' '`; do
            if [[ ${id:4:1} == '-' ]]; then
                for j in `seq ${id:0:4} ${id:5:4}`; do
                    nodefile=$nodefile' '$pre$j
                done
            else
                nodefile=$nodefile' '$pre$id
            fi
        done
    else
        nodefile=$job_nodelist
    fi
    echo $nodefile |tr ' ' '\n'
}

get_nodefile $SLURM_JOB_NODELIST |head -n $o |tail -n 1 > nodefile
mpirun -np $n -machinefile nodefile $exe


