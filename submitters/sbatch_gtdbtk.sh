#!/bin/bash

sbatch \
--cpus-per-task 64 \
--time 72:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/kmeibom/ANA1" \
-k \
-- \
-i gtdbtk \
-s run_gtdbtk \
--micromamba_env gtdbtk \
--bind /scratch/nljacque/gtdb:/db \
-- \
--input_genome_folder raw/genomes \
--input_extension fna

