# Run exceRpt pipeline

**Pipeline:** [exceRpt](https://github.com/rkitchen/exceRpt), [pipeline documentation](https://rkitchen.github.io/exceRpt/)
**Prerequisite software:** [GNU cat](https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html), [GNU sed](https://www.gnu.org/software/sed/), [GNU parallel](https://www.gnu.org/software/parallel/), [GNU wc](https://www.gnu.org/software/coreutils/manual/html_node/wc-invocation.html), [wget](https://www.gnu.org/software/wget/), [docker](https://docs.docker.com/get-docker/), [R](https://www.r-project.org/), [GNU screen](https://www.gnu.org/software/screen/), [git](https://git-scm.com/)

## Table of contents

- [Run exceRpt pipeline](#run-excerpt-pipeline)
  - [Table of contents](#table-of-contents)
  - [Set user parameters](#set-user-parameters)
  - [Create screen to run pipeline in](#create-screen-to-run-pipeline-in)
  - [Run data through pipeline](#run-data-through-pipeline)
  - [Merge results from all samples](#merge-results-from-all-samples)
  - [Clean up](#clean-up)

## Set user parameters

Set user parameters in the `excerpt_pipeline_run_script.sh` script (the `##### USER PARAMETERS #####` section)

*Note. if a nextflex adapter sequence was used in sequencing you might need to include an additional hardtrim of 4bp each side by passing `TRIM_N_BASES_5p=4 TRIM_N_BASES_3p=4` to the excerpt pipeline run script*

*Another note. correct trimming is VERY important for these little RNA's because it strongly influences how many RNA's you get mapping to the references, check the adapter sequence you think is in the data is actually in the data with the following few commands:*

```bash
# for example to check how many reads in a fastq file have the nextflex adapter
zgrep TGGAATTCTCGG /my/path/to/my_sample.fastq.gz | wc -l

# and to look at a few reads with their adapter sequences
zgrep TGGAATTCTCGG /my/path/to/my_sample.fastq.gz | head
```

*A last note: this script downloads a large database ~31G so make sure you have enough space to download this*

## Create screen to run pipeline in

```bash
screen -S excerpt_run
```

## Run data through pipeline

Run pipeline, for example

```bash
bash /my/path/to/excerpt_pipeline_run_script.sh
```

## Merge results from all samples

Get excerpt pipeline git repo

```bash
git clone https://github.com/rkitchen/exceRpt.git
```

*Note. make sure you have the same version of the pipeline that you ran your data through. The `excerpt_pipeline_run_script.sh` script, the pipeline version can be changed with the following*

```bash
cd /my/path/to/exceRpt
git checkout tags/4.3.2
```

Create a dir for merged output

```bash
mkdir /data/lkemp/covid_sncrna/merged/
```

Run in R, I needed to run this script in an RStudio session so I can say yes to prompts to download libraries

```r
setwd("/my/path/to/exceRpt/")
source("mergePipelineRuns_functions.R")
processSamplesInDir("/my/path/to/exceRpt_output/", "/where/to/write/output/files/")
```

## Clean up

Remove any dangling dockers containers *this can be quite important since the docker container can be sitting there happily consuming resources long after you've finished your analyses*

Get the list of running containers

```bash
docker container ls
```

Kill them with fire

```bash
docker kill my_container
```
