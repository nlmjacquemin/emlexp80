# 🧰 Wrappers

This folder contains all the tool-specific scripts that define **how each software is executed inside its container** in the `emlexp80` pipeline. These wrappers handle command-line options, file handling, and tool logic, and are intended to be executed via the `apptainer.sh` runner script.

Each wrapper is paired with:

-   A corresponding container image (built from `dockerfiles/`)
-   A SLURM `submitter` script that schedules its execution

---

## 🧱 Role in the Pipeline

-   Wrappers **do not execute directly**: they are invoked through `apptainer.sh`, which takes care of container loading and runtime environment setup.
-   Each wrapper accepts parameters such as `--working_directory`, `--input_folder`, or `--threads`, and handles input/output paths relative to the project folder.
-   Tool-specific logic such as paired-end file detection or format validation is handled here.

---

## 📄 Available Wrappers

| Script        | Tool        | Task                          |
| ------------- | ----------- | ----------------------------- |
| `fastp`       | fastp       | Read quality control          |
| `megahit`     | MEGAHIT     | Assembly of reads             |
| `basalt`      | BASALT      | Genome binning and refinement |
| `strobealign` | Strobealign | Read alignment                |
| `gtotree`     | GToTree     | Phylogenomic reconstruction   |
| `metabolic`   | METABOLIC   | Functional annotation         |
| `coverm`      | CoverM      | Abundance estimation          |
| `gtdbtk`      | GTDBtk      | Toxonomic assignment          |
| `checkm`      | Checkm2     | Read QC                       |
| `quast`       | Quast       | Assembly QC                   |
| `motus`       | mOTUs       | Marker gene-based profiling   |
