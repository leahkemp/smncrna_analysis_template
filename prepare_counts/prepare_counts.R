# load libraries
library(dplyr)
library(textshape)
library(edgeR)
library(tibble)
library(gtools)
library(janitor)

# read in yaml config file
config <- yaml::yaml.load_file("./config/config.yaml")

# load all the count datasets
mirna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                        "exceRpt_miRNA_ReadCounts.txt"),
                                        header = TRUE,
                                        stringsAsFactors = FALSE,
                                        check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub("[_][S]\\d+[_]R1.fastq", "", .))

pirna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                        "exceRpt_piRNA_ReadCounts.txt"),
                                        header = TRUE,
                                        stringsAsFactors = FALSE,
                                        check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub("[_][S]\\d+[_]R1.fastq", "", .))

trna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                       "exceRpt_tRNA_ReadCounts.txt"),
                                       header = TRUE,
                                       stringsAsFactors = FALSE,
                                       check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub("[_][S]\\d+[_]R1.fastq", "", .))

circrna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                          "exceRpt_circularRNA_ReadCounts.txt"),
                                          header = TRUE,
                                          stringsAsFactors = FALSE,
                                          comment.char = "") %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub("[_][S]\\d+[_]R1.fastq", "", .))

gencode_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                          "exceRpt_gencode_ReadCounts.txt"),
                                          header = TRUE,
                                          stringsAsFactors = FALSE,
                                          check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub("[_][S]\\d+[_]R1.fastq", "", .))

mirna_smrnaseq_data <- utils::read.table(base::file.path(config$smrnaseq_results_dir,
                                                         "/edgeR/miRBase_mature/mature_counts.csv"),
                                         header = TRUE,
                                         stringsAsFactors = TRUE,
                                         sep = ",") %>%
  # formatting
  base::t() %>%
  base::as.data.frame() %>%
  janitor::row_to_names(row_number = 1) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub("[_][S]\\d+[.]mature", "", .))

# formatting to make counts datasets consistent between smrnaseq and excerpt pipelines
mirna_smrnaseq_data <- mirna_smrnaseq_data %>%
  # make all count data numeric
  dplyr::mutate_all(as.numeric)

# replace "." with "-" so RNA names are the same
base::row.names(mirna_smrnaseq_data) <- base::gsub("\\.", "\\-", base::row.names(mirna_smrnaseq_data))

# create a vector defining the count datasets to analyse (that are set to TRUE) based on the yaml user configuration file
to_analyse <- config[c("mirna_smrnaseq",
                       "mirna_excerpt",
                       "pirna_excerpt",
                       "trna_excerpt",
                       "circrna_excerpt",
                       "gencode_excerpt")] %>%
  base::as.data.frame() %>%
  base::t() %>%
  base::as.data.frame() %>%
  tibble::rownames_to_column("rna_species") %>%
  dplyr::rename("analyse" = "V1") %>%
  tidyr::separate(rna_species, c("rna_species", "pipeline")) %>%
  dplyr::filter(analyse == TRUE) %>%
  dplyr::mutate(dataset_name = base::paste0(rna_species, "_", pipeline)) %>%
  dplyr::pull(dataset_name)

# set up a vector of all the possible datasets to analyse
count_datasets <- base::list(mirna_smrnaseq = mirna_smrnaseq_data,
                             mirna_excerpt = mirna_excerpt_data,
                             pirna_excerpt = pirna_excerpt_data,
                             trna_excerpt = trna_excerpt_data,
                             circrna_excerpt = circrna_excerpt_data,
                             gencode_excerpt = gencode_excerpt_data)

# filter all possible datasets by the datasets the user has specified to analyse
count_datasets <- count_datasets[to_analyse]

# calculate counts per million (loop over all the count datasets the user has specified)
counts_cpm <- base::lapply(base::seq_along(count_datasets), function(y, pipeline, rna_species, i){
  
  # calculate counts per million for all datasets in the list
  edgeR::cpm(y[[i]]) %>%
    base::as.data.frame() %>%
    # sort all the columns in the different datasets so they are consistent among each other
    # (important for specifying the treatment groups downstream)
    dplyr::select(gtools::mixedsort(tidyselect::peek_vars())) %>%
    tibble::rownames_to_column("rna") %>%
    # make data long
    tidyr::pivot_longer(-rna, names_to = "sample", values_to = "counts_per_million") %>%
    # create a column that has defines the rna_species the data has come from
    # based on the names of the "count_dataset" list, grab everything BEFORE 
    # the underscore
    dplyr::mutate(rna_species = rna_species[[i]]) %>%
    # also create a column that defines the pipeline the data has come from
    # based on the names of the "count_dataset" list, grab everything AFTER
    # the underscore
    dplyr::mutate(pipeline = pipeline[[i]])
}, y=count_datasets,
rna_species=base::sub("\\_.*", "", base::paste(base::names(count_datasets))),
pipeline=base::sub(".*\\_", "", base::paste(base::names(count_datasets)))
)

