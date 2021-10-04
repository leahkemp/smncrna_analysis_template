# Calculate mapping metrics

**Prerequisite software:** [python 3](https://www.python.org/), [cut](https://www.man7.org/linux/man-pages/man1/cut.1.html), [zgrep](https://linux.die.net/man/1/zgrep), [GNU cat](https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html), [GNU bc](https://www.gnu.org/software/bc/), [GNU wc](https://www.gnu.org/software/coreutils/manual/html_node/wc-invocation.html), [GNU ls](https://www.gnu.org/software/coreutils/manual/html_node/ls-invocation.html), [GNU screen](https://www.gnu.org/software/screen/)

## Table of contents

- [Calculate mapping metrics](#calculate-mapping-metrics)
  - [Table of contents](#table-of-contents)
  - [Create screen to run script in](#create-screen-to-run-script-in)
  - [Run script to generate csv file](#run-script-to-generate-csv-file)

## Create screen to run script in

```bash
screen -S extract_mapping_rates
```

## Run script to generate csv file

For example

```bash
cd /my_project/smncrna_analysis_template/
bash ./mapping_rates/extract_mapping_info.sh
```
