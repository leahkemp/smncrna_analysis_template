#!/bin/bash

#SBATCH --job-name=excerpt_test_data
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=leah.kemp@esr.cri.nz
#SBATCH --output=excerpt_test_data_%j.log

##### INFO #####

# this script downloads the input files for the excerpt pipeline, generates a txt file with
# a list of fastq files in the user specified directory which is used to run the samples in
# parallel through the latest version of the excerpt pipeline
# BEWARE: the excerpt database that is a big boi is downloaded in this script

##### USER CONFIGURATION #####

# set the path to the directory containing the input fastq files
fastq_dir="/NGS/scratch/KSCBIOM/HumanGenomics/smncrna_analysis_template/test/fastq"

# set the path to your smncrna_analysis_template directory
template_dir="/NGS/scratch/KSCBIOM/HumanGenomics/smncrna_analysis_template"

# set the directory to where the excerpt database will be downloaded
# BEWARE: this database is a big boi that need space
database_dir="/NGS/scratch/KSCBIOM/HumanGenomics/publicData/excerptDB/hg38/"

# choose if the hg19 or hg38 excerpt database should be downloaded
genome_version="hg38"

# set the minimum read length for trimming
min_read_length="17"

# set the number of threads to use per sample
threads="4"

# set the java memory allocation per sample
memory="24G"

# set the number of samples to analyse at one time
# note. this will multiply the threads and java_ram
num_parallel_samples="4"

##### SCRIPT #####

# create the directory to download the exerpt database if it doesn't yet exist
mkdir -p $database_dir

# also create the directory to put merged results downstream if it doesn't yet exist
mkdir -p $template_dir/excerpt_pipeline_run/merged/

# download the excerpt database
if [[ $genome_version == "hg19" ]]; then
	# download the database file into the user specified directory
    wget http://org.gersteinlab.excerpt.s3-website-us-east-1.amazonaws.com/exceRptDB_v4_hg19_lowmem.tgz -P $database_dir
    # unzip
    tar -xvf $database_dir/exceRptDB_v4_hg19_lowmem.tgz --directory $database_dir
    # cleanup
    rm $database_dir/exceRptDB_v4_hg19_lowmem.tgz
elif [[ $genome_version == "hg38" ]]; then
	# download the database file into the user specified directory
    wget http://org.gersteinlab.excerpt.s3-website-us-east-1.amazonaws.com/exceRptDB_v4_hg38_lowmem.tgz -P $database_dir
    # unzip
    tar -xvf $database_dir/exceRptDB_v4_hg38_lowmem.tgz --directory $database_dir
    # cleanup
    rm $database_dir/exceRptDB_v4_hg38_lowmem.tgz
else
    echo "Please set genome_version to either hg19 or hg38"
fi

# get list of files in the fastq dir (without hidden files)
ls -A $fastq_dir > $template_dir/excerpt_pipeline_run/fastq_files_tmp.txt

# strip the '.fastq.gz' suffix to just have sample names
cat $template_dir/excerpt_pipeline_run/fastq_files_tmp.txt | sed "s/.fastq.gz//" > $template_dir/excerpt_pipeline_run/fastq_files.txt

# remove temp file
rm $template_dir/excerpt_pipeline_run/fastq_files_tmp.txt

# run excerpt pipeline, run in parallel over all files specified in fastq_files.txt
parallel -j $num_parallel_samples \
"docker run -v $fastq_dir:/exceRptInput \
                -v $template_dir/excerpt_pipeline_run:/exceRptOutput \
                -v $database_dir/$genome_version/:/exceRpt_DB/$genome_version \
                -t rkitchen/excerpt:latest \
                INPUT_FILE_PATH=/exceRptInput/{}.fastq.gz \
                MIN_READ_LENGTH=$min_read_length \
                TRIM_N_BASES_5p=4 \
                TRIM_N_BASES_3p=4 \
                N_THREADS=$threads \
                JAVA_RAM=$memory \
                ADAPTER_SEQ=TGGAATTCTCGG" >> excerpt_pipeline_run_log.txt :::: fastq_files.txt
