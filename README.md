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
bash submit_denovo_pipeline.sh /path/to/project_folder
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

```
<project_folder>/
├── raw/reads/
├── qc/fastp/
├── assembly/megahit/
├── binning/basalt/
├── mapping/strobealign/
├── phylogeny/gtotree/
├── annotation/metabolic/
├── coverage/coverm/
├── quality/checkm2/
```

## ⚙️ Computational Environment

Scripts were executed on the EPFL high-performance computing (HPC) cluster using:

-   SLURM version 23.11.10
-   Apptainer version 1.2.5
-   Nodes: Dual Intel(R) Xeon(R) Platinum 8360Y (72 cores total), 3 TB SSD

## 🧪 Development

This pipeline is not maintained and is here for reproduciblity only.
