#!/bin/bash

sbatch \
--cpus-per-task 1 \
--time 20:00:00 \
launcher.sh \
-s run_get_gtdb \
--working_directory "/scratch/nljacque/gtdb" \
-k

