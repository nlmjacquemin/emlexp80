# Supplementary Scripts for Reproducible Analysis

Scripts used for the analysis presented in the paper:

**H. Sallet, M. Calvo, M. Titus, N. Jacquemin, K.L. Meibom, R. Bernier-Latmani.**  
_High-throughput cultivation and isolation of environmental anaerobes using selectively permeable hydrogel capsules._

## 📦 Overview

This repository contains SLURM-compatible scripts and containerized environments used in the bioinformatic metagenomic shotgun analysis.

Each step of the analysis—from raw read quality control to genome binning, annotation, and coverage analysis—is defined as an independent, containerized task. It enables reproducible and modular shotgun metagenomic processing using Apptainer and Docker images.

### Key Features

-   Modular design: each tool runs in its own container
-   Reproducible and portable across clusters supporting Apptainer and SLURM
-   SLURM-native job submission with dependency chaining
-   Outputs include bins, annotations, taxonomy, coverage, and phylogeny

## 📁 Repository Structure

| Folder         | Purpose                                                       |
| -------------- | ------------------------------------------------------------- |
| `dockerfiles/` | Dockerfiles and `build.sh` scripts to build modular images    |
| `submitters/`  | SLURM `sbatch_*.sh` scripts for submitting jobs per tool      |
| `wrappers/`    | Tool-specific logic used by the launcher (e.g. fastp, basalt) |

## ⚙️ Computational Environment

Scripts were executed on the EPFL high-performance computing (HPC) cluster using:

-   [SLURM](https://slurm.schedmd.com/quickstart_admin.html) version 23.11.10
-   [Apptainer](https://apptainer.org/docs/admin/main/installation.html) version 1.2.5
-   [Docker](https://docs.docker.com/desktop)
-   Nodes: Dual Intel(R) Xeon(R) Platinum 8360Y (72 cores total), 3 TB SSD

## 🚀 Quickstart

1. **Clone the Repository**

```bash
git clone https://github.com/nlmjacquemin/emlexp80.git
cd emlexp80
```

2. **Prepare Raw Reads**  
   Place your input FASTQ files in:

```bash
/.../project_folder/raw/reads/
```

3. **Build All Images (Docker → Apptainer)**

```bash
bash build_sifs.sh
```

### For de-novo

4. **Submit the Full _de novo_ Pipeline (SLURM)**

```bash
bash submit_denovo_pipeline.sh /path/to/project_folder /path/to/database_folder
```

Jobs will be submitted in the correct order using SLURM job dependencies.

### For reference-based profiling

4. **Submit the motus script (SLURM)**

```bash
bash submit_motus.sh /path/to/project_folder
```

## 🧬 Pipeline Steps and Tools

| Step                         | Tool/databases | CPUs (default) | Time (default) |
| ---------------------------- | -------------- | -------------- | -------------- |
| Taxonomic Databases download | gtdb           | 1              | 20h            |
| Metabolic Databases download | metabolic      | 1              | 48h            |
| Alignment Databases download | checkm2        | 1              | 4h             |
| Read QC & Trimming           | fastp          | 16             | 48h            |
| Read QC                      | fastqc         | 8              | 24h            |
| Assembly                     | megahit        | 72             | 72h            |
| Assembly QC                  | Quast          | 72             | 48h            |
| Binning                      | basalt         | 72             | 7d             |
| Bin QC                       | checkm2        | 72             | 96h            |
| Mapping                      | strobealign    | 72             | 96h            |
| Phylogeny                    | gtotree        | 72             | 24h            |
| Taxonomy                     | gtdbtk         | 64             | 72h            |
| Annotation                   | metabolic      | 72             | 48h            |
| Read abundance               | coverm         | 72             | 24h            |

## 📂 Output Structure

```text
project_folder/
├── raw/
│   ├── reads/
│   │   ├── *_R1.fastq.gz, *_R2.fastq.gz           # Raw paired-end reads
│   └── genomes/
│       └── *.fna, *.fasta                         # Input genomes for annotation
├── clean/
│   └── *_R1.clean.fq, *_R2.clean.fq               # Output of fastp
├── assembly/
│   └── megahit/
│       └── <sample>/
│           └── final.contigs.fa                   # Output of MEGAHIT
├── binning/
│   └── basalt/
│       ├── Final_bestbinset/
│       │   └── *.fa, *.fna                        # MAGs (best bins)
│       └── *_final.contigs.fa, *.fq               # Symlinks to assembly + reads
├── mapping/
│   ├── reads2bins/
│   │   ├── <sample>.sorted.bam                    # Strobealign BAMs
│   │   ├── <sample>.sorted.bam.bai
│   │   └── bins_db.fna                            # Concatenated bin reference
│   └── reads2assemblies/
│       ├── <assembly>/<sample>_on_<assembly>.sorted.bam
│       └── *.bam.bai
├── analysis/
│   ├── fastqc/
│   │   ├── raw/
│   │   │   ├── *_fastqc.html
│   │   │   └── *_fastqc.zip
│   │   └── clean/
│   │       ├── *_fastqc.html
│   │       └── *_fastqc.zip
│   ├── checkm/
│   │   └── checkm_quality.tsv                     # Output from CheckM2
│   ├── coverm/
│   │   └── coverm_abd.tsv                         # Genome abundance table
│   ├── gtdb/
│   │   └── classify/
│   │       ├── summary.tsv                        # GTDB-Tk classification
│   │       ├── metadata.tsv
│   │       ├── placement.pickle
│   │       └── *.log
│   ├── metabolic/
│   │   ├── genomes/
│   │   │   └── *.fna                              # Symlinked or reheadered genomes
│   │   └── METABOLIC_output/
│   │       ├── Pathway/*.tsv                      # KEGG and pathway profiles
│   │       ├── *.svg, *.html                      # Overview diagrams
│   │       └── Heatmap/
│   │           └── *.tsv
│   ├── gtotree/
│   │   └── result/
│   │       ├── *.faa, *.fna                       # Sequences used
│   │       ├── *.aln                              # Alignments
│   │       ├── *.tree                             # Final tree
│   │       └── *.tsv                              # Mapping files
│   └── quast/
│       └── megahit/
│           ├── report.txt, report.tsv
│           └── contigs_reports/
│               └── <sample>.tsv
├── result/
│   └── motus/
│       ├── intermediary/
│       │   └── <sample>.motus                     # Intermediate mOTUs profiles
│       └── abd.motus                              # Merged abundance table
├── db/                                            # Optional local database cache
│   ├── GTDB/
│   │   └── *.metadata.tsv, taxonomy files
│   ├── METABOLIC/
│   │   └── *.hmm, *.ko.list, *.fasta              # Downloaded DBs
│   └── CheckM2_database/
│       └── *.dmnd, *.json
├── scripts/                                       # Wrapper and runner scripts
│   └── <job_id>
│       └── run_*.sh, sbatch_*.sh, launcher.sh, apptainer.sh
```

## 🧪 Development

This pipeline is not maintained and is here for reproducibily only.
