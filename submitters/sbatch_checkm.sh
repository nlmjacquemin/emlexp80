#!/bin/bash

sbatch \
--cpus-per-task 72 \
--time 24:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/sallet/E80" \
-k \
-- \
-i checkm \
-s run_checkm \
--micromamba_env checkm \
--bind /scratch/nljacque/db/checkm:/db

#-- \
#--input_genome_folder raw/genomes \
#-- \
#--extension .fasta

