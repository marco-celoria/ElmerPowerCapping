hpccm --recipe recipe_Elmer_ubuntu24.py  --format singularity --singularity-version=3.2 > Elmer_ubuntu24_thea.def
singularity build Elmer_ubuntu24_thea.sif Elmer_ubuntu24_thea.def
