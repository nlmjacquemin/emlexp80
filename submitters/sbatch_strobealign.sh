#!/bin/bash

sbatch \
--cpus-per-task 72 \
--time 96:00:00 \
launcher.sh \
-s apptainer \
--working_directory "/scratch/nljacque/sallet/E85" \
-- \
-i samtools-strobealign \
-s run_strobealign \
-- \
--read_extension .clean.fq \
--against bins
