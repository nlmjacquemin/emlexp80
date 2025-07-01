#!/bin/bash

sbatch \
--cpus-per-task 72 \
--time 96:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/sallet/E85" \
-- \
-i coverm \
-s run_coverm \
--micromamba_env coverm
