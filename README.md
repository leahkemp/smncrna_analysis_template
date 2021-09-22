# smncRNA analysis template

---

Analysis template for analysing Illumina Small RNA sequencing data with a focus on analysing small non-coding RNA's.

---

## Table of contents

- [smncRNA analysis template](#smncrna-analysis-template)
  - [Table of contents](#table-of-contents)
  - [What this template can do](#what-this-template-can-do)
  - [What this template can't do](#what-this-template-cant-do)
  - [What's the template gonna do?](#whats-the-template-gonna-do)
  - [Output files](#output-files)
  - [How to use this template](#how-to-use-this-template)
    - [1. Fork the template repo to a personal or lab account](#1-fork-the-template-repo-to-a-personal-or-lab-account)
    - [2. Take this template to the data on your local machine](#2-take-this-template-to-the-data-on-your-local-machine)
    - [3. Format your input files](#3-format-your-input-files)
    - [4. Analyse your data](#4-analyse-your-data)
    - [5. Commit and push to your forked version of the github repo](#5-commit-and-push-to-your-forked-version-of-the-github-repo)
    - [6. Repeat step 4 each time you re-run the analysis with different parameters](#6-repeat-step-4-each-time-you-re-run-the-analysis-with-different-parameters)
    - [7. Create a github page (optional)](#7-create-a-github-page-optional)
    - [8. Contribute back!](#8-contribute-back)

## What this template can do

This template uses open source tools and includes several scripts for researchers to analyse, explore and communicate findings to other researchers through interactive tables and plots. The results of this template can be served as a [github page](https://pages.github.com/) that renders html files and provides links to RShiny apps hosted on [shinyapps.io](https://www.shinyapps.io/) - this means a single weblink can be given to your collaborators to provide them with all your analysis code and results. Most importantly, this template puts you in good steed to ensure your analysis is reproducible!

## What this template can't do

- Tell you what analysis tools and parameters are appropriate for your data or research question, the assumption is that the tools this template uses are tools you've intentionally chosen to use and that you will actively adapt this template for your use-case
- Account for different operating systems - this means there might be some coding/bioinformatic skill required to run the pipelines/scripts on your operating system. I won't tell you how to do this here, but the pipelines and tools used here are generally portable (ie. able to be run on different operating systems) and I've used [renv](https://rstudio.github.io/renv/articles/renv.html) to make the R code more portable
- The whole analysis isn't automated because it probably shouldn't be

## What's the template gonna do?

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

- Smrnaseq read counts (mirtop.tsv)
- ExceRpt miRNA read counts (exceRpt_miRNA_read counts.txt)
- ExceRpt piRNA read counts (exceRpt_piRNA_read counts.txt)
- ExceRpt tRNA read counts (exceRpt_tRNA_read counts.txt)
- ExceRpt circularRNA read counts (exceRpt_circularRNA_read counts.txt)
- ExceRpt gencode read counts (exceRpt_gencode_read counts.txt)
- Sequencing read QC (sequencing_read_QC.html)
- Multiqc report - smrnaseq (multiqc_report.html)
- Mirtrace report - smrnaseq (mirtrace-report.html)
- Diagnostic plots - excerpt (exceRpt_DiagnosticPlots.pdf)
- RNA expression plotting (http://your-account.shinyapps.io/rna_expression_plotting)
- MDS/PCA plots (clustering.html)
- RNA species composition (rna_species_composition.html)
- Differential expression (diff_expression.html)

## How to use this template

### 1. Fork the template repo to a personal or lab account

See [here](https://help.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository) for help

### 2. Take this template to the data on your local machine

Clone the forked [smncrna_analysis_template](https://github.com/leahkemp/smncrna_analysis_template) repo to the machine you'd like to analyse the data on

```bash
git clone https://github.com/leahkemp/smncrna_analysis_template.git
```

### 3. Format your input files

fastq naming convention

```bash

```



Metadata file

### 4. Analyse your data

- [Run smrnaseq pipeline](./smrnaseq_pipeline_run/run_smrnaseq_pipeline.md)
- [Run excerpt pipeline](./excerpt_pipeline_run/run_excerpt_pipeline.md)
- [Differential expression analysis](./diff_expression/diff_expression.Rmd)
- RNA expression plotting in RShiny:
  - [Data prep for app](./expression_plotting/data_prep_for_app.R)
  - Deploy RShiny app to ESR's shinyapps IO account, see the [server](./expression_plotting/server.R) and [ui](./expression_plotting/ui.R) that comprise the app
- [Summarise the read counts/mapping rates for both pipelines](./mapping_rates/calculate_mapping_metrics.md)
- [Clustering/MDS plots](./clustering/clustering.Rmd)
- [RNA species composition plotting](./rna_species_composition/rna_species_composition.Rmd)

### 5. Commit and push to your forked version of the github repo

To maintain reproducibility of your analysis, commit and push:

- All configuration files
- All run scripts
- All your documentation/notes

### 6. Repeat step 4 each time you re-run the analysis with different parameters

### 7. Create a github page (optional)

### 8. Contribute back!

- Raise issues in [the issues page](https://github.com/leahkemp/smncrna_analysis_template/issues)
- Create feature requests in [the issues page](https://github.com/leahkemp/smncrna_analysis_template/issues)
- Contribute your code! Create your own branch from the [development branch](https://github.com/leahkemp/smncrna_analysis_template/tree/dev) and create a pull request to the [development branch](https://github.com/leahkemp/smncrna_analysis_template/tree/dev) once the code is on point!

Contributions and feedback are always welcome! :blush:
