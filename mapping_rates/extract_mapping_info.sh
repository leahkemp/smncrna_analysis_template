#!/bin/bash

##### INFO #####

# this script gets various info from the raw fastq files and smrnaseq and excerpt pipeline
# outputs for all samples relating to the number of raw reads and number of reads trimmed,
# clipped and mapped. it outputs several text files and parses/uses the config.yaml file
# from the smncrna_analysis_template the user sets paratemers in

##### SCRIPT #####

# a bash-only parser that leverages sed and awk to parse simple yaml files
# grabbed from here: https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# parse and create bash variables out of everything in the configuration file
eval $(parse_yaml config.yaml)

# remove any old outputs of this script to avoid results being written twice to a file
rm -rf $template_dir/mapping_rates/extracted_all_samples
rm -rf $template_dir/smrnaseq_pipeline_run/results/fastqc_unzipped
rm -rf $template_dir/mapping_rates/mapping_rates.csv

# make directory to put results in if it doesn't yet exist
mkdir -p $template_dir/mapping_rates/extracted_all_samples/

# also make a directory to put unzipped fastqc files in if it doesn't yet exist
mkdir -p $template_dir/smrnaseq_pipeline_run/results/fastqc_unzipped

# unzip fastqc output files so info can be grabbed from them
for i in $template_dir/smrnaseq_pipeline_run/results/fastqc/*.zip
do
unzip $i -d $template_dir/smrnaseq_pipeline_run/results/fastqc_unzipped/
done

# get the number of read in the raw fastq files
for i in $fastq_dir/*
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/raw_read_count_fastq_file.txt
done

# get the number of reads in fastq files after clipping (excerpt pipeline run)
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq/*.fastq.clipped.fastq.gz`
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/excerpt_clipped_read_count_fastq_file.txt
done

# get the number of reads in fastq files after clipping and trimming (excerpt pipeline run)
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq/*.fastq.clipped.trimmed.fastq.gz`
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/excerpt_clipped_trimmed_read_count_fastq_file.txt
done

# get the number of reads in fastq files after clipping, trimming and filtering (excerpt pipeline run)
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq/*.fastq.clipped.trimmed.filtered.fastq.gz`
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/excerpt_clipped_trimmed_filtered_read_count_fastq_file.txt
done

# get the number of reads in fastq files after clipping, trimming, filtering and removing ribosomal RNA (excerpt pipeline run)
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq.stats`
do
grep "failed_quality_filter" $i | cut -d $'\t' -f2- >> $template_dir/mapping_rates/extracted_all_samples/excerpt_failed_quality_filter_read_count_stats_file.txt
done

# get number of reads that failed the homopolymer filter
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq.stats`
do
grep "failed_homopolymer_filter" $i | cut -d $'\t' -f2- >> $template_dir/mapping_rates/extracted_all_samples/excerpt_failed_homopolymer_filter_read_count_stats_file.txt
done

# get number of reads that were used for alignment (excerpt pipeline run)
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq.stats`
do
grep "reads_used_for_alignment" $i | cut -d $'\t' -f2- >> $template_dir/mapping_rates/extracted_all_samples/excerpt_reads_used_for_alignment_stats_file.txt
done

# get number of reads that were not mapped to genome or libs (excerpt pipeline run)
for i in `ls $template_dir/excerpt_pipeline_run/exceRpt_output/*.fastq.stats`
do
grep "not_mapped_to_genome_or_libs" $i | cut -d $'\t' -f2- >> $template_dir/mapping_rates/extracted_all_samples/excerpt_not_mapped_to_genome_or_libs_stats_file.txt
done

# get the number of read in the raw fastq files based on the fastqc file (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/fastqc_unzipped/*_fastqc/fastqc_data.txt`
do
grep "Total Sequences" $i | cut -d $'\t' -f2- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_raw_read_count_fastqc_file.txt
done

# get the number of reads in fastq files after trimming (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/trim_galore/*_trimmed.fq.gz`
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_trimmed_read_count_fastq_file.txt
done

# get the number of QC passed reads in fastq files (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/miRTrace/mirtrace/qc_passed_reads.all.collapsed/*.fasta`
do
echo $(cat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_qc_passed_read_count_fastq_file.txt
done

# get the number of QC passed reads for which the rna type is unknown in fastq files (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/miRTrace/mirtrace/qc_passed_reads.rnatype_unknown.collapsed/*.fasta`
do
echo $(cat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_qc_passed_rna_type_unknown_read_count_fastq_file.txt
done

# get number of reads that were mapped to the reference genome (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie_ref/*.genome.sorted.bam.stats`
do
grep "reads mapped:" $i | cut -d $'\t' -f3- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_mapped_to_ref_bowtie_stats_file.txt
done

# get number of reads that were un-mapped to the reference genome (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie_ref/*.genome.sorted.bam.stats`
do
grep "reads unmapped:" $i | cut -d $'\t' -f3- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_unmapped_to_ref_bowtie_stats_file.txt
done

# get number of reads that were un-mapped to the reference genome (based on summary file) (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie_ref/unmapped/unmapped_refgenome.txt`
do
cat $i | cut -d $'\t' -f2- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_unmapped_to_ref_summary_file.txt
done

# get number of reads that were mapped to mature mirnas (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie/miRBase_mature/*.mature.sorted.bam.stats`
do
grep "reads mapped:" $i | cut -d $'\t' -f3- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_mapped_to_mature_bowtie_stats_file.txt
done

# get number of reads that were un-mapped to mature mirnas (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie/miRBase_mature/*.mature.sorted.bam.stats`
do
grep "reads unmapped:" $i | cut -d $'\t' -f3- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_unmapped_to_mature_bowtie_stats_file.txt
done

# get the number of reads in fastq files that were un-mapped to mature mirnas (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie/miRBase_mature/*.mature_unmapped.fq.gz`
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_unmapped_to_mature_fastq_file.txt
done

# get number of reads that were mapped to hairpin mirnas (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie/miRBase_hairpin/*.hairpin.sorted.bam.stats`
do
grep "reads mapped:" $i | cut -d $'\t' -f3- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_mapped_to_hairpin_bowtie_stats_file.txt
done

# get number of reads that were un-mapped to hairpin mirnas (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie/miRBase_hairpin/*.hairpin.sorted.bam.stats`
do
grep "reads unmapped:" $i | cut -d $'\t' -f3- >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_unmapped_to_hairpin_bowtie_stats_file.txt
done

# get the number of reads in fastq files that were un-mapped to hairpin mirnas (smrnaseq pipeline run)
for i in `ls $template_dir/smrnaseq_pipeline_run/results/bowtie/miRBase_hairpin/*.hairpin_unmapped.fq.gz`
do
echo $(zcat ${i} | wc -l) /4 | bc >> $template_dir/mapping_rates/extracted_all_samples/smrnaseq_reads_unmapped_to_hairpin_fastq_file.txt
done

# merge all these files into a single csv file
python ./mapping_rates/merge_mapping_rates.py