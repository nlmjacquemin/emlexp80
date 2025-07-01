#!/bin/bash

DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_INPUT_FOLDER="raw/reads"
DEFAULT_INPUT_EXTENSION=".fastq"
DEFAULT_OUTPUT_FOLDER="clean"
DEFAULT_OUTPUT_EXTENSION=".clean.fq"
DEFAULT_PATTERN_FWD="_1"  # Default forward pattern for paired reads
DEFAULT_PATTERN_REV="_2"  # Default reverse pattern for paired reads
DEFAULT_PAIRED=false  # Default to single-end unless --paired is specified

show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory  Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -i, --input_folder       Specify the path of the input read folder (default: $DEFAULT_INPUT_FOLDER)"
    echo "  -x, --input_extension    Specify the input reads extension (default: $DEFAULT_INPUT_EXTENSION)"
    echo "  -o, --output_folder      Specify the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -y, --output_extension   Specify the output reads extension (default: $DEFAULT_OUTPUT_EXTENSION)"
    echo "  --paired                 Enable paired-end mode (default: $DEFAULT_PAIRED)"
    echo "  -p, --pattern_paired     Specify the paired-end pattern (default: $DEFAULT_PATTERN_FWD/$DEFAULT_PATTERN_REV) (only used if --paired is set)"
    echo "  -l, --log_folder         Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  --                       Separator to pass additional options to fastp"
}

# Variables
path_to_working_directory="$DEFAULT_WORKING_DIRECTORY"
input_folder=$DEFAULT_INPUT_FOLDER
input_extension=$DEFAULT_INPUT_EXTENSION
output_folder=$DEFAULT_OUTPUT_FOLDER
output_extension=$DEFAULT_OUTPUT_EXTENSION
log_folder="$DEFAULT_LOG_FOLDER"
paired=$DEFAULT_PAIRED
pattern_fwd=""
pattern_rev=""
custom_pattern_set=false  # Flag to track if --pattern_paired was used

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
        -o|--output_folder)
            output_folder="$2"
            shift 2
        ;;
        -y|--output_extension)
            output_extension="$2"
            shift 2
        ;;
        --paired)
            paired=true
            # Only set default patterns if no custom pattern was specified
            if [[ "$custom_pattern_set" == false ]]; then
                pattern_fwd=$DEFAULT_PATTERN_FWD
                pattern_rev=$DEFAULT_PATTERN_REV
            fi
            shift
        ;;
        -p|--pattern_paired)
            pattern_fwd="${2%/*}"
            pattern_rev="${2#*/}"
            custom_pattern_set=true  # Mark that a custom pattern was set
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

# Capture additional arguments for fastp
cmd_options=("$@")

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Function to detect potential paired files by looking for "1." and "2." differences
detect_paired_files() {
    local detected_paired=false
    for file in "$input_folder"/*1."$input_extension"; do
        base_name=$(basename "$file" "1.$input_extension")
        if [[ -f "$input_folder/${base_name}2.$input_extension" ]]; then
            detected_paired=true
            break
        fi
    done
    
    if [[ "$detected_paired" == true && "$paired" == false ]]; then
        log_message "Warning: Paired files detected (e.g., ${base_name}1.$input_extension and ${base_name}2.$input_extension). Consider using the --paired option for paired-end processing."
    fi
}

# Function to process a sample with fastp
process_fastp() {
    local read1="$1"
    local output_folder="$2"
    local input_extension="$3"
    local output_extension="$4"
    local paired="$5"
    local pattern_fwd="$6"
    local pattern_rev="$7"
    
    local sample=$(basename "$read1" | sed -E "s/(${pattern_fwd}${input_extension}|\.fq|\.fastq)//g")
    local output_file_1="$output_folder/${sample}${output_extension}"
    
    if [[ "$paired" == true && -n "$pattern_fwd" && -n "$pattern_rev" ]]; then
        local read2="${read1/$pattern_fwd/$pattern_rev}"
        if [[ -f "$read2" ]]; then
            # Paired-end processing
            local output_file_2="$output_folder/${sample}${output_extension}"
            log_message "Processing paired-end sample $sample"
            fastp --detect_adapter_for_pe \
            --thread "$SLURM_CPUS_PER_TASK" \
            --in1 "$read1" \
            --in2 "$read2" \
            --out1 "$output_file_1" \
            --out2 "$output_file_2" \
            --json "$output_folder/${sample}.fastp.json" \
            --html "$output_folder/${sample}.fastp.html" \
            "${cmd_options[@]}" \
            2>&1 | tee "$output_folder/${sample}.log.txt"
        else
            # Warning if only read1 is found in paired mode
            log_message "Warning: Missing paired file $read2 for sample $sample. Processing as single-end."
            fastp \
            --thread "$SLURM_CPUS_PER_TASK" \
            --in1 "$read1" \
            --out1 "$output_file_1" \
            --json "$output_folder/${sample}.fastp.json" \
            --html "$output_folder/${sample}.fastp.html" \
            "${cmd_options[@]}" \
            2>&1 | tee "$output_folder/${sample}.log.txt"
        fi
    else
        # Single-end processing
        log_message "Processing single-end sample $sample"
        fastp \
        --thread "$SLURM_CPUS_PER_TASK" \
        --in1 "$read1" \
        --out1 "$output_file_1" \
        --json "$output_folder/${sample}.fastp.json" \
        --html "$output_folder/${sample}.fastp.html" \
        "${cmd_options[@]}" \
        2>&1 | tee "$output_folder/${sample}.log.txt"
    fi
}


# Setting folders and working space
cd "$path_to_working_directory" || exit
mkdir -p "$output_folder"

# Run paired file detection if --paired is not set
if [[ "$paired" == false ]]; then
    detect_paired_files
fi

# Running the script
log_message "Running fastp..."

if [[ -n "$SLURM_ARRAY_TASK_ID" ]]; then
    # Array job handling
    sample_prefix=$(find "$input_folder" -type f -name "*${pattern_fwd}${input_extension}" \
    | sed -E "s/${pattern_fwd}${input_extension}$//" | uniq | sed -n "${SLURM_ARRAY_TASK_ID}p")
    process_fastp "${sample_prefix}${pattern_fwd}${input_extension}" "$output_folder" "$input_extension" "$output_extension" "$paired" "$pattern_fwd" "$pattern_rev"
else
    # Non-array job: process all samples
    index=1
    total_samples=$(find "$input_folder" -type f -name "*${pattern_fwd}${input_extension}" \
    | sed -E "s/${pattern_fwd}${input_extension}$//" | uniq | wc -l)
    
    for sample_prefix in $(find "$input_folder" -type f -name "*${pattern_fwd}${input_extension}" \
        | sed -E "s/${pattern_fwd}${input_extension}$//" | uniq); do
        log_message "Iteration $index/$total_samples"
        process_fastp "${sample_prefix}${pattern_fwd}${input_extension}" "$output_folder" "$input_extension" "$output_extension" "$paired" "$pattern_fwd" "$pattern_rev"
        ((index++))
    done
fi

log_message "Running fastp done!"
