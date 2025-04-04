#!/bin/bash -l

MESH_LEVEL=$1

export BASEDIR="/global/scratch/users/mceloria/ElmerPowerCapping"
export RUNDIR="${BASEDIR}/runs/run_ElmerIce_Thea_N${SLURM_NNODES}_n${SLURM_NTASKS_PER_NODE}_c${SLURM_CPUS_PER_TASK}_ML${MESH_LEVEL}_${SLURM_JOB_ID}"
export SCRIPTSDIR="${BASEDIR}/scripts"
export CONTAINERSDIR="${BASEDIR}/containers"
export INPUTSDIR="${BASEDIR}/inputs"

