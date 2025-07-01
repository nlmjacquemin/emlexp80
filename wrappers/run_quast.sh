#!/bin/bash

# Default values
DEFAULT_WORKING_DIRECTORY="/data"
DEFAULT_LOG_FOLDER="~/jobs"
DEFAULT_ASSEMBLER="megahit"
DEFAULT_INPUT_BASE_FOLDER="assembly"
DEFAULT_OUTPUT_BASE_FOLDER="analysis/quast"
DEFAULT_CONTIG_FILENAME="final.contigs.fa"

# Usage info
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -w, --working_directory     Working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -l, --log_folder            Log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -a, --assembler             Assembler name (default: $DEFAULT_ASSEMBLER)"
    echo "  -i, --input_base_folder     Base input folder (default: $DEFAULT_INPUT_BASE_FOLDER)"
    echo "  -o, --output_base_folder    Base output folder (default: $DEFAULT_OUTPUT_BASE_FOLDER)"
    echo "  -c, --contig_filename       Name of contig file (default: $DEFAULT_CONTIG_FILENAME)"
    echo "  -h, --help                  Show this help message"
}

# Defaults
working_directory="$DEFAULT_WORKING_DIRECTORY"
log_folder="$DEFAULT_LOG_FOLDER"
assembler="$DEFAULT_ASSEMBLER"
input_base_folder="$DEFAULT_INPUT_BASE_FOLDER"
output_base_folder="$DEFAULT_OUTPUT_BASE_FOLDER"
contig_filename="$DEFAULT_CONTIG_FILENAME"

# Parse command-line args
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -w|--working_directory) working_directory="$2"; shift 2 ;;
        -l|--log_folder) log_folder="$2"; shift 2 ;;
        -a|--assembler) assembler="$2"; shift 2 ;;
        -i|--input_base_folder) input_base_folder="$2"; shift 2 ;;
        -o|--output_base_folder) output_base_folder="$2"; shift 2 ;;
        -c|--contig_filename) contig_filename="$2"; shift 2 ;;
        -h|--help) show_usage; exit 0 ;;
        *) echo "Unknown option: $1"; show_usage; exit 1 ;;
    esac
done

# Final paths
input_folder="${input_base_folder}/${assembler}"
output_folder="${output_base_folder}/${assembler}"
log_file="${log_folder}/quast_${assembler}.log"

# Logging function
log_message() {
    local msg="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $msg"
}

# Setup
cd "$working_directory" || { log_message "ERROR: working directory $working_directory does not exist."; exit 1; }
mkdir -p "$output_folder" "$log_folder"

log_message "Running QUAST on assembler: $assembler" | tee "$log_file"
log_message "Contig file: $contig_filename" | tee -a "$log_file"
log_message "Input folder: $input_folder" | tee -a "$log_file"
log_message "Output folder: $output_folder" | tee -a "$log_file"

# Check if quast.py is available
if ! command -v quast.py &>/dev/null; then
    log_message "ERROR: quast.py not found in PATH." | tee -a "$log_file"
    exit 1
fi

# Run QUAST
quast.py "$input_folder"/*/"$contig_filename" -o "$output_folder" &>> "$log_file"

log_message "QUAST run completed." | tee -a "$log_file"
