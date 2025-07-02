#!/bin/bash

project_folder="$1"
database_folder="$2"

sbatch \
--cpus-per-task 64 \
--time 72:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-k \
-- \
-i gtdbtk \
-s run_gtdbtk \
--micromamba_env gtdbtk \
--bind $database_folder/gtdb:/db

