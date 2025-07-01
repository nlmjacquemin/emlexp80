#!/bin/bash

project_folder="$1"

sbatch \
--cpus-per-task 8 \
--time 24:00:00 \
launcher.sh \
-s "apptainer" \
--working_directory $project_folder \
-k \
-- \
-i multiqc \
-s run_fastqc \
-- \
--input_extension .fastq.gz \
--output_folder analysis/fastqc/raw

jid_s1=$(sbatch \
    --parsable \
    --cpus-per-task 16 \
    --time 48:00:00 \
    launcher.sh \
    -s "apptainer" \
    --working_directory $project_folder \
    -k \
    -- \
    -i fastp \
    -s run_fastp \
    -- \
--input_extension .fastq.gz)

sbatch \
--dependency=afterok:${jid_s1} \
--cpus-per-task 8 \
--time 24:00:00 \
launcher.sh \
-s "apptainer" \
--working_directory $project_folder \
-k \
-- \
-i multiqc \
-s run_fastqc \
-- \
--input_folder clean \
--input_extension .fastq.gz \
--output_folder analysis/fastqc/clean

