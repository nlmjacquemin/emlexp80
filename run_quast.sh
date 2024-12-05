#!/bin/bash

cd /data

assembler="megahit"

input_folder=assembly/$assembler

output_folder=analysis/quast/$assembler

mkdir -p $output_folder

quast.py $input_folder/*/final.contigs.fa -o $output_folder
