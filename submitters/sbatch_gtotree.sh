#!/bin/bash

mkdir -p /scratch/nljacque/db/gtotree

sbatch \
--cpus-per-task 72 \
--time 24:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/sallet/E80" \
-k \
-- \
-i gtotree \
-s run_gtotree\
--micromamba_env gtotree \
--overlay /scratch/nljacque/db/gtotree/overlay \
-- \
--jobs 14 \
--output_folder analysis/gtotree/result_G0 \
-- \
-M 5 \
-n 5 \
-K raw/ko.txt \
-G 0

