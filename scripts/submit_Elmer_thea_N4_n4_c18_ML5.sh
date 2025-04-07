#!/bin/bash -l
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=18
#SBATCH --nodes=4
#SBATCH --partition=gh
#SBATCH --time=4:00:00
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --job-name=run_Elmer_thea_N4_n4_c18_ML5
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

# Set the directory structure environment
source config_thea.sh 5

# Set the OMP and MPI environmental variables
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PMIX_MCA_gds=hash
export PMIX_MCA_psec=native

# Set the containers
export GMSH="srun -N1 -n1 singularity exec --nv ${CONTAINERSDIR}/Elmer_ubuntu24_thea.sif gmsh"
export ELMERGRID="srun -N1 -n1 singularity exec --nv ${CONTAINERSDIR}/Elmer_ubuntu24_thea.sif ElmerGrid"
export ELMERSOLVER="srun --mpi=pmix singularity exec --env  UCX_POSIX_USE_PROC_LINK=n --nv ${CONTAINERSDIR}/Elmer_ubuntu24_thea.sif ElmerSolver_mpi"
export ELMERF90="srun -N1 -n1 singularity exec --nv ${CONTAINERSDIR}/Elmer_ubuntu24_thea.sif elmerf90"

# Create a directory for this run where we store all the inputs files
mkdir -p ${RUNDIR}
tar -xvzf "${INPUTSDIR}/Greenland_SSA.tar.gz" -C ${RUNDIR}
cd ${RUNDIR}/Greenland_SSA

# Partition the mesh and set the input files
${ELMERGRID} 2 2 MESH -partdual -metiskway ${SLURM_NTASKS}

${ELMERF90} Scalar_OUTPUT.F90 -o Scalar_OUTPUT

start=$(date +%s)

# Energy measurements start here
# cd ${SCRIPTSDIR} && source "${SCRIPTSDIR}/preprocess.sh" "thea" "5" && cd -

# Start the Elmer simulation
${ELMERSOLVER} SSA_amgx_ML5.sif

# Energy measurements stop here
# cd ${SCRIPTSDIR} && source "${SCRIPTSDIR}/postprocess.sh" "thea" "5" && cd -

end=$(date +%s)

echo "Elapsed time: $(($end-$start)) s"
echo "-----------------------------------"

