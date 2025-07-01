#!/bin/bash

cd /data

input_folder="clean"

output_folder="result/motus"

mkdir -p $output_folder/intermediary

R1_files=$(ls $input_folder/*_R1.clean.fq | sort | uniq)

#sed -e 's/_R1\.clean\.fastq//'

for R1_file in $R1_files;do
    
    filename=$(basename $R1_file _R1.clean.fq)
    
    echo $filename
    
    motus profile -n ${filename} -f $R1_file -r ${R1_file/_R1/_R2} -t $SLURM_CPUS_PER_TASK > $output_folder/intermediary/${filename}.motus
done

taxs=$(ls $output_folder/intermediary/*.motus | tr "\n" "," | sed 's/,$//g')

echo $taxs

motus merge -i $taxs > $output_folder/abd.motus

