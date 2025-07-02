#!/bin/bash

project_folder="$1"
database_folder="$2"

mkdir -p $database_folder/db/gtotree

sbatch \
--cpus-per-task 72 \
--time 24:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-k \
-- \
-i gtotree \
-s run_gtotree\
--micromamba_env gtotree \
--overlay $database_folder/db/gtotree/overlay \
-- \
--jobs 14 \
--output_folder analysis/gtotree/result_G0 \
-- \
-M 5 \
-n 5 \
-K raw/ko.txt \
-G 0

