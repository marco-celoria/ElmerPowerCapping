#!/bin/bash -x
#SBATCH --account=jureap119
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=72
#SBATCH --partition=all
#SBATCH --job-name=run_Elmer_jedi_N1_n4_c72_ML4
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --time=2:00:00
#SBATCH --gres=gpu:4
#SBATCH --threads-per-core=1
#SBATCH --exclusive


MESH_LEVEL=4

export BASEDIR="/p/scratch/jureap119/ElmerPowerCapping"
export RUNDIR="${BASEDIR}/runs/run_Elmer_jedi_N${SLURM_NNODES}_n${SLURM_NTASKS_PER_NODE}_c${SLURM_CPUS_PER_TASK}_ML${MESH_LEVEL}_${SLURM_JOB_ID}"
export SCRIPTSDIR="${BASEDIR}/scripts"
export CONTAINERSDIR="${BASEDIR}/containers"
export INPUTSDIR="${BASEDIR}/inputs"

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PMIX_MCA_gds=hash
export PMIX_MCA_psec=native

module load Stages/2025  GCC/13.3.0  OpenMPI/5.0.5
module load MPI-settings/CUDA

export APPTAINERENV_PMIX_MCA_psec=^munge
export APPTAINERENV_UCX_TLS=^xpmem
export UCX_TLS=^xpmem

export GMSH="srun -N1 -n1 singularity exec  --nv ${CONTAINERSDIR}/Elmer_ubuntu24_thea.sif gmsh"
export ELMERGRID="srun -N1 -n1 singularity exec --nv ${CONTAINERSDIR}/Elmer_ubuntu24_thea.sif ElmerGrid"
export ELMERSOLVER="srun singularity exec --env  UCX_POSIX_USE_PROC_LINK=n --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif ElmerSolver_mpi"
export ELMERF90="srun -N1 -n1 singularity exec --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif elmerf90"

OMP_PROC_BIND=true

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

