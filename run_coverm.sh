#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_INPUT_FOLDER_BINS="binning/basalt/Final_bestbinset"
DEFAULT_INPUT_FOLDER_MAPPING="mapping/reads2bins"
DEFAULT_OUTPUT_FOLDER="analysis/coverm"
DEFAULT_FILE_OUTPUT="coverm_abd.tsv"
DEFAULT_MAPPING_FILE_EXTENSION=".bam"
DEFAULT_GENOME_EXTENSION="fa"
DEFAULT_THREADS="$SLURM_CPUS_PER_TASK"

show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory      Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -l, --log_folder             Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -b, --input_folder_bins      Specify the path of the input folder bins (default: $DEFAULT_INPUT_FOLDER_BINS)"
    echo "  -m, --input_folder_mapping   Specify the path of the input folder mapping (default: $DEFAULT_INPUT_FOLDER_MAPPING)"
    echo "  -o, --output_folder          Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -f, --file_output            Specify the output file name (default: $DEFAULT_FILE_OUTPUT)"
    echo "  -e, --mapping_file_extension Specify the mapping file extension (default: $DEFAULT_MAPPING_FILE_EXTENSION)"
    echo "  -x, --genome_extension       Specify the genome file extension (default: $DEFAULT_GENOME_EXTENSION)"
    echo "  -t, --threads                Specify the number of threads (default: $DEFAULT_THREADS)"
    echo "  -h, --help                   Display this help message"
    echo "  --                           Separator to pass following options to coverm"
    echo "  [coverm options]             Options for coverm command"

}

# Variables
working_directory="$DEFAULT_WORKING_DIRECTORY"
log_folder="$DEFAULT_LOG_FOLDER"
input_folder_bins="$DEFAULT_INPUT_FOLDER_BINS"
input_folder_mapping="$DEFAULT_INPUT_FOLDER_MAPPING"
output_folder="$DEFAULT_OUTPUT_FOLDER"
file_output="$DEFAULT_FILE_OUTPUT"
mapping_file_extension="$DEFAULT_MAPPING_FILE_EXTENSION"
genome_extension="$DEFAULT_GENOME_EXTENSION"
threads="$DEFAULT_THREADS"
coverm_cmd=""

# Parse command-line arguments
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
            shift 2
            ;;
        -l|--log_folder)
            log_folder="$2"
            shift 2
            ;;
        -b|--input_folder_bins)
            input_folder_bins="$2"
            shift 2
            ;;
        -m|--input_folder_mapping)
            input_folder_mapping="$2"
            shift 2
            ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
            ;;
        -f|--file_output)
            file_output="$2"
            shift 2
            ;;
        -e|--mapping_file_extension)
            mapping_file_extension="$2"
            shift 2
            ;;
        -x|--genome_extension)
            genome_extension="$2"
            shift 2
            ;;
        -t|--threads)
            threads="$2"
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

# Remaining arguments are for the coverm command
coverm_cmd=("$@")

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Check if coverm is installed
if ! command -v coverm &> /dev/null; then
    log_message "coverm could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

# Setting folders and working space
cd "$working_directory" || { log_message "Working directory $working_directory does not exist"; exit 1; }
mkdir -p "$output_folder"

# Running coverm
log_message "Running coverm"

coverm genome \
    -d "$input_folder_bins" \
    -x "$genome_extension" \
    -b "$input_folder_mapping"/*"$mapping_file_extension" \
    -o "$output_folder/$file_output" \
    --threads "$threads" \
    "${coverm_cmd[@]}"

log_message "Running coverm done!"
