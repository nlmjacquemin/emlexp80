#!/bin/bash

path_to_host_working_directory=$1

input_folder=$path_to_host_working_directory/clean

read_extension=".clean.fq"

for read1 in $(ls $input_folder/*1.clean.fq);do
    
    read1=$(basename $read1)
    
    sample=$(echo $read1 | sed -E "s/($read_extension|\.fq|\.fastq|\.gz)//g" | sed -E "s/(.*)_(R[0-9]+|[0-9]+)/\1/")
    
    echo "Sample: $sample"
    
    bash sbatch_megahit_one.sh $sample $path_to_host_working_directory
    
done
