#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_METABOLIC_PATH=/tool
DEFAULT_INPUT_FOLDER_GENOMES=binning/basalt/Final_bestbinset
DEFAULT_OUTPUT_FOLDER=analysis/metabolic
DEFAULT_GENOME_EXTENSION=.fa
DEFAULT_THREADS=$SLURM_CPUS_PER_TASK

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory         Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -l, --log_folder                Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -m, --metabolic_path            Specify the path of the METABOLIC tool (default: $DEFAULT_METABOLIC_PATH)"
    echo "  -i, --input_folder_genomes      Specify the input genome folder (default: $DEFAULT_INPUT_FOLDER_GENOMES)"
    echo "  -o, --output_folder             Specify the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -e, --genome_extension          Specify the genome file extension (default: $DEFAULT_GENOME_EXTENSION)"
    echo "  -t, --threads                   Specify the number of threads (default: $DEFAULT_THREADS)"
    echo "  --                              Separator to pass following options to the command being executed"
    echo "  -h, --help                      Display this help message"
}

# Default variables
log_folder="$DEFAULT_LOG_FOLDER"
working_directory="$DEFAULT_WORKING_DIRECTORY"
metabolic_path="$DEFAULT_METABOLIC_PATH"
input_folder_genomes="$DEFAULT_INPUT_FOLDER_GENOMES"
output_folder="$DEFAULT_OUTPUT_FOLDER"
genome_extension="$DEFAULT_GENOME_EXTENSION"
threads="$DEFAULT_THREADS"

# Parse options
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
        -m|--metabolic_path)
            metabolic_path="$2"
            shift 2
            ;;
        -i|--input_folder_genomes)
            input_folder_genomes="$2"
            shift 2
            ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
            ;;
        -e|--genome_extension)
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

# Remaining arguments are for the script to run
cmd_options=("$@")

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Check if perl is installed
if ! command -v perl &> /dev/null; then
    log_message "Perl could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

log_message "Preparing working directory and output folders..."
cd "$working_directory"
mkdir -p "$log_folder"
mkdir -p "$output_folder"
log_message "Working directory and output folders prepared!"

log_message "Starting METABOLIC analysis..."

bash ~/scripts/misc/HeaderPreparationBasalt2Metabolic.sh \
	--input_folder $working_directory/$input_folder_genomes \
	--output_folder $working_directory/$output_folder/genomes \
	--extension $genome_extension

perl "${metabolic_path}/METABOLIC-G.pl" \
	-in-gn $output_folder/genomes \
	-o $output_folder \
	-t "$threads" \
	"${cmd_options[@]}"

log_message "METABOLIC analysis completed!"
