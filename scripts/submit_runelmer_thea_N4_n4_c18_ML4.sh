#!/bin/bash -l
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=18
#SBATCH --nodes=4
#SBATCH --partition=gh
#SBATCH --time=4:00:00
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --job-name=run_ElmerIce_Thea_N4_n4_c18_ML4
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PMIX_MCA_gds=hash
export PMIX_MCA_psec=native

BASEDIR="/global/scratch/users/mceloria/ElmerPowerCapping"

export GMSH="srun -N1 -n1 singularity exec --nv ${BASEDIR}/containers/ElmerNobleNumbat_Thea.sif gmsh"
export ELMERGRID="srun -N1 -n1 singularity exec --nv ${BASEDIR}/containers/ElmerNobleNumbat_Thea.sif ElmerGrid"
export ELMERSOLVER="srun --mpi=pmix singularity exec --env  UCX_POSIX_USE_PROC_LINK=n --nv ${BASEDIR}/containers/ElmerNobleNumbat_Thea.sif ElmerSolver_mpi"
export ELMERF90="srun -N1 -n1 singularity exec --nv ${BASEDIR}/containers/ElmerNobleNumbat_Thea.sif elmerf90"

export RUNDIR="${BASEDIR}/runs/run_ElmerIce_Thea_N${SLURM_NNODES}_n${SLURM_NTASKS_PER_NODE}_c${SLURM_CPUS_PER_TASK}_ML4_${SLURM_JOB_ID}"

mkdir -p ${RUNDIR}

tar -xvzf "${BASEDIR}/inputs/Greenland_SSA.tar.gz" -C ${RUNDIR}

cd ${RUNDIR}/Greenland_SSA

${ELMERGRID} 2 2 MESH -partdual -metiskway ${SLURM_NTASKS}

${ELMERF90} Scalar_OUTPUT.F90 -o Scalar_OUTPUT

start=$(date +%s)
${ELMERSOLVER} SSA_amgx_ML4.sif
end=$(date +%s)

echo "Elapsed time: $(($end-$start)) s"
echo "-----------------------------------"


