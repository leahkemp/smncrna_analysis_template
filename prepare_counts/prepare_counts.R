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
raw_mirna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                            "exceRpt_miRNA_ReadCounts.txt"),
                                            header = TRUE,
                                            stringsAsFactors = FALSE,
                                            check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub(".fastq", "", .))

raw_pirna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                            "exceRpt_piRNA_ReadCounts.txt"),
                                            header = TRUE,
                                            stringsAsFactors = FALSE,
                                            check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub(".fastq", "", .))

raw_trna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                           "exceRpt_tRNA_ReadCounts.txt"),
                                           header = TRUE,
                                           stringsAsFactors = FALSE,
                                           check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub(".fastq", "", .))

raw_circrna_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                              "exceRpt_circularRNA_ReadCounts.txt"),
                                              header = TRUE,
                                              stringsAsFactors = FALSE,
                                              comment.char = "") %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub(".fastq", "", .))

raw_gencode_excerpt_data <- utils::read.table(base::file.path(config$excerpt_merged_results_dir,
                                                              "exceRpt_gencode_ReadCounts.txt"),
                                              header = TRUE,
                                              stringsAsFactors = FALSE,
                                              check.names = FALSE) %>%
  # remove S*_R1.fastq suffix from the sample/column names
  dplyr::rename_with(~ base::sub(".fastq", "", .))

raw_mirna_smrnaseq_data <- utils::read.table(base::file.path(config$smrnaseq_results_dir,
                                                             "/mirtop/mirtop.tsv"),
                                             header = TRUE) %>%
  # get only the count data
  dplyr::select(-c("UID", "Read", "Variant", "iso_5p", "iso_3p", "iso_add3p", "iso_snp", "iso_5p_nt", "iso_3p_nt", "iso_add3p_nt", "iso_snp_nt")) %>%
  # "squash" out the isoform info (of the mirtop from smrnaseq pipeline)
  dplyr::group_by(miRNA) %>%
  dplyr::summarise_each(sum) %>%
  # convert column to rowname so the data can be normalised later
  tibble::column_to_rownames(var="miRNA")

# formatting to make counts datasets consistent between smrnaseq and excerpt pipelines
raw_mirna_smrnaseq_data <- raw_mirna_smrnaseq_data %>%
  # make all count data numeric
  dplyr::mutate_all(as.numeric)

# replace "." with "-" so RNA names are the same
base::row.names(raw_mirna_smrnaseq_data) <- base::gsub("\\.", "\\-", base::row.names(raw_mirna_smrnaseq_data))

# remove weird tRNA row
raw_trna_excerpt_data <- raw_trna_excerpt_data %>%
  dplyr::filter(!(rownames(raw_trna_excerpt_data) == "tRNA"))

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
count_datasets <- base::list(mirna_smrnaseq = raw_mirna_smrnaseq_data,
                             mirna_excerpt = raw_mirna_excerpt_data,
                             pirna_excerpt = raw_pirna_excerpt_data,
                             trna_excerpt = raw_trna_excerpt_data,
                             circrna_excerpt = raw_circrna_excerpt_data,
                             gencode_excerpt = raw_gencode_excerpt_data)

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
# (I'll put into a new column)
# overwrite the rna_species_2 column with a partial string from the rna column (for the gencode data)
# otherwise overwrite the rna_species_2 column with what is already in the rna_species_2 column
counts <- dplyr::mutate(counts, rna_species_2 = rna_species)
counts <- dplyr::mutate(counts, rna_species_2 = dplyr::case_when(rna_species_2 == "gencode" ~ base::sub('.*:', '', counts$rna),
                                                                 rna_species_2 != "gencode" ~ counts$rna_species_2
))

# fix for css highlighting in expression plotting shiny app not working for rnas/rows with ":", "|" or "."
# doing this here so the genes/transcripts are named consitantly throughout all documents
# | needed to be escaped with \\ in order to be interpreted correctly
# also need to use gsub instead of sub to replace all occurrences instead of just the first one
counts <- counts %>%
  dplyr::mutate(rna = base::gsub(":", "_", rna)) %>%
  dplyr::mutate(rna = base::gsub("\\|", "_", rna)) %>%
  dplyr::mutate(rna = base::gsub("\\.", "_", rna))

# rename mirna (from rna_species_2") so that it matches up with miRNA and gets put in the same group in downstream analyses
counts <- counts %>%
  dplyr::mutate(rna_species_2 = dplyr::case_when(
    rna_species_2 == "miRNA" ~ "mirna", 
    TRUE ~ rna_species_2))

# write the data to a csv file so I can use it in other documents
utils::write.csv(counts, "./prepare_counts/counts.csv", row.names = FALSE)

# also save some rds objects
dir.create("./prepare_counts/rds_objects/", showWarnings = FALSE)

raw_mirna_smrnaseq_data <- raw_mirna_smrnaseq_data %>%
  dplyr::select(gtools::mixedsort(tidyselect::peek_vars()))
