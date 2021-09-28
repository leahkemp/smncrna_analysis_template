# smncRNA analysis template

---

Analysis template for analysing, visualising and communicating the findings of [Illumina Small RNA sequencing](https://www.illumina.com/techniques/sequencing/rna-sequencing/small-rna-seq.html) data with a focus on small non-coding RNA's that are sometimes forgotten (ie. looking at and beyond miRNA's). This is set up to analyse human data, but can be adapted to other species with some tweaks to the code, namely the pipeline inputs. Think of this as a collection of scripts that will require some familiarity with UNIX/R rather than a fully automated workflow.

---

## Table of contents

- [smncRNA analysis template](#smncrna-analysis-template)
  - [Table of contents](#table-of-contents)
  - [What this template can do](#what-this-template-can-do)
  - [What this template can't do](#what-this-template-cant-do)
  - [What's this template gonna do?](#whats-this-template-gonna-do)
  - [Output files](#output-files)
    - [Raw counts](#raw-counts)
    - [Processed counts](#processed-counts)
    - [QC](#qc)
    - [Plotting/analysis](#plottinganalysis)
  - [How to use this template](#how-to-use-this-template)
    - [1. Fork the template repo to a personal or lab account](#1-fork-the-template-repo-to-a-personal-or-lab-account)
    - [2. Take this template to the data on your local machine](#2-take-this-template-to-the-data-on-your-local-machine)
    - [3. Format your input files](#3-format-your-input-files)
      - [fastq naming convention](#fastq-naming-convention)
      - [List of samples](#list-of-samples)
      - [Metadata file](#metadata-file)
    - [4. Configure the configuration file](#4-configure-the-configuration-file)
    - [5. Analyse your data](#5-analyse-your-data)
    - [6. Commit and push to your forked version of the github repo](#6-commit-and-push-to-your-forked-version-of-the-github-repo)
    - [7. Repeat step 5 each time you re-run the analysis with different parameters](#7-repeat-step-5-each-time-you-re-run-the-analysis-with-different-parameters)
    - [8. Create a github page (optional)](#8-create-a-github-page-optional)
    - [9. Contribute back!](#9-contribute-back)

## What this template can do

This template uses open source tools and includes several scripts for researchers to analyse, explore and communicate findings to other researchers through interactive tables and plots. The results of this template can be served as a [github page](https://pages.github.com/) that renders html files and provides links to RShiny apps hosted on [shinyapps.io](https://www.shinyapps.io/) - this means a single weblink can be given to your collaborators to provide them with all your analysis code and results. Most importantly, this template puts you in good steed to ensure your analysis is reproducible!

## What this template can't do

- Tell you what analysis tools and parameters are appropriate for your data or research question, the assumption is that the tools this template uses are tools you've intentionally chosen to use and that you will actively adapt this template for your use-case
- Account for different operating systems and compute infrastructures - this means there likely be some UNIX experience required to run the pipelines/scripts on your operating system or job scheduler. I won't tell you how to do this here, but the pipelines and tools used here are generally portable (ie. able to be run on different operating systems) and I've used [renv](https://rstudio.github.io/renv/articles/renv.html) environments to make the R code more portable
- The whole analysis isn't automated because it probably shouldn't be

## What's this template gonna do?

This template will guide you through processing the data through two pipelines:

- [smrnaseq](https://github.com/nf-core/smrnaseq)
- [exceRpt](https://github.com/rkitchen/exceRpt)

Both these pipelines undertake preprocessing, filtering, alignment, and reporting. These pipelines output counts of miRNA's (in the case of the first pipeline - [smrnaseq](https://github.com/nf-core/smrnaseq)) and other RNA's such as miRNA's, tRNA's, piRNA's, circRNA's etc. (in the case of the second pipeline - [exceRpt](https://github.com/rkitchen/exceRpt)).

Beyond the QC the pipelines undertake, additional QC is undertaken to summarise the read counts and mapping rates of the data.

These counts datasets output by the pipelines are analysed in [R](https://www.r-project.org/) to undertake a differential expression analysis of all these RNA species to find differently expressed RNA's. Two methods were employed to undertake a differential expression analysis, namely [limma/voom](https://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-2-r29) and [deseq2](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-014-0550-8).

Beyond a traditional differential expression analysis, the data is prepared and presented in an interactive [RShiny](https://shiny.rstudio.com/) app that allows the user to explore RNA expression (both raw counts and counts per million).

Interactive MDS and PCA plots are also created to explore clusters in the data.

Lastly, the composition of the RNA species are explored.

## Output files

The main output files you'll end up with:

### Raw counts

- smrnaseq read counts (smrnaseq_pipeline_run/results/mirtop/mirtop.tsv)
- exceRpt miRNA read counts (excerpt_pipeline_run/merged/exceRpt_miRNA_read counts.txt)
- exceRpt piRNA read counts (excerpt_pipeline_run/merged/exceRpt_piRNA_read counts.txt)
- exceRpt tRNA read counts (excerpt_pipeline_run/merged/exceRpt_tRNA_read counts.txt)
- exceRpt circularRNA read counts (excerpt_pipeline_run/merged/exceRpt_circularRNA_read counts.txt)
- exceRpt gencode read counts (excerpt_pipeline_run/merged/exceRpt_gencode_read counts.txt)

### Processed counts

- raw, counts per million and log counts per million for all samples and RNA species (prepare_counts/counts.csv)

### QC

- Multiqc report - smrnaseq (smrnaseq_pipeline_run/results/MultiQC/multiqc_report.html)
- Mirtrace report - smrnaseq (smrnaseq_pipeline_run/results/miRTrace/mirtrace/mirtrace-report.html)
- Diagnostic plots - excerpt (excerpt_pipeline_run/merged/exceRpt_DiagnosticPlots.pdf)
- Sequencing read QC (sequencing_read_QC/sequencing_read_QC.html)

### Plotting/analysis

- RNA expression plotting ()
- MDS plots (mds/mds.html)
- PCA plots ()
- RNA species composition (rna_species_composition/rna_species_composition.html)
- Differential expression (diff_expression/diff_expression.html)

## How to use this template

### 1. Fork the template repo to a personal or lab account

See [here](https://help.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository) for help

### 2. Take this template to the data on your local machine

Clone the forked [smncrna_analysis_template](https://github.com/leahkemp/smncrna_analysis_template) repo to the machine you'd like to analyse the data on

```bash
git clone https://github.com/leahkemp/smncrna_analysis_template.git
```

### 3. Format your input files

#### fastq naming convention

```bash
S*_R1.fastq.gz
```

#### List of samples



#### Metadata file

Columns:

- "sample"
- "treatment"

### 4. Configure the configuration file

Set up [rna_species_config.yaml](rna_species_config.yaml)

### 5. Analyse your data

- [Run smrnaseq pipeline](./smrnaseq_pipeline_run/run_smrnaseq_pipeline.md)
- [Run excerpt pipeline](./excerpt_pipeline_run/run_excerpt_pipeline.md)
- [Summarise the read counts/mapping rates for both pipelines](./mapping_rates/calculate_mapping_metrics.md)
- [Prepare count data](./prepare_counts/prepare_counts.Rmd)
- [RNA species composition plotting](./rna_species_composition/rna_species_composition.Rmd)
- [MDS plots](./mds/mds.Rmd)
- PCA plots:
  - [Data prep for app](./pca/data_prep_for_app.R)
  - Deploy RShiny app to ESR's shinyapps IO account, see the [server](./pca/server.R) and [ui](./pca/ui.R) that comprise the app
- [Differential expression analysis](./diff_expression/diff_expression.Rmd)
- Expression plots:
  - [Data prep for app](./expression_plotting/data_prep_for_app.R)
  - Deploy RShiny app to ESR's shinyapps IO account, see the [server](./expression_plotting/server.R) and [ui](./expression_plotting/ui.R) that comprise the app

### 6. Commit and push to your forked version of the github repo

Push all the results files you're comfortable with being online:

- 

To maintain reproducibility of your analysis, commit and push:

- All configuration files
- All run scripts
- All your documentation/notes

### 7. Repeat step 5 each time you re-run the analysis with different parameters

### 8. Create a github page (optional)

### 9. Contribute back!

- Raise issues in [the issues page](https://github.com/leahkemp/smncrna_analysis_template/issues)
- Create feature requests in [the issues page](https://github.com/leahkemp/smncrna_analysis_template/issues)
- Contribute your code! Create your own branch from the [development branch](https://github.com/leahkemp/smncrna_analysis_template/tree/dev) and create a pull request to the [development branch](https://github.com/leahkemp/smncrna_analysis_template/tree/dev) once the code is on point!

Contributions and feedback are always welcome! :blush:
