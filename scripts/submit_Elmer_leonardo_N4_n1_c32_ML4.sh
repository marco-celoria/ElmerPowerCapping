#!/bin/bash -l
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=4
#SBATCH --partition=boost_usr_prod
#SBATCH --time=3:30:00
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --job-name=run_Elmer_leonardo_N4_n1_c32_ML4
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --gres=gpu:4
##SBATCH --qos=boost_qos_dbg
#SBATCH --exclusive

module load openmpi/4.1.6--gcc--12.2.0

source config_leonardo.sh

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PMIX_MCA_gds=hash
export PMIX_MCA_psec=native

export GMSH="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif gmsh"
export ELMERGRID="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif ElmerGrid"
export ELMERSOLVER="mpirun -mca btl \"^openib\" singularity exec -B ${RUNDIR}/Greenland_SSA --env  UCX_POSIX_USE_PROC_LINK=n --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif ElmerSolver_mpi"
export ELMERF90="srun -N1 -n1 singularity exec -B ${RUNDIR}/Greenland_SSA --nv ${CONTAINERSDIR}/Elmer_ubuntu24_leonardo.sif elmerf90"

mkdir -p ${RUNDIR}

tar -xvzf "${INPUTSDIR}/Greenland_SSA.tar.gz" -C ${RUNDIR}

cd ${RUNDIR}/Greenland_SSA

${ELMERGRID} 2 2 MESH -partdual -metiskway ${SLURM_NTASKS}

${ELMERF90} Scalar_OUTPUT.F90 -o Scalar_OUTPUT

start=$(date +%s)

cd ${RUNDIR} 
for node in `scontrol show hostname`; do
  echo $node >> "${RUNDIR}/nodelist.txt"
done
srun -N${SLURM_NNODES} -n${SLURM_NNODES} --ntasks-per-node=1 ${SCRIPTSDIR}/nvsmi_start.sh 
cd -

${ELMERSOLVER} SSA_amgx_ML4.sif

cd ${RUNDIR} && srun -N${SLURM_NNODES} -n${SLURM_NNODES} --ntasks-per-node=1 ${SCRIPTSDIR}/nvsmi_stop.sh && cd -

end=$(date +%s)

echo "Elapsed time: $(($end-$start)) s"
echo "-----------------------------------"

