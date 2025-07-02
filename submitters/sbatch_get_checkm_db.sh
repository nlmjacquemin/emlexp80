#!/bin/bash

database_folder="$2"

sbatch \
--cpus-per-task 1 \
--time 4:00:00 \
launcher.sh \
-s apptainer \
--working_directory $database_folder/db" \
-k \
-- \
-i checkm \
--micromamba_env checkm \
-s run_get_checkm_db \



