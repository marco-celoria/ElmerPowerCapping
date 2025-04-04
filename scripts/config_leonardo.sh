#!/bin/bash -l

export BASEDIR="/leonardo_work/cin_staff/mcelori1/ChEESE/ElmerPowerCapping"
export RUNDIR="${BASEDIR}/runs/run_Elmer_leonardo_N${SLURM_NNODES}_n${SLURM_NTASKS_PER_NODE}_c${SLURM_CPUS_PER_TASK}_ML4_${SLURM_JOB_ID}"
export SCRIPTSDIR="${BASEDIR}/scripts"
export CONTAINERSDIR="${BASEDIR}/containers"
export INPUTSDIR="${BASEDIR}/inputs"

