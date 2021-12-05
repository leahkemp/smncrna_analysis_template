# Small non-coding RNA hps - type two diabetes

## Overview of the analysis

The small non-coding RNA-seq data was analysed with [smrnaseq version 1.1.0](https://github.com/nf-core/smrnaseq/tree/1.1.0) and [excerpt version 4.3.2](https://github.com/rkitchen/exceRpt/tree/4.3.2). The outputs of these pipelines were then analysed with the [smncrna_analysis_template version 2.0.0](https://github.com/leahkemp/smncrna_analysis_template/tree/2.0.0) (with some tweaks to the code). The following treatment groups were compared for analysis:

- T2D vs. No_T2D (type two diabetes vs. no type two diabetes)

The full analysis has been documented so others can take a "deep dive" into the analysis to check/reproduce the work.

## Quality control reports

### Both pipelines

- [Sequencing read QC](./sequencing_read_QC/sequencing_read_QC.html)

### excerpt

- [Diagnostic plots](./excerpt_pipeline_run/merged/exceRpt_DiagnosticPlots.pdf)

### smrnaseq

*Note. this smrnaseq pipeline run took pre-trimmed fastq files output by the excerpt pipeline run, hence there will likely be some low trimming rates in the smrnaseq pipeline run (see [running_smrnaseq_pipeline.md](./smrnaseq_pipeline_run/running_smrnaseq_pipeline.md) for more info)*

- [Mirtrace report](./smrnaseq_pipeline_run_2/results/miRTrace/mirtrace/mirtrace-report.html)
- [MultiQC report](./smrnaseq_pipeline_run_2/results/MultiQC/multiqc_report.html)

## RNA counts/expression

- [RNA expression plotting](https://esr-cri.shinyapps.io/expression_plotting_hps_sncrna/)

## MDS/PCA plotting

- [MDS plots](./mds/mds.html)
- [PCA plots](https://esr-cri.shinyapps.io/pca_hps_sncrna/)

## RNA composition

- [RNA species composition - by treatment group](./rna_species_composition/rna_species_composition_treatments.html)
- [RNA species composition - by sample](./rna_species_composition/rna_species_composition_samples.html)
  
## Differential expression

- [Differential expression](./diff_expression/diff_expression.html)

## Heatmaps

- [Heatmaps](./heatmaps/heatmaps.html)

## Presence/absence

- [Presence/absence](./presence_absence/presence_absence.html)

## Raw count data

- [smrnaseq miRNA](./smrnaseq_pipeline_run_2/results/edgeR/miRBase_mature/mature_counts.csv)
- [exceRpt miRNA](./excerpt_pipeline_run/merged/exceRpt_miRNA_ReadCounts.txt)
- [exceRpt piRNA](./excerpt_pipeline_run/merged/exceRpt_piRNA_ReadCounts.txt)
- [exceRpt tRNA](./excerpt_pipeline_run/merged/exceRpt_tRNA_ReadCounts.txt)
- [exceRpt circularRNA](./excerpt_pipeline_run/merged/exceRpt_circularRNA_ReadCounts.txt)
- [exceRpt gencode](./excerpt_pipeline_run/merged/exceRpt_gencode_ReadCounts.txt)

## Analysis workflow for reproducing this analysis

Analysis located at `/NGS/scratch/KSCBIOM/HumanGenomics/hps_sncrna/` on ESR's production network

- [setup.md](./setup.md)
- [running_excerpt_pipeline.md](./excerpt_pipeline_run/running_excerpt_pipeline.md)
- [running_smrnaseq_pipeline.md](./smrnaseq_pipeline_run/running_smrnaseq_pipeline.md)
- [manual_mapping.md](./manual_mapping/manual_mapping.md)
- [master.Rmd](./master.Rmd)
- [check_unmapped_reads.md](./check_unmapped_reads/check_unmapped_reads.md)

## Extra

*Find more in the [github repository](https://github.com/leahkemp/hps_sncrna)*
