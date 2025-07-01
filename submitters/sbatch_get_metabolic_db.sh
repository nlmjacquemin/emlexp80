#!/bin/bash

sbatch \
--cpus-per-task 1 \
--time 48:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/db" \
-k \
-- \
-i metabolic \
-s run_get_metabolic_db \
--micromamba_env METABOLIC_v4.0