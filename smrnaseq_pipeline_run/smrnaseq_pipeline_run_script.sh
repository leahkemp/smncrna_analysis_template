#!/bin/bash

##### INFO #####

# this script downloads the input files (microRNA database) for the smrnaseq pipeline from mirbase,
# automatically downloads the latest version of the smrnaseq pipeline and analyses the samples in
# parallel

##### USER PARAMETERS #####

# set the path to the fastq files to be analysed
fastq_files="/my_project/smncrna_analysis_template/fastq/*.fastq.gz"

# set the directory to where the smrnaseq database (mirbase) will be downloaded
smrnaseq_database_dir="/my_project/smncrna_analysis_template/publicData/mirbase"

# choose if the GRCh37 or GRCh38 smrnaseq database should be used in the pipeline
genome_version="GRCh37"

# set the adapter to use in trimming
adapter="nextflex"

# set the minimum read length
min_read_length="17"

##### SCRIPT #####

# create the directory to download the exerpt database if it doesn't yet exist
mkdir -p $smrnaseq_database_dir

# download the database file
wget ftp://mirbase.org:21/pub/mirbase/CURRENT/ -P $smrnaseq_database_dir

# unzip
for i in $smrnaseq_database_dir/mirbase.org/pub/mirbase/CURRENT/*; do
gunzip $i
done

# run smrnaseq pipeline
run nf-core/smrnaseq \
--reads '$fastq_files' \
--protocol $adapter \
-profile singularity \
--mature $smrnaseq_database_dir/mirbase.org/pub/mirbase/CURRENT/mature.fa \
--hairpin $smrnaseq_database_dir/mirbase.org/pub/mirbase/CURRENT/hairpin.fa \
--genome $genome_version \
--mirtrace_species hsa \
--mirna_gtf $smrnaseq_database_dir/mirbase.org/pub/mirbase/CURRENT/genomes/hsa.gff3 \
--saveReference \
-resume \
--illumina \
--min_length $min_read_length
```