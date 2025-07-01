
#!/bin/bash

PATH_TO_JOB_LOG_DIR=$1

cd /data

#cd /scratch/nljacque/sallet/E85

output_folder="result"

mkdir $output_folder

SCRIPT=~/scripts/run_motus.sh

cp $SCRIPT $PATH_TO_JOB_LOG_DIR

bash $SCRIPT 2>&1 | tee $output_folder/log.txt

grep -e "Number of reads after filtering:" -e "^B" $output_folder/log.txt -e "Total number of reads:" | grep -v "fastq" | head -n -1 > $output_folder/summary.txt

awk 'ORS=NR%3?FS:RS' $output_folder/summary.txt | sed -e 's/Total number of reads\: //g'\
-e 's/Number of reads after filtering\: //g'\
-e 's/ (/\t/g'\
-e 's/ percent)//g'\
-e 's/    /\t/g'\
-e 's/_R1.clean//g'\
> $output_folder/read.tsv

