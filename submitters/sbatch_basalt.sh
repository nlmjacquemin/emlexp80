#!/bin/bash

project_folder=$1

sbatch \
--cpus-per-task 72 \
--time 7-00:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-- \
-i basalt \
-s run_basalt \
--micromamba_env basalt \
-- \
--input_read_extension .clean.fq.gz \
--output_folder binning/basalt

