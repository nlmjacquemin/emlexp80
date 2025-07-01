#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_OUTPUT_FOLDER="checkm"

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory    Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -o, --output_folder        Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -l, --log_folder           Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  --                         Separator to pass additional options to CheckM2 database command"
}

# Default variables
log_folder="$DEFAULT_LOG_FOLDER"
working_directory="$DEFAULT_WORKING_DIRECTORY"
output_folder="$DEFAULT_OUTPUT_FOLDER"

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
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

# Remaining arguments passed to checkm2 database
cmd_options=("$@")

# Create log folder if it doesn't exist
mkdir -p "$log_folder"

# Print log message function
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

log_message "Starting CheckM2 database download"

# Change to working directory
cd "$working_directory"

# Run CheckM2 database download
checkm2 database --download --path "$output_folder" "${cmd_options[@]}"

log_message "CheckM2 database download finished"

