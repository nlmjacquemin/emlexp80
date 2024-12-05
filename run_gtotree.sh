#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY="/data"
DEFAULT_INPUT_FOLDER="analysis/gtotree"
DEFAULT_GTDBTK_FOLDER="analysis/gtdb/classify"
DEFAULT_OUTGROUP="GCF_000195915.1"
DEFAULT_INPUT_GENOME_FOLDERS="binning/basalt/Final_bestbinset" # run_prepare_bins
DEFAULT_INPUT_GENOME_EXTENSIONS=".fa" # run_prepare_bins
DEFAULT_CHECKM_QC_FILE="analysis/checkm/quality_report.tsv" # run_prepare_bins
DEFAULT_GENOME_PATHS_FILE="genome_paths.tsv"  # This file contains paths of genome files
DEFAULT_ACCESSION_FILE="accession_file.tsv"
DEFAULT_OUTPUT_FOLDER="analysis/gtotree/result"
DEFAULT_MARKER_GENES="Bacteria_and_Archaea"
DEFAULT_JOBS=1  # Default 

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory     Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -f, --input_folder          Specify the input folder (default: $DEFAULT_INPUT_FOLDER)"
    echo "  -i, --input_genome_folders  Specify input genome folders, comma-separated (default: $DEFAULT_INPUT_GENOME_FOLDERS)"
    echo "  -e, --input_genome_extensions Specify genome extensions (default: $DEFAULT_INPUT_GENOME_EXTENSIONS)"
    echo "  -g, --genome_paths          Specify the file containing genome paths (default: $DEFAULT_GENOME_PATHS_FILE)"
    echo "  -a, --accession_file        Specify the accession file (default: $DEFAULT_ACCESSION_FILE)"
    echo "  -o, --output_folder         Specify the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -l, --log_folder            Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -m, --marker_genes          Specify the marker genes for GToTree (default: $DEFAULT_MARKER_GENES)"
    echo "  -j, --jobs                  Number of concurrent jobs not that cpus given to hmmsearch (-n) and alignments with MUSCLE (-M) as well as Tree algorithm would be multipled (default: $DEFAULT_JOBS)"
    echo "  -t, --gtdbtk_folder         Specify the GTDB-Tk folder (default: $DEFAULT_GTDBTK_FOLDER)"
    echo "  -u, --outgroup              Specify the outgroup (default: $DEFAULT_OUTGROUP)"
    echo "  --                          Separator to pass following options to the command being executed"
}

# Default variables
log_folder="$DEFAULT_LOG_FOLDER"
working_directory="$DEFAULT_WORKING_DIRECTORY"
input_folder="$DEFAULT_INPUT_FOLDER"
input_genome_folders="$DEFAULT_INPUT_GENOME_FOLDERS"
input_genome_extensions="$DEFAULT_INPUT_GENOME_EXTENSIONS"
checkm_qc_file="$DEFAULT_CHECKM_QC_FILE"
genome_paths_file="$DEFAULT_GENOME_PATHS_FILE"
accession_file="$DEFAULT_ACCESSION_FILE"
output_folder="$DEFAULT_OUTPUT_FOLDER"
marker_genes="$DEFAULT_MARKER_GENES"
jobs="$DEFAULT_JOBS"
gtdbtk_folder="$DEFAULT_GTDBTK_FOLDER"
outgroup="$DEFAULT_OUTGROUP"

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
            shift 2
            ;;
        -f|--input_folder)
            input_folder="$2"
            shift 2
            ;;
        -i|--input_genome_folders)
            input_genome_folders="$2"
            shift 2
            ;;
        -e|--input_genome_extensions)
            input_genome_extensions="$2"
            shift 2
            ;;
        -g|--genome_paths)
            genome_paths_file="$2"
            shift 2
            ;;
        -a|--accession_file)
            accession_file="$2"
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
        -m|--marker_genes)
            marker_genes="$2"
            shift 2
            ;;
        -j|--jobs)
            jobs="$2"
            shift 2
            ;;
        -t|--gtdbtk_folder)
            gtdbtk_folder="$2"
            shift 2
            ;;
        -u|--outgroup)
            outgroup="$2"
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

# Going to working directory
cd "$working_directory"

if [ ! -f $input_folder/$genome_paths_file ]; then
    echo "Getting genomes paths file..."
    # Run the prepare bins script
    bash ~/scripts/run_gtt_prepare_bins.sh \
        --working_directory "$working_directory" \
        --input_genome_folders "$input_genome_folders" \
        --input_genome_extensions "$input_genome_extensions" \
        --checkm_qc_file "$checkm_qc_file" \
        --genome_paths_file "$genome_paths_file" \
        --output_folder "$input_folder" \
        --log_folder "$log_folder"
else
    echo "Genome paths file already created, using it for GToTree."
fi


if [ ! -f $input_folder/$accession_file ]; then
    echo "Getting accession file..."
    # Run the prepare accessions script
    bash ~/scripts/run_gtt_prepare_accession.sh \
        --working_directory "$working_directory" \
        --input_folder "$gtdbtk_folder" \
        --output_folder "$input_folder" \
        --accession_file "$accession_file" \
        --outgroup "$outgroup" \
        --log_folder "$log_folder"
else
    echo "Accession file already created, using it for GToTree."
fi

# Run GToTree with the genome paths file
GToTree \
    -f "$input_folder/$genome_paths_file" \
    -a "$input_folder/$accession_file" \
    -H "$marker_genes" \
    -o "$output_folder" \
    -D \
    -j "$jobs" \
    "${cmd_options[@]}"
