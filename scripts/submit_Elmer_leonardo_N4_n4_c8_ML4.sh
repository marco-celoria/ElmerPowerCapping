#!/bin/bash -l
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=8
#SBATCH --nodes=4
#SBATCH --partition=boost_usr_prod
#SBATCH --time=8:30:00
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --job-name=run_Elmer_leonardo_N4_n4_c8_ML4
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --gres=gpu:4
##SBATCH --qos=boost_qos_dbg
#SBATCH --exclusive

module load openmpi/4.1.6--gcc--12.2.0

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

MESH_LEVEL=4

export BASEDIR="/leonardo_work/cin_staff/mcelori1/ChEESE/ElmerPowerCapping"
export RUNDIR="${BASEDIR}/runs/run_Elmer_leonardo_N${SLURM_NNODES}_n${SLURM_NTASKS_PER_NODE}_c${SLURM_CPUS_PER_TASK}_ML${MESH_LEVEL}_${SLURM_JOB_ID}"
export SCRIPTSDIR="${BASEDIR}/scripts"
export CONTAINERSDIR="${BASEDIR}/containers"
export INPUTSDIR="${BASEDIR}/inputs"

export PMIX_MCA_gds=hash
export PMIX_MCA_psec=native

export GMSH="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif gmsh"
export ELMERGRID="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif ElmerGrid"
export ELMERSOLVER="mpirun -mca btl \"^openib\" singularity exec -B ${RUNDIR}/Greenland_SSA --env  UCX_POSIX_USE_PROC_LINK=n --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif ElmerSolver_mpi"
export ELMERF90="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif elmerf90"

# Create a directory for this run where we store all the inputs files
mkdir -p ${RUNDIR}
tar -xvzf "${INPUTSDIR}/Greenland_SSA.tar.gz" -C ${RUNDIR}
cd ${RUNDIR}/Greenland_SSA

# Partition the mesh and set the input files
${ELMERGRID} 2 2 MESH -partdual -metiskway ${SLURM_NTASKS}

${ELMERF90} Scalar_OUTPUT.F90 -o Scalar_OUTPUT

start=$(date +%s)

# Energy measurements start here
srun -N${SLURM_NNODES} -n${SLURM_NNODES} --ntasks-per-node=1 --overlap ${SCRIPTSDIR}/nvsmi_start.sh &

# Start the Elmer simulation
${ELMERSOLVER} "SSA_amgx_ML${MESH_LEVEL}.sif"

# Energy measurements stop here
srun -N${SLURM_NNODES} -n${SLURM_NNODES} --ntasks-per-node=1 ${SCRIPTSDIR}/nvsmi_stop.sh

end=$(date +%s)

echo "Elapsed time: $(($end-$start)) s"
echo "-----------------------------------"

