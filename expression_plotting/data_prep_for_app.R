##################################################################
##                          Setup                               ##
##################################################################

# load libraries
library(dplyr)
library(DBI)
library(yaml)
library(stringr)

# read in processed count data (processed in the differential expression document)
counts <- utils::read.csv("./prepare_counts/counts.csv")

# read in yaml config file
config <- yaml::yaml.load_file("./config/config.yaml")

# read in metadata
metadata <- utils::read.csv(file.path(config$metadata))

# create output directory
dir.create("./expression_plotting/expr_plotting_results/", showWarnings = FALSE)

# subset all count data to the count data specified to be analysed by the user in the config file
# this will remove rows of data matching the said conditions

if(config$mirna_smrnaseq == "FALSE") {
  
  counts <- counts %>%
    dplyr::filter(!((rna_species == "mirna") & (pipeline == "smrnaseq")))
  
}

if(config$mirna_excerpt == "FALSE") {
  
  counts <- counts %>%
    dplyr::filter(!((rna_species == "mirna") & (pipeline == "excerpt")))
  
}

if(config$pirna_excerpt == "FALSE") {
  
  counts <- counts %>%
    dplyr::filter(!((rna_species == "pirna") & (pipeline == "excerpt")))
  
}

if(config$trna_excerpt == "FALSE") {
  
  counts <- counts %>%
    dplyr::filter(!((rna_species == "trna") & (pipeline == "excerpt")))
  
}

if(config$circrna_excerpt == "FALSE") {
  
  counts <- counts %>%
    dplyr::filter(!((rna_species == "circrna") & (pipeline == "excerpt")))
  
}

if(config$gencode_excerpt == "FALSE") {
  
  counts <- counts %>%
    dplyr::filter(!((rna_species == "gencode") & (pipeline == "excerpt")))
  
}

# read in metadata
metadata <- utils::read.csv(config$metadata_path)

# read in differential expression data
diff_expr_data <- utils::read.table("./diff_expression/diff_expr_results/diff_expr_results.tsv", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

# read in mapping rates data
mapping_rates <- utils::read.csv("./mapping_rates/mapping_rates.csv") %>%
  tidyr::drop_na()

##################################################################
##                   Prep of count data                         ##
##################################################################

# set up a flag for when the sequencing read counts for a sample is low (arbitrary line at 5 million)
low_read_count_flag <- mapping_rates %>%
  dplyr::filter(raw_read_count_fastq_file < config$low_sequencing_read_count) %>%
  dplyr::group_by(sample) %>%
  dplyr::summarise() %>%
  dplyr::pull(sample)

# make a column that flags when a sample was low in read counts
counts <- dplyr::mutate(counts, low_sequencing_read_count = sample %in% low_read_count_flag)

# append metadata to the count data
counts <- dplyr::left_join(counts, metadata, by = "sample")

# make a column that notes the raw read count for a given sample
raw_read_count <- mapping_rates %>%
  dplyr::select(sample, raw_read_count_fastq_file)

counts <- dplyr::left_join(counts, raw_read_count, by = "sample")

##################################################################
##           Prep of differential expression data               ##
##################################################################

# extract a list of the significant RNAs (at three significance levels)
sig_diff_expr_data_1 <- diff_expr_data %>%
  dplyr::filter(significance == "significant_1%") %>%
  dplyr::select(rna) %>%
  dplyr::distinct(rna)

sig_diff_expr_data_5 <- diff_expr_data %>%
  dplyr::filter(significance == "significant_5%") %>%
  dplyr::select(rna) %>%
  dplyr::distinct(rna)

sig_diff_expr_data_10 <- diff_expr_data %>%
  dplyr::filter(significance == "significant_10%") %>%
  dplyr::select(rna) %>%
  dplyr::distinct(rna)

#################################################################
##                        Write to file                        ##
#################################################################

# differential expression data
utils::write.csv(diff_expr_data, file = "./expression_plotting/expr_plotting_results/master_diff_expr_data.csv", row.names = FALSE)
utils::write.csv(sig_diff_expr_data_1, file = "./expression_plotting/expr_plotting_results/master_sig_diff_expr_data_1.csv", row.names = FALSE)
utils::write.csv(sig_diff_expr_data_5, file = "./expression_plotting/expr_plotting_results/master_sig_diff_expr_data_5.csv", row.names = FALSE)
utils::write.csv(sig_diff_expr_data_10, file = "./expression_plotting/expr_plotting_results/master_sig_diff_expr_data_10.csv", row.names = FALSE)

# write the config file needed for app to file within this project directory
# so it can be sent to shinyappsio and used
yaml::write_yaml(config, "./expression_plotting/expr_plotting_results/config.yaml")

# write the metadata file needed for app to file within this project directory
# so it can be sent to shinyappsio and used
utils::write.csv(metadata, file = "./expression_plotting/expr_plotting_results/metadata.csv", row.names = FALSE)

# count data
# this data was written to an sql lite database
# this significantly speeds up the app compared to reading a csv file of the data and filtering/subsetting the data

# initialise a database
db <- DBI::dbConnect(RSQLite::SQLite(), "./expression_plotting/expr_plotting_results/master-count.sqlite")

# get all unique rna species
species_choices <- base::data.frame(base::unique(base::as.character(counts$rna_species)))

# create dataframe of unique combinations of rna species and rna
rna_choices <- base::data.frame(base::unique(counts[c("rna_species", "rna")]))

# write dataframes and count data to database tables
DBI::dbWriteTable(db, "species", species_choices, overwrite=TRUE)
DBI::dbWriteTable(db, "rna_choices", rna_choices, overwrite=TRUE)
DBI::dbWriteTable(db, "counts", counts, overwrite=TRUE)

# create indexes for common data lookups the app with do (will further speed up app, particularly index_rna)
# note. I tried to make more indexes, but it made the database too large to deploy to shiny apps io
DBI::dbSendQuery(db,"CREATE INDEX index_rna ON counts (rna, rna_species)")

# close the connection to the database
DBI::dbDisconnect(db)

# clean up
rm(list = ls())
