#!/bin/bash

database_folder="$2"

sbatch \
--cpus-per-task 1 \
--time 20:00:00 \
launcher.sh \
-s run_get_gtdb \
--working_directory $database_folder/gtdb" \
-k

