# Load libraries
library(shiny)
library(shinythemes)
library(shinydashboard)
library(dplyr)
library(plotly)
library(shinycssloaders)
library(DBI)
library(dbplyr)
library(DT)

# load significant differential expression data
sig_diff_expr_data_1 <- read.csv("./data/master_sig_diff_expr_data_1.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_5 <- read.csv("./data/master_sig_diff_expr_data_5.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_10 <- read.csv("./data/master_sig_diff_expr_data_10.csv", header = TRUE, stringsAsFactors = FALSE)

# define UI for app ----
ui <- fluidPage(
  
  # app theme ----
  theme = shinytheme("yeti"),
  
  # css to highlight the RNAs in the drop down box (defined by rna_choice) that were found to be significantly differentially expressed
  # a different highlight is used for the three significance levels (1%, 5%, 10%) ----
  tags$head(
    lapply(sig_diff_expr_data_1, function(x){
      tags$style(HTML(
        paste0(".option[data-value=", x, "], .item[data-value=", x, "] {background: #ffe342 !important;}")
      ))
    })
  ),
  
  tags$head(
    lapply(sig_diff_expr_data_5, function(x){
      tags$style(HTML(
        paste0(".option[data-value=", x, "], .item[data-value=", x, "] {background: #ffef8a !important;}")
      ))
    })
  ),
  
  tags$head(
    lapply(sig_diff_expr_data_10, function(x){
      tags$style(HTML(
        paste0(".option[data-value=", x, "], .item[data-value=", x, "] {background: #fff5b8 !important;}")
      ))
    })
  ),
  
  # define page layout ----
  verticalLayout(
    
    # render user options panel ----
    wellPanel(
      
      # user input to choose RNA species/group of interest to plot ----
      selectizeInput("rna_species_choice",
                     h4("Select/search for an RNA species:"),
                     choices = NULL,
                     options = list(maxItems = 1)),
      
      # user input to choose RNA of interest to plot (options dependent on the first input - rna_species_choice) ----
      selectizeInput("rna_choice",
                     h4("Select/search for an RNA:"),
                     choices = NULL,
                     options = list(maxItems = 10)),
      
      # user input to choose the main variable of interest to compare ----
      selectInput("variable_of_interest",
                  h4("Select the main variable of interest to compare:"),
                  choices = c("Treatment"),
                  selected = "Treatment"),
      
      # add help text that reminds the user that all this differential expression data is based on
      # on only one of the variables they can choose to explore
      helpText(tags$i(
        h5("Explore the differential expression results, raw counts and counts per million by RNA. RNA's highlighted in yellow were found to be significantly differentially expressed by at least one differential expression analysis. A smaller p-value is highlighted in a bolder yellow. A differential expression analysis was only carried out on miRNAs, piRNA's and tRNA's.")))
    ),
    
    # plot all the tables and boxplots ----        
    wellPanel(
      
      # plot differential expression table
      dataTableOutput("table_diff_expr") %>% withSpinner(color="#0dc5c1")
    ),
    
    wellPanel(
      
      plotlyOutput(outputId = "scatterplot_raw_by_sample") %>% withSpinner(color="#0dc5c1")
    ), 

    wellPanel(

      plotlyOutput(outputId = "box_plot_raw") %>% withSpinner(color="#0dc5c1")
    ),
    
    wellPanel(
      
      plotlyOutput(outputId = "scatterplot_cpm_by_sample") %>% withSpinner(color="#0dc5c1")
    ),

    wellPanel(

      plotlyOutput(outputId = "box_plot_cpm") %>% withSpinner(color="#0dc5c1")
    ),
    
    wellPanel(
      
      dataTableOutput("table") %>% withSpinner(color="#0dc5c1")
      
    )
  )
)
