#!/bin/bash

sbatch \
--cpus-per-task 72 \
--time 7-00:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/siwang/ANA16" \
-- \
-i basalt \
-s run_basalt \
--micromamba_env basalt \
-- \
--input_read_extension .clean.fq.gz \
--output_folder binning/basalt_bis
#--bind /scratch/nljacque/basalt_forked:/script2 \
# -- \
# --input_read_extension .clean.fq
