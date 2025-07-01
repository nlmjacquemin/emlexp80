#!/bin/bash

# Default values
DEFAULT_WORKING_DIRECTORY="/scratch/nljacque/gtdb"
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_RELEASE=220

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory  Specify the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -l, --log_folder         Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -r, --release            Specify the GTDB release number (default: $DEFAULT_RELEASE)"
    echo "  -h, --help               Display this help message"
}

# Default variables
working_directory="$DEFAULT_WORKING_DIRECTORY"
log_folder="$DEFAULT_LOG_FOLDER"
release="$DEFAULT_RELEASE"

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
        -r|--release)
            release="$2"
            shift 2
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

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Prepare working and log folders
log_message "Preparing working directory: $working_directory"
mkdir -p "$working_directory"
mkdir -p "$log_folder"
cd "$working_directory" || { log_message "Failed to change directory to $working_directory"; exit 1; }

log_message "Working directory: $working_directory"
log_message "Log folder: $log_folder"
log_message "GTDB Release: $release"

log_message "Starting download..."

# Download parts in parallel
for i in {a..k}; do
    wget "https://data.ace.uq.edu.au/public/gtdb/data/releases/release${release}/${release}.0/auxillary_files/gtdbtk_package/split_package/gtdbtk_r${release}_data.tar.gz.part_a$i" &
done
wait

log_message "Download finished"

log_message "Starting file merging..."

# Merge the downloaded parts
cat gtdbtk_r${release}_data.tar.gz.part_* > gtdbtk_r${release}_data.tar.gz

log_message "File merging finished"

log_message "Starting extraction..."

# Extract the merged tar.gz file
tar xvzf gtdbtk_r${release}_data.tar.gz

log_message "Extraction finished"

# Generate directory structure overview
tree -L 3 "$working_directory/release${release}" > "$working_directory/gtdb_structure.tree"

log_message "Directory structure saved to gtdb_structure.tree"
log_message "Process completed!"
