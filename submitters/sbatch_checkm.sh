#!/bin/bash

project_folder=$1

sbatch \
--cpus-per-task 72 \
--time 24:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-k \
-- \
-i checkm \
-s run_checkm \
--micromamba_env checkm \
--bind $database_folder/db/checkm:/db

#-- \
#--input_genome_folder raw/genomes \
#-- \
#--extension .fasta

