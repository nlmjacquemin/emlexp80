#!/bin/bash

# Default variables
DEFAULT_WORKING_DIRECTORY="/data"
DEFAULT_INPUT_FOLDER="clean"
DEFAULT_OUTPUT_FOLDER="assembly/megahit"
DEFAULT_INPUT_EXTENSION=".clean.fq"
DEFAULT_PRESETS="meta-large"
DEFAULT_MIN_CONTIG_LEN="500"
DEFAULT_LOG_FOLDER=~/jobs

if [[ -z $SLURM_CPUS_PER_TASK ]]; then
    DEFAULT_THREADS=4
else
    DEFAULT_THREADS=$SLURM_CPUS_PER_TASK # Default number of threads for multi-threaded compression
fi

show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory		Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -i, --input_folder			Specify the path of the input read folder (default: $DEFAULT_INPUT_FOLDER)"
    echo "  -x, --input_extension		Specify the input reads extension (default: $DEFAULT_INPUT_EXTENSION)"
    echo "  -s, --input_sample			Specify the sample"
    echo "  -o, --output_folder			Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -p, --presets				Specify the MEGAHIT presets (default: $DEFAULT_PRESETS)"
    echo "  -m, --min_contig_len		Specify the minimum contig length (default: $DEFAULT_MIN_CONTIG_LEN)"
    echo "  -t, --threads				Specify the number of threads (default: $DEFAULT_THREADS)"
    echo "  -l, --log_folder			Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  --							Separator to pass the following options to MEGAHIT"
    echo "  [megahit options]			Options for MEGAHIT command"
}

# Variables
path_to_working_directory="$DEFAULT_WORKING_DIRECTORY"
input_folder="$DEFAULT_INPUT_FOLDER"
output_folder="$DEFAULT_OUTPUT_FOLDER"
input_extension="$DEFAULT_INPUT_EXTENSION"
input_sample=""
presets="$DEFAULT_PRESETS"
min_contig_len="$DEFAULT_MIN_CONTIG_LEN"
threads="$DEFAULT_THREADS"
log_folder="$DEFAULT_LOG_FOLDER"

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            path_to_working_directory="$2"
            shift 2
        ;;
        -i|--input_folder)
            input_folder="$2"
            shift 2
        ;;
        -x|--input_extension)
            input_extension="$2"
            shift 2
        ;;
        -s|--input_sample)
            input_sample="$2"
            shift 2
        ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
        ;;
        -p|--presets)
            presets="$2"
            shift 2
        ;;
        -m|--min_contig_len)
            min_contig_len="$2"
            shift 2
        ;;
        -t|--threads)
            threads="$2"
            shift 2
        ;;
        -l|--log_folder)
            log_folder="$2"
            shift 2
        ;;
        --)
            shift
            megahit_options="$@"
            break
        ;;
        -h|--help)
            show_usage
            exit 0
        ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
        ;;
    esac
done

# Check if MEGAHIT is installed
if ! command -v megahit &> /dev/null; then
    echo "MEGAHIT could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

# Setting folders and working space
cd $path_to_working_directory
mkdir -p $output_folder

# Running megahit
process_sample() {
    
    echo "Running megahit"
    
    #Setting inputs
    local sample=$1
    local read1=$(basename $(ls $input_folder/${sample}_*1${input_extension}))
    local read2=${read1/1./2.}
    if [ ! -f "$input_folder/$read1" ]; then
        echo "File $read1 not found!"
        exit 1
    fi
    if [ ! -f "$input_folder/$read2" ]; then
        echo "File $read2 not found!"
        exit 1
    fi
    echo "Sample:" $sample
    echo "Read forward:" $read1
    echo "Read reverse:" $read2
    if [ -d "$output_folder/$sample" ]; then
        echo "Assembly for $sample already done, skipping it!"
        exit 0
    fi
    
    megahit \
    -1 $input_folder/$read1 \
    -2 $input_folder/$read2 \
    -o $output_folder/$sample \
    -t $threads \
    --presets $presets \
    --min-contig-len $min_contig_len \
    ${megahit_options[@]}
    
    echo "Running megahit done!"
    
}

if [ -n "$input_sample" ]; then
    process_sample "$input_sample"
else
    # If no sample is provided, process all samples in the input folder
    for read1 in "$input_folder"/*1${input_extension}; do
        read1=$(basename "$read1")
        sample=$(echo $read1 | sed -E "s/($input_extension|\.fq|\.fastq)//g" | sed -E "s/(.*)_(R[0-9]+|[0-9]+)/\1/")
        process_sample "$sample"
    done
fi
