hpccm --recipe recipeNobleNumbat.py  --format singularity --singularity-version=3.2 > ElmerNobleNumbat_Thea.def
singularity build ElmerNobleNumbat_Thea.sif ElmerNobleNumbat_Thea.def
