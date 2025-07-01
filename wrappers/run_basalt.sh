#!/bin/bash

# Default values
DEFAULT_WORKING_DIRECTORY="/data"
DEFAULT_INPUT_READ_FOLDER="clean"
DEFAULT_INPUT_READ_EXTENSION=".fq"
DEFAULT_INPUT_ASSEMBLY_FOLDER="assembly/megahit"
DEFAULT_INPUT_ASSEMBLY_FILE="final.contigs.fa"
DEFAULT_OUTPUT_FOLDER="binning/basalt"
DEFAULT_LOG_FOLDER=~/jobs

show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory			Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -r, --input_read_folder			Specify the path of the input read folder (default: $DEFAULT_INPUT_READ_FOLDER)"
    echo "  -x, --input_read_extension		Specify the input reads extension (default: $DEFAULT_INPUT_READ_EXTENSION)"
    echo "  -a, --input_assembly_folder		Specify the path of the input assembly folder (default: $DEFAULT_INPUT_ASSEMBLY_FOLDER)"
    echo "  -y, --input_assembly_file	    Specify the input assembly extension (default: $DEFAULT_INPUT_ASSEMBLY_FILE)"
    echo "  -o, --output_folder				Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
	echo "  -l, --log_folder				Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  --								Separator to pass following options to BASALT"
    echo "  -h, --help						Display this help message"
}

# Variables
working_directory="$DEFAULT_WORKING_DIRECTORY"
input_read_folder="$DEFAULT_INPUT_READ_FOLDER"
input_read_extension="$DEFAULT_INPUT_READ_EXTENSION"
input_assembly_folder="$DEFAULT_INPUT_ASSEMBLY_FOLDER"
input_assembly_file="$DEFAULT_INPUT_ASSEMBLY_FILE"
output_folder="$DEFAULT_OUTPUT_FOLDER"
log_folder="$DEFAULT_LOG_FOLDER"
basalt_cmd=""

# Parse command-line arguments
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
            shift 2
            ;;
        -r|--input_read_folder)
            input_read_folder="$2"
            shift 2
            ;;
        -x|--input_read_extension)
            input_read_extension="$2"
            shift 2
            ;;
        -a|--input_assembly_folder)
            input_assembly_folder="$2"
            shift 2
            ;;
        -y|--input_assembly_file)
            input_assembly_file="$2"
            shift 2
            ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
            ;;
        -l|--log_folder)
            log_folder="$2"
            shift 2
            ;;
        --)
            shift
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

# Remaining arguments are for the script to run
basalt_cmd=("$@")

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Check if BASALT is installed
if ! command -v BASALT &> /dev/null; then
    log_message "BASALT could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

# Setting folders and working space
cd $working_directory
mkdir -p $output_folder

#Creating symbolic links
#Reads
for file in $input_read_folder/*$input_read_extension; do
    ln -s $working_directory/$file $working_directory/$output_folder/$(basename $file)
done
log_message "Symbolic links created for reads in $output_folder"
#Assemblies
for file in $input_assembly_folder/*/*$input_assembly_file; do
    folder_name=$(basename "$(dirname $file)")
    file_name=$(basename "$file")
    ln -s $working_directory/$file $working_directory/$output_folder/${folder_name}_${file_name}
done
log_message "Symbolic links created for assemblies in $output_folder"

#Running basalt
log_message "Running BASALT"

cd $output_folder

BASALT \
	-a $(ls *$input_assembly_file | tr '\n' ',' | sed 's/,$//') \
	-s $(ls *$input_read_extension | paste -d',' - - | tr '\n' '/' | sed 's/\/$//') \
	-t $SLURM_CPUS_PER_TASK \
	-m "$(( SLURM_CPUS_PER_TASK * SLURM_MEM_PER_CPU / 1000 ))" \
	$basalt_cmd

log_message "Running BASALT done!"
