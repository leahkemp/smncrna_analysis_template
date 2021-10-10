#!/bin/bash

#SBATCH --job-name=smrnaseq_test_data
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=leah.kemp@esr.cri.nz
#SBATCH --output=smrnaseq_test_data_%j.log

##### INFO #####

# this script downloads the input files (microRNA database) for the smrnaseq pipeline from mirbase,
# automatically downloads the latest version of the smrnaseq pipeline and analyses the samples in
# parallel

##### SCRIPT #####

# run smrnaseq pipeline
nextflow run nf-core/smrnaseq \
--input '/NGS/scratch/KSCBIOM/HumanGenomics/smncrna_analysis_template/test/fastq/*.fastq.gz' \
--protocol nextflex \
--genome GRCh38 \
--mirtrace_species hsa \
--min_length 17 \
-profile singularity \
--fasta /NGS/scratch/KSCBIOM/HumanGenomics/publicData/hg38/v0/Homo_sapiens_assembly38.fasta \
--mature /NGS/scratch/KSCBIOM/HumanGenomics/publicData/mirbase.org/pub/mirbase/CURRENT/mature.fa \
--hairpin /NGS/scratch/KSCBIOM/HumanGenomics/publicData/mirbase.org/pub/mirbase/CURRENT/hairpin.fa \
--mirna_gtf /NGS/scratch/KSCBIOM/HumanGenomics/publicData/mirbase.org/pub/mirbase/CURRENT/genomes/hsa.gff3 \
-resume