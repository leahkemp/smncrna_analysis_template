#!/bin/bash

parallel -j 2 \
"docker run -v /data/lkemp/test_new/fastq/:/exceRptInput \
                -v /data/lkemp/test_new/exceRpt_output:/exceRptOutput \
                -v /share/excerpt_data/hg38/:/exceRpt_DB/hg38 \
                -t rkitchen/excerpt:latest \
                INPUT_FILE_PATH=/exceRptInput/{}.fastq.gz \
                MIN_READ_LENGTH=17 \
                TRIM_N_BASES_3p=4 \
                TRIM_N_BASES_5p=4 \
                N_THREADS=4 \
                JAVA_RAM=24G \
                ADAPTER_SEQ=TGGAATTCTCGGGTGCCAAGG \
                ENDOGENOUS_LIB_PRIORITY=miRNA,tRNA,piRNA,circRNA,gencode \
                MAIN_ORGANISM_GENOME_ID=hg38 \
                STAR_outFilterMatchNmin=17" >> excerpt_log.txt :::: sample_ids.txt