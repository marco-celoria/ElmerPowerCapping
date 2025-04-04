Usage:

Make sure that in `recipe_Elmer_ubuntu24.py` the correct architecture is imported. 

Then, for Thea

```
hpccm --recipe recipe_Elmer_ubuntu24.py  --format singularity --singularity-version=3.2 > Elmer_ubuntu24_thea.def

singularity build Elmer_ubuntu24_thea.sif Elmer_ubuntu24_thea.def
```

While for Leonardo

```
hpccm --recipe recipe_Elmer_ubuntu24.py  --format singularity --singularity-version=3.2 > Elmer_ubuntu24_leonardo.def

singularity build Elmer_ubuntu24_leonardo.sif Elmer_ubuntu24_thea.def
```

To be fixed:

Use command line for architecture selection