raw_mirna_excerpt_data <- raw_mirna_excerpt_data %>%
  dplyr::select(gtools::mixedsort(tidyselect::peek_vars()))
raw_pirna_excerpt_data <- raw_pirna_excerpt_data %>%
  dplyr::select(gtools::mixedsort(tidyselect::peek_vars()))
raw_trna_excerpt_data <- raw_trna_excerpt_data %>%
  dplyr::select(gtools::mixedsort(tidyselect::peek_vars()))
raw_circrna_excerpt_data <- raw_circrna_excerpt_data %>%
  dplyr::select(gtools::mixedsort(tidyselect::peek_vars()))
raw_gencode_excerpt_data <- raw_gencode_excerpt_data %>%
  dplyr::select(gtools::mixedsort(tidyselect::peek_vars()))

base::saveRDS(raw_mirna_smrnaseq_data, file = "./prepare_counts/rds_objects/raw_mirna_smrnaseq_counts.rds")
base::saveRDS(raw_mirna_excerpt_data, file = "./prepare_counts/rds_objects/raw_mirna_excerpt_counts.rds")
base::saveRDS(raw_pirna_excerpt_data, file = "./prepare_counts/rds_objects/raw_pirna_excerpt_counts.rds")
base::saveRDS(raw_trna_excerpt_data, file = "./prepare_counts/rds_objects/raw_trna_excerpt_counts.rds")
base::saveRDS(raw_circrna_excerpt_data, file = "./prepare_counts/rds_objects/raw_circrna_excerpt_counts.rds")
base::saveRDS(raw_gencode_excerpt_data, file = "./prepare_counts/rds_objects/raw_gencode_excerpt_counts.rds")

cpm_mirna_smrnaseq_data <- raw_mirna_smrnaseq_data %>%
  edgeR::cpm()
cpm_mirna_excerpt_data <- raw_mirna_excerpt_data %>%
  edgeR::cpm()
cpm_pirna_excerpt_data <- raw_pirna_excerpt_data %>%
  edgeR::cpm()
cpm_trna_excerpt_data <- raw_trna_excerpt_data %>%
  edgeR::cpm()
cpm_circrna_excerpt_data <- raw_circrna_excerpt_data %>%
  edgeR::cpm()
cpm_gencode_excerpt_data <- raw_gencode_excerpt_data %>%
  edgeR::cpm()

base::saveRDS(cpm_mirna_smrnaseq_data, file = "./prepare_counts/rds_objects/cpm_mirna_smrnaseq_counts.rds")
base::saveRDS(cpm_mirna_excerpt_data, file = "./prepare_counts/rds_objects/cpm_mirna_excerpt_counts.rds")
base::saveRDS(cpm_pirna_excerpt_data, file = "./prepare_counts/rds_objects/cpm_pirna_excerpt_counts.rds")
base::saveRDS(cpm_trna_excerpt_data, file = "./prepare_counts/rds_objects/cpm_trna_excerpt_counts.rds")
base::saveRDS(cpm_circrna_excerpt_data, file = "./prepare_counts/rds_objects/cpm_circrna_excerpt_counts.rds")
base::saveRDS(cpm_gencode_excerpt_data, file = "./prepare_counts/rds_objects/cpm_gencode_excerpt_counts.rds")

lcpm_mirna_smrnaseq_data <- raw_mirna_smrnaseq_data %>%
  edgeR::cpm(log = TRUE)
lcpm_mirna_excerpt_data <- raw_mirna_excerpt_data %>%
  edgeR::cpm(log = TRUE)
lcpm_pirna_excerpt_data <- raw_pirna_excerpt_data %>%
  edgeR::cpm(log = TRUE)
lcpm_trna_excerpt_data <- raw_trna_excerpt_data %>%
  edgeR::cpm(log = TRUE)
lcpm_circrna_excerpt_data <- raw_circrna_excerpt_data %>%
  edgeR::cpm(log = TRUE)
lcpm_gencode_excerpt_data <- raw_gencode_excerpt_data %>%
  edgeR::cpm(log = TRUE)

base::saveRDS(lcpm_mirna_smrnaseq_data, file = "./prepare_counts/rds_objects/lcpm_mirna_smrnaseq_counts.rds")
base::saveRDS(lcpm_mirna_excerpt_data, file = "./prepare_counts/rds_objects/lcpm_mirna_excerpt_counts.rds")
base::saveRDS(lcpm_pirna_excerpt_data, file = "./prepare_counts/rds_objects/lcpm_pirna_excerpt_counts.rds")
base::saveRDS(lcpm_trna_excerpt_data, file = "./prepare_counts/rds_objects/lcpm_trna_excerpt_counts.rds")
base::saveRDS(lcpm_circrna_excerpt_data, file = "./prepare_counts/rds_objects/lcpm_circrna_excerpt_counts.rds")
base::saveRDS(lcpm_gencode_excerpt_data, file = "./prepare_counts/rds_objects/lcpm_gencode_excerpt_counts.rds")

# clean up
rm(list = ls())