# calculate log counts per million (loop over all the count datasets the user has specified)
counts_lcpm <- base::lapply(seq_along(count_datasets), function(y, pipeline, rna_species, i){
  
  # calculate log counts per million for all datasets in the list
  edgeR::cpm(y[[i]], log = TRUE) %>%
    base::as.data.frame() %>%
    # sort all the columns in the different datasets so they are consistent among each other
    # (important for specifying the treatment groups downstream)
    dplyr::select(gtools::mixedsort(tidyselect::peek_vars())) %>%
    tibble::rownames_to_column("rna") %>%
    # make data long
    tidyr::pivot_longer(-rna, names_to = "sample", values_to = "log_counts_per_million") %>%
    # create a column that has defines the rna_species the data has come from
    # based on the names of the "count_dataset" list, grab everything BEFORE 
    # the underscore
    dplyr::mutate(rna_species = rna_species[[i]]) %>%
    # also create a column that defines the pipeline the data has come from
    # based on the names of the "count_dataset" list, grab everything AFTER
    # the underscore
    dplyr::mutate(pipeline = pipeline[[i]])
}, y=count_datasets,
rna_species=base::sub("\\_.*", "", base::paste(base::names(count_datasets))),
pipeline=base::sub(".*\\_", "", base::paste(base::names(count_datasets)))
)

# prepare raw counts (loop over all the count datasets the user has specified)
counts_raw <- base::lapply(seq_along(count_datasets), function(y, pipeline, rna_species, i){
  
  # prepare raw counts for all datasets in the list
  y[[i]] %>%
    base::as.data.frame() %>%
    # sort all the columns in the different datasets so they are consistent among each other
    # (important for specifying the treatment groups downstream)
    dplyr::select(gtools::mixedsort(tidyselect::peek_vars())) %>%
    tibble::rownames_to_column("rna") %>%
    # make data long
    tidyr::pivot_longer(-rna, names_to = "sample", values_to = "raw_counts") %>%
    # create a column that has defines the rna_species the data has come from
    # based on the names of the "count_dataset" list, grab everything BEFORE 
    # the underscore
    dplyr::mutate(rna_species = rna_species[[i]]) %>%
    # also create a column that defines the pipeline the data has come from
    # based on the names of the "count_dataset" list, grab everything AFTER
    # the underscore
    dplyr::mutate(pipeline = pipeline[[i]])
}, y=count_datasets,
rna_species=base::sub("\\_.*", "", base::paste(base::names(count_datasets))),
pipeline=base::sub(".*\\_", "", base::paste(base::names(count_datasets)))
)

# collapse my list of dataframes into single dataframes
counts_cpm <- base::Reduce (rbind, counts_cpm)
counts_lcpm <- base::Reduce(rbind, counts_lcpm)
counts_raw <- base::Reduce(rbind, counts_raw)

# join all three dataframes into one large dataframe of all count data!
counts <- dplyr::full_join(counts_cpm, counts_lcpm, by = c("rna", "sample", "pipeline", "rna_species")) 
counts <- dplyr::full_join(counts, counts_raw, by = c("rna", "sample", "pipeline", "rna_species")) 

# further split the gencode data into different RNA categories
# overwrite the rna_species column with a partial string from the rna column (for the gencode data)
# otherwise overwrite the rna_species column with what is already in the rna_species column
counts <- dplyr::mutate(counts, rna_species = dplyr::case_when(rna_species == "gencode" ~ base::sub('.*:', '', counts$rna),
                                                               rna_species != "gencode" ~ counts$rna_species
))

# rename mirna (from "rna_species") so that it matches up with miRNA and gets put in the same group in downstream analyses
counts <- counts %>%
  dplyr::mutate(rna_species = dplyr::case_when(
    rna_species == "miRNA" ~ "mirna", 
    TRUE ~ rna_species))

# write the data to a csv file so I can use it in other documents
utils::write.csv(counts, "./prepare_counts/counts.csv", row.names = FALSE)

# clean up
rm(list = ls())
