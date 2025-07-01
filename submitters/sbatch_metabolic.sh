#!/bin/bash

project_folder="$1"
database_folder="$2"

sbatch \
--cpus-per-task 72 \
--time 48:00:00 \
launcher.sh \
-s apptainer \
--working_directory $project_folder \
-k \
-- \
-i metabolic \
-s run_metabolic \
--micromamba_env METABOLIC_v4.0 \
--bind $database_folder/METABOLIC:/tool

#       -- \
#	--genome_extension .fasta \
#	--
#	-p single
#       --input_folder_genomes raw/genomes \

