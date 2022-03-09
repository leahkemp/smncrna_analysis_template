# smncRNA analysis

## Overview of the analysis

The small RNA-seq data was analysed with [smrnaseq version 1.1.0](https://github.com/nf-core/smrnaseq/tree/1.1.0) and [excerpt version 4.3.2](https://github.com/rkitchen/exceRpt/tree/4.3.2). The outputs of these pipelines were then analysed with the [smncrna_analysis_template 3.2.5](https://github.com/leahkemp/smncrna_analysis_template/tree/3.2.5). The following treatment groups were compared for analysis:

- treatment1 vs. treatment2
- treatment1 vs. treatment3

The full analysis has been documented so others can take a "deep dive" into the analysis to check/reproduce the work.

## Quality control reports

### Both pipelines

- [Sequencing read QC](./example_webpage/sequencing_read_QC.html)

### excerpt

- [Diagnostic plots](./test/excerpt_pipeline_run/merged/exceRpt_DiagnosticPlots.pdf)

### smrnaseq

- [Mirtrace report](./test/smrnaseq_pipeline_run/results/miRTrace/mirtrace/mirtrace-report.html)
- [MultiQC report](./test/smrnaseq_pipeline_run/results/MultiQC/multiqc_report.html)

## RNA counts/expression

- [RNA expression plotting](https://esr-cri.shinyapps.io/expression_plotting_example/)

## MDS/PCA plotting

- [MDS plots](./example_webpage/mds.html)
- [PCA plots](https://esr-cri.shinyapps.io/pca_example/)

## RNA composition

- [RNA species composition - samples](./example_webpage/rna_species_composition_samples.html)
- [RNA species composition - treatments](./example_webpage/rna_species_composition_treatments.html)
  
## Differential expression

### limma/voom

- [Differential expression (limma/voom)](./example_webpage/diff_expression_limma_voom.html)
- [Differential expression volcano plots (limma/voom)](./example_webpage/diff_expression_limma_voom_volcano.html)
- [Differential expression results (limma/voom)](./example_webpage/diff_expression_limma_voom_results.html)

### deseq2

- [Differential expression (deseq2)](./example_webpage/diff_expression_deseq.html)
- [Differential expression MA plots (deseq2)](./example_webpage/diff_expression_deseq_ma.html)
- [Differential expression volcano plots (deseq2)](./example_webpage/diff_expression_deseq_volcano.html)
- [Differential expression results (deseq2)](./example_webpage/diff_expression_deseq_results.html)

### Both differential expression methods

- [Differential expression - all results](./example_webpage/diff_expression_all_results.html)

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

**Outline where the project is located on which machine/server/cluster**

Analysis located at `/my_project/smncrna_analysis_template/` on ESR's production network

**Link your analysis documentation here**

- [setup.md](./setup.md)
- [running_excerpt_pipeline.md](./excerpt_pipeline_run/running_excerpt_pipeline.md)
- [running_smrnaseq_pipeline.md](./smrnaseq_pipeline_run/running_smrnaseq_pipeline.md)
- [master.Rmd](./master.Rmd)

## Extra

**Provide link to your github repository with all your analyses**

*Find more in the [github repository](https://github.com/leahkemp/my_project)*
