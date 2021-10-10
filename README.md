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
  - [Testing](#testing)
  - [How to use this template](#how-to-use-this-template)
    - [1. Fork the template repo to a personal or lab account](#1-fork-the-template-repo-to-a-personal-or-lab-account)
    - [2. Take this template to the data on your local machine](#2-take-this-template-to-the-data-on-your-local-machine)
    - [3. Format your input files](#3-format-your-input-files)
      - [Fastq naming convention](#fastq-naming-convention)
      - [Metadata file](#metadata-file)
      - [Configuration file](#configuration-file)
    - [4. Analyse your data](#4-analyse-your-data)
    - [5. Commit and push to your forked version of the github repo](#5-commit-and-push-to-your-forked-version-of-the-github-repo)
    - [6. Repeat step 5 each time you re-run the analysis with different parameters](#6-repeat-step-5-each-time-you-re-run-the-analysis-with-different-parameters)
    - [7. Create a github page (optional)](#7-create-a-github-page-optional)
    - [8. Contribute back!](#8-contribute-back)

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

Interactive MDS and PCA plots are also created to explore clusters of RNA's/samples in the data.

Lastly, the composition of the RNA species are explored.

## Testing

This template has been validated to work on:

- [nextflow 21.04.0](https://github.com/nextflow-io/nextflow/tree/v21.04.0)
- [singularity 3.7.2](https://github.com/hpcng/singularity/tree/v3.7.2),
- [smrnaseq version 1.0.0](https://github.com/nf-core/smrnaseq/tree/1.0.0)
- [excerpt version 4.3.2](https://github.com/rkitchen/exceRpt/tree/4.3.2)
- R version 4.0.5
- CentOS Linux 7

Test fastq data available in the [test_fastq directory](./test_fastq/)

## How to use this template

### 1. Fork the template repo to a personal or lab account

See [here](https://help.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository) for help

### 2. Take this template to the data on your local machine

Clone the forked [smncrna_analysis_template](https://github.com/leahkemp/smncrna_analysis_template) repo to the machine you'd like to analyse the data on

```bash
git clone https://github.com/leahkemp/smncrna_analysis_template.git
```

### 3. Format your input files

#### Fastq naming convention

```bash
sample_S*_R1.fastq.gz
```

- one fastq file per sample

For example see the test fastq files [here](./test/fastq/)

#### Metadata file

Required columns:

- "sample"
  - must be titled "sample"
  - must contain a row with a unique sample name/id for each fastq file present in the directory of fastq files to be analysed

- "treatment"
  - must be titled "treatment"

Other notes:

- you can have additional columns
- you can't have any duplicate column names eg. two columns named "sample" and "Sample"
- make sure every sample in the fastq directory to be analysed is included in the metadata file and is associated with a treatment group

For example see the test metadata file [here](./test/metadata.csv)

#### Configuration file

Set up [./config/config.yaml](config/config.yaml)

For example see the test configuration file [here](./test/config.yaml)

### 4. Analyse your data

Run/work through the [master RMarkdown file](./master.Rmd), this will do the bulk of the analyses and generate several html file for data visualisation and csv files with processed data

### 5. Commit and push to your forked version of the github repo

Push all the results files you're comfortable with being online:

- 

To maintain reproducibility of your analysis, commit and push:

- All configuration files
- All run scripts
- All your documentation/notes

### 6. Repeat step 5 each time you re-run the analysis with different parameters

### 7. Create a github page (optional)

### 8. Contribute back!

- Raise issues in [the issues page](https://github.com/leahkemp/smncrna_analysis_template/issues)
- Create feature requests in [the issues page](https://github.com/leahkemp/smncrna_analysis_template/issues)
- Contribute your code! Create your own branch from the [development branch](https://github.com/leahkemp/smncrna_analysis_template/tree/dev) and create a pull request to the [development branch](https://github.com/leahkemp/smncrna_analysis_template/tree/dev) once the code is on point!

Contributions and feedback are always welcome! :blush:
