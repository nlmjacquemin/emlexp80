#!/bin/bash
set -e

# Base working directory (adjust per project)
project_folder=$1
database_folder=$2

echo "Submitting DB downloads..."
jid_checkm_db=$(sbatch --parsable sbatch_get_checkm_db.sh $project_folder)
jid_metabolic_db=$(sbatch --parsable sbatch_get_metabolic_db.sh $project_folder)
jid_gtdb=$(sbatch --parsable sbatch_get_gtdb.sh $project_folder)

echo "Submitting FASTP..."
jid_fastp=$(sbatch --parsable sbatch_fastp.sh $project_folder)

echo "Submitting MEGAHIT (after FASTP)..."
jid_megahit=$(sbatch --parsable --dependency=afterok:$jid_fastp bash_megahit_loop.sh $project_folder)

echo "Submitting QUAST (after MEGAHIT)..."
jid_quast=$(sbatch --parsable --dependency=afterok:$jid_megahit sbatch_quast.sh $project_folder)

echo "Submitting BASALT (after MEGAHIT)..."
jid_basalt=$(sbatch --parsable --dependency=afterok:$jid_megahit sbatch_basalt.sh $project_folder)

echo "Submitting GTDBTK (after BASALT + DB)..."
jid_strobe=$(sbatch --parsable --dependency=afterok:$jid_basalt sbatch_gtdbtk.sh $project_folder)

echo "Submitting STROBEALIGN (after BASALT)..."
jid_strobe=$(sbatch --parsable --dependency=afterok:$jid_basalt sbatch_strobealign.sh $project_folder)

echo "Submitting CHECKM2 (after BASALT + DB)..."
jid_checkm=$(sbatch --parsable --dependency=afterok:$jid_basalt:$jid_checkm_db sbatch_checkm2.sh $project_folder)

echo "Submitting GTOTREE (after BASALT)..."
jid_gtotree=$(sbatch --parsable --dependency=afterok:$jid_basalt sbatch_gtotree.sh $project_folder)

echo "Submitting METABOLIC (after BASALT + DB)..."
jid_metabolic=$(sbatch --parsable --dependency=afterok:$jid_basalt:$jid_metabolic_db sbatch_metabolic.sh $project_folder)

echo "Submitting COVERM (after STROBEALIGN)..."
jid_coverm=$(sbatch --parsable --dependency=afterok:$jid_strobe sbatch_coverm.sh $project_folder)

echo "✅ All pipeline steps submitted with correct dependencies!"
