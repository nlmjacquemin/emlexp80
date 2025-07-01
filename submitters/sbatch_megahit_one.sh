#!/bin/bash

sbatch \
--cpus-per-task 72 \
--time 72:00:00 \
launcher.sh \
-s "apptainer" \
--working_directory $2 \
-k \
-- \
-i megahit \
-s run_megahit \
-- \
--input_sample $1
