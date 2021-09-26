# Run smrnaseq pipeline

**Pipeline:** [smrnaseq](https://github.com/nf-core/smrnaseq), [pipeline documentation](https://nf-co.re/smrnaseq)
**Prerequisite software:** [GNU wc](https://www.gnu.org/software/coreutils/manual/html_node/wc-invocation.html), [wget](https://www.gnu.org/software/wget/), [conda](https://docs.conda.io/en/latest/), [GNU screen](https://www.gnu.org/software/screen/), [git](https://git-scm.com/), [nextflow](https://www.nextflow.io/), [zgrep](https://linux.die.net/man/1/zgrep)

## Table of contents

- [Run smrnaseq pipeline](#run-smrnaseq-pipeline)
  - [Table of contents](#table-of-contents)
  - [Set user parameters](#set-user-parameters)
  - [Create screen to run pipeline in](#create-screen-to-run-pipeline-in)
  - [Set nextflow configuration](#set-nextflow-configuration)
  - [Run data through pipeline](#run-data-through-pipeline)

## Set user parameters

Set user parameters in the `smrnaseq_pipeline_run_script.sh` script (the `##### USER PARAMETERS #####` section)

*A note. correct trimming is VERY important for these little RNA's because it strongly influences how many RNA's you get mapping to the references, check the adapter sequence you think is in the data is actually in the data with the following few commands:*

```bash
# for example to check how many reads in a fastq file have the nextflex adapter
zgrep TGGAATTCTCGG /my/path/to/my_sample.fastq.gz | wc -l

# and to look at a few reads with their adapter sequences
zgrep TGGAATTCTCGG /my/path/to/my_sample.fastq.gz | head
```

## Create screen to run pipeline in

```bash
screen -S smrnaseq_run
```

## Set nextflow configuration

See info [here](https://www.nextflow.io/docs/latest/config.html)

## Run data through pipeline

Run pipeline, for example

```bash
bash /my/path/to/smrnaseq_pipeline_run_script.sh
```
