#!/bin/bash
#SBATCH --job-name=smrnaseq
#SBATCH --mail-type=END,FAIL
#SBATCH --ntasks=1
#SBATCH --mem=20gb
#SBATCH --time=01:00:00
#SBATCH --output=smrnaseq_%j.log

module purge

nextflow run nf-core/smrnaseq \
--input '/NGS/scratch/KSCBIOM/HumanGenomics/smncrna_analysis_template/test/fastq/*.fastq.gz' \
--protocol nextflex \
-profile singularity \
--mature /NGS/scratch/KSCBIOM/HumanGenomics/publicData/mirbase.org/pub/mirbase/CURRENT/mature.fa \
--hairpin /NGS/scratch/KSCBIOM/HumanGenomics/publicData/mirbase.org/pub/mirbase/CURRENT/hairpin.fa \
--mirna_gtf /NGS/scratch/KSCBIOM/HumanGenomics/publicData/mirbase.org/pub/mirbase/CURRENT/genomes/hsa.gff3 \
--mirtrace_species hsa \
--saveReference \
-resume \
--min_length 17 \
--skip_mirdeep