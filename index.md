# smncRNA analysis

## Overview of the analysis

The small non-coding RNA-seq data was analysed with [smrnaseq version 1.1.0](https://github.com/nf-core/smrnaseq/tree/1.1.0) and [excerpt version 4.3.2](https://github.com/rkitchen/exceRpt/tree/4.3.2). The outputs of these pipelines were then analysed with the [smncrna_analysis_template](https://github.com/leahkemp/smncrna_analysis_template). The following treatment groups were compared for analysis:

- treatment1 vs. treatment2
- treatment1 vs. treatment3

The full analysis has been documented so others can take a "deep dive" into the analysis to check/reproduce the work.

## Quality control reports

- [Sequencing read QC](./example_webpage/sequencing_read_QC.html)
- [Diagnostic plots - excerpt](./test/excerpt_pipeline_run/merged/exceRpt_DiagnosticPlots.pdf)

## RNA counts/expression

- [RNA expression plotting](https://esr-cri.shinyapps.io/expression_plotting_example/)

## MDS/PCA plotting

- [MDS plots](./example_webpage/mds.html)
- [PCA plots](https://esr-cri.shinyapps.io/pca_example/)

## RNA composition

- [RNA species composition](./example_webpage/rna_species_composition.html)
  
## Differential expression

- [Differential expression](./example_webpage/diff_expression.html)

## Heatmaps

- [Heatmaps](./example_webpage/heatmaps.html)

## Presence/absence

- [Presence/absence](./example_webpage/presence_absence.html)

## Raw count data

- [smrnaseq miRNA](./test/smrnaseq_pipeline_run/results/edgeR/miRBase_mature/mature_counts.csv)
- [exceRpt miRNA](./test/excerpt_pipeline_run/merged/exceRpt_miRNA_ReadCounts.txt)
- [exceRpt piRNA](./test/excerpt_pipeline_run/merged/exceRpt_piRNA_ReadCounts.txt)
- [exceRpt tRNA](./test/excerpt_pipeline_run/merged/exceRpt_tRNA_ReadCounts.txt)
- [exceRpt circularRNA](./test/excerpt_pipeline_run/merged/exceRpt_circularRNA_ReadCounts.txt)
- [exceRpt gencode](./test/excerpt_pipeline_run/merged/exceRpt_gencode_ReadCounts.txt)

## Analysis workflow for reproducing this analysis

- [master.Rmd](./master.Rmd)
