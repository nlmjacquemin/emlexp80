#!/bin/bash

project_folder=$1

sbatch \
--cpus-per-task 72 \
--time 96:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-- \
-i coverm \
-s run_coverm \
--micromamba_env coverm
