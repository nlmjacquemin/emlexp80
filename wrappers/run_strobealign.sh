#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_INPUT_FOLDER_READS="clean"
DEFAULT_READ_EXTENSION=".clean.fq"
DEFAULT_BAM_EXTENSION=".sorted.bam"
DEFAULT_AGAINST="assemblies"
DEFAULT_SELF_MAPPING=true

# Default values for assemblies
DEFAULT_INPUT_FOLDER_ASSEMBLIES="assembly/megahit"
DEFAULT_TARGET_FILE="final.contigs.fa"

# Default values for bins
DEFAULT_INPUT_FOLDER_BINS="binning/basalt/Final_bestbinset"
DEFAULT_TARGET_EXTENSION=".fa"

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory         Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -r, --input_folder_reads        Specify the path of the input reads folder (default: $DEFAULT_INPUT_FOLDER_READS)"
    echo "  -x, --read_extension            Specify the extension for read files (default: $DEFAULT_READ_EXTENSION)"
    echo "  -m, --bam_extension             Specify the extension for BAM files (default: $DEFAULT_BAM_EXTENSION)"
    echo "  -l, --log_folder                Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  --against                       Specify what to map reads against: 'assemblies' or 'bins' (default: $DEFAULT_AGAINST)"
    echo "      -a, --input_folder              Specify the path of the input folder for assemblies or bins (default: depends on --against, either $DEFAULT_INPUT_FOLDER_ASSEMBLIES or $DEFAULT_INPUT_FOLDER_BINS)"
    echo "      -t, --target_pattern            Specify the target file name or extension (default: depends on --against, either $DEFAULT_TARGET_FILE or $DEFAULT_TARGET_EXTENSION)"
    echo "      -o, --output_folder             Specify the path of the output folder (default: depends on --against, either mapping/reads2assemblies or mapping/reads2bins)"
    echo "      Only use when against="assemblies":"
    echo "      --self_mapping                  Only map reads if the sample name matches the target name (default: $DEFAULT_SELF_MAPPING)"
    echo "  -h, --help                   Display this help message"
    echo "  --                              Separator to pass following options to the script/command being executed"
    echo "  [strobealign options]           Options for strobealign command"
}

# Variables
working_directory="$DEFAULT_WORKING_DIRECTORY"
input_folder_reads="$DEFAULT_INPUT_FOLDER_READS"
output_folder=""
read_extension="$DEFAULT_READ_EXTENSION"
bam_extension="$DEFAULT_BAM_EXTENSION"
log_folder="$DEFAULT_LOG_FOLDER"
self_mapping="$DEFAULT_SELF_MAPPING"
against="$DEFAULT_AGAINST"
input_folder=""
target_pattern=""

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
            shift 2
            ;;
        -r|--input_folder_reads)
            input_folder_reads="$2"
            shift 2
            ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
            ;;
        -x|--read_extension)
            read_extension="$2"
            shift 2
            ;;
        -m|--bam_extension)
            bam_extension="$2"
            shift 2
            ;;
        -l|--log_folder)
            log_folder="$2"
            shift 2
            ;;
        --self_mapping)
            self_mapping=false
            shift
            ;;
        --against)
            against="$2"
            shift 2
            ;;
        -a|--input_folder)
            input_folder="$2"
            shift 2
            ;;
        -t|--target_pattern)
            target_pattern="$2"
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

# Adjust defaults based on --against parameter
if [[ "$against" == "bins" ]]; then
    input_folder=${input_folder:-$DEFAULT_INPUT_FOLDER_BINS}
    target_pattern=${target_pattern:-$DEFAULT_TARGET_EXTENSION}
else
    input_folder=${input_folder:-$DEFAULT_INPUT_FOLDER_ASSEMBLIES}
    target_pattern=${target_pattern:-$DEFAULT_TARGET_FILE}
fi

output_folder=${output_folder:-"mapping/reads2${against}"}

# Remaining arguments are for the script to run
cmd_options=("$@")

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Check if strobealign is installed
if ! command -v strobealign &> /dev/null; then
    log_message "strobealign could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

# Setting folders and working space
cd $working_directory
mkdir -p $output_folder

log_message "Running strobealign"

index=1

if [[ "$against" == "bins" ]]; then
    log_message "Concatenating bin files to create the bins database"
    cat $input_folder/*$target_pattern > $output_folder/bins_db.fna
    target_db="$output_folder/bins_db.fna"
    total_index=$(ls $input_folder_reads/*1$read_extension | wc -l)
else
    total_index=$(ls $input_folder | wc -l)
fi

for read1 in $(ls $input_folder_reads/*1$read_extension); do

    read1=$(basename $read1)
    read2=${read1/1./2.}
    sample=$(echo $read1 | sed -E "s/($read_extension|\.fq|\.fastq)//g" | sed -E "s/(.*)_(R[0-9]+|[0-9]+)/\1/")

    log_message "Iteration $index/$total_index"
    echo "Sample: $sample"
    echo "Read forward: $read1"
    echo "Read reverse: $read2"

    if [[ "$against" == "assemblies" ]]; then
        for input_folder_assembly in $(ls $input_folder); do
            assembly=$(basename $input_folder_assembly)
            echo "Assembly: $assembly"
            mkdir -p $output_folder/$assembly
            if [[ $self_mapping == true && "$assembly" != "$sample" ]]; then
                log_message "Skipping mapping for sample $sample as it does not match assembly $assembly"
                continue
            fi
            target_db="$input_folder/$assembly/$target_pattern"
            strobealign \
            $target_db \
            $input_folder_reads/$read1 \
            $input_folder_reads/$read2 \
            -t $SLURM_CPUS_PER_TASK \
            "${cmd_options[@]}" | samtools sort \
            -o $output_folder/$assembly/${sample}_on_${assembly}${bam_extension}
            samtools index $output_folder/$assembly/${sample}_on_${assembly}${bam_extension}
        done
    else
        strobealign \
        $target_db \
        $input_folder_reads/$read1 \
        $input_folder_reads/$read2 \
        -t $SLURM_CPUS_PER_TASK \
        "${cmd_options[@]}" | samtools sort \
        -o $output_folder/${sample}${bam_extension}
        samtools index $output_folder/${sample}${bam_extension}
    fi
    ((index++))
done

log_message "Running strobealign done for all samples!"
