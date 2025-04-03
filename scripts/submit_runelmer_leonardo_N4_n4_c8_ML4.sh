#!/bin/bash -l
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=8
#SBATCH --nodes=4
#SBATCH --partition=boost_usr_prod
#SBATCH --time=2:30:00
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --job-name=run_ElmerIce_Leonardo_N4_n4_c8_ML4
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --gres=gpu:4
##SBATCH --qos=boost_qos_dbg
#SBATCH --exclusive

module load openmpi/4.1.6--gcc--12.2.0

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PMIX_MCA_gds=hash
export PMIX_MCA_psec=native

BASEDIR="/leonardo_work/cin_staff/mcelori1/ChEESE/ElmerPowerCapping"
export RUNDIR="${BASEDIR}/runs/run_ElmerIce_Leonardo_N${SLURM_NNODES}_n${SLURM_NTASKS_PER_NODE}_c${SLURM_CPUS_PER_TASK}_ML4_${SLURM_JOB_ID}"

export GMSH="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${BASEDIR}/containers/ElmerNobleNumbat_Leonardo.sif gmsh"
export ELMERGRID="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${BASEDIR}/containers/ElmerNobleNumbat_Leonardo.sif ElmerGrid"
export ELMERSOLVER="mpirun -mca btl \"^openib\" singularity exec -B ${RUNDIR}/Greenland_SSA --env  UCX_POSIX_USE_PROC_LINK=n --nv ${BASEDIR}/containers/ElmerNobleNumbat_Leonardo.sif ElmerSolver_mpi"
export ELMERF90="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${BASEDIR}/containers/ElmerNobleNumbat_Leonardo.sif elmerf90"


mkdir -p ${RUNDIR}

tar -xvzf "${BASEDIR}/inputs/Greenland_SSA.tar.gz" -C ${RUNDIR}

echo "$(pwd)"
cd ${RUNDIR}/Greenland_SSA
echo "$(pwd)"
ls

${ELMERGRID} 2 2 MESH -partdual -metiskway ${SLURM_NTASKS}

${ELMERF90} Scalar_OUTPUT.F90 -o Scalar_OUTPUT

start=$(date +%s)
${ELMERSOLVER} SSA_amgx_ML4.sif
end=$(date +%s)

echo "Elapsed time: $(($end-$start)) s"
echo "-----------------------------------"


