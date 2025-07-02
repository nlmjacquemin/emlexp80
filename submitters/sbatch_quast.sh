#!/bin/bash

project_folder="$1"

sbatch \
--cpus-per-task 72 \
--time 48:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-k \
-- \
-i quast \
-s run_quast