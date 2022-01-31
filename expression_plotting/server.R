# load libraries
library(shiny)
library(shinythemes)
library(shinydashboard)
library(dplyr)
library(plotly)
library(shinycssloaders)
library(DBI)
library(dbplyr)
library(DT)

# load database data ----
db <- DBI::dbConnect(RSQLite::SQLite(), "./expr_plotting_results/master-count.sqlite")
counts <- dplyr::tbl(db, "counts")
species <- dplyr::tbl(db, "species")
rna_species_pairs <- dplyr::tbl(db, "rna_choices")

# load differential expression data ----
diff_expr_data <- utils::read.csv("./expr_plotting_results/master_diff_expr_data.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_1 <- utils::read.csv("./expr_plotting_results/master_sig_diff_expr_data_1.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_5 <- utils::read.csv("./expr_plotting_results/master_sig_diff_expr_data_5.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_10 <- utils::read.csv("./expr_plotting_results/master_sig_diff_expr_data_10.csv", header = TRUE, stringsAsFactors = FALSE)

# read in yaml config file
config <- yaml::yaml.load_file("./expr_plotting_results/config.yaml")

# read in yaml config file
metadata <- utils::read.csv("./expr_plotting_results/metadata.csv", header = TRUE, stringsAsFactors = FALSE)

# get other variables in metadata file the user may wish to compare counts by
# main_variable_command <- base::paste(base::readLines("./expr_plotting_results/command.txt"), collapse=" ")

# get list of rna_species ----
rna_species_choices <- species %>%
  dplyr::distinct() %>%
  dplyr::pull()

variables_of_interest <- metadata %>%
  dplyr::select(-sample) %>%
  base::colnames()

# define server logic for app ----
server <- function(input, output, session) {
  
  # get the current rna species the user has chosen ----
  shiny::updateSelectizeInput(session, "rna_species_choice", choices = rna_species_choices, selected = "mirna", server = TRUE)
  
  # create a user input switch that will let the user view the data based on their main variable of interest ----
  shiny::updateSelectizeInput(session, "main_variable", choices = variables_of_interest, selected = "treatment", server = TRUE)
  
  # return rnas available for the user to choose from (depends on the users choice of rna species) ----
  rna_choices <- shiny::reactive({
    if(base::is.null(input$rna_species_choice)){
      return(rna_species_pairs) %>%
        dplyr::distinct() %>%
        dplyr::pull()
    }
    
    rna_species_pairs %>%
      dplyr::filter(rna_species==local(input$rna_species_choice)) %>%
      dplyr::distinct() %>%
      dplyr::pull()
  })
  
  # get the current rna the user has chosen ----
  observe({
    shiny::updateSelectizeInput(session, "rna_choice", choices = rna_choices(), server=TRUE)
  })
  
  # subset count data based on the user choice of rna_species and rna ----
  # the dplyr::collect() function is required to force evaluation of "input$rna_choice" and "input$rna_species_choice" - otherwise is does lazy evaluation
  # the !! syntax is required to force dplyr to evaluate the user inputs (eg. input$rna_species_choice) before operating on it (eg. dplyr::filter())
  subset_count_data <- shiny::reactive({
    
    shiny::req(input$rna_species_choice, input$rna_choice)
    
    counts %>%
      dplyr::filter(rna_species==!!input$rna_species_choice & rna %in% !!input$rna_choice) %>%
      dplyr::collect() %>%
      # order the levels of the data so they plot in a sensible order on the xaxes of the plots, user specifies in configuration file
      dplyr::mutate(treatment = factor(treatment, levels = c(config$treatment_order))) %>%
      # also format logical variable so it renders properly
      dplyr::mutate(low_sequencing_read_count = as.logical(low_sequencing_read_count))
  })
  
  # subset differential expression data based on the user choice of rna_species and rna ----
  # the dplyr::collect() function is required to force evaluation of "input$rna_choice" and "input$rna_species_choice" - otherwise is does lazy evaluation
  # the !! syntax is required to force dplyr to evaluate the user inputs (eg. input$rna_species_choice) before operating on it (eg. dplyr::filter())
  subset_diff_expr_data <- shiny::reactive({
    
    shiny::req(input$rna_species_choice, input$rna_choice)
    
    diff_expr_data %>% 
      dplyr::filter(rna_species==!!input$rna_species_choice & rna %in% !!input$rna_choice) %>%
      dplyr::collect()
  })
  
  # create interactive table of the users current selection of rna and rna_species that show differential expressions results ----
  output$table_diff_expr <- DT::renderDataTable({
    
    DT::datatable(subset_diff_expr_data() %>%
                    dplyr::select(rna,
                                  rna_species,
                                  comparison,
                                  pipeline,
                                  diff_expr_method,
                                  log_fc,
                                  p_value,
                                  adj_p_value,
                                  significance) %>%
                    dplyr::mutate(across(c(rna_species,
                                           pipeline,
                                           diff_expr_method,
                                           comparison,
                                           significance), base::as.factor)) %>%
                    dplyr::mutate(across(c(log_fc,
                                           p_value,
                                           adj_p_value), base::as.double)) %>%
                    dplyr::mutate(across(c(p_value,
                                           adj_p_value), ~base::round(.x, digits = 6))) %>%
                    dplyr::mutate(across(c(log_fc), ~base::round(.x, digits = 4))),
                  filter = "top",
                  rownames = FALSE,
                  colnames = c("RNA",
                               "RNA species",
                               "Treatment comparison",
                               "Pipeline",
                               "Differential expression method",
                               "Log fold change",
                               "p-value",
                               "Adjusted p-value",
                               "Significance"),
                  extensions = base::list("ColReorder" = NULL,
                                          "Buttons" = NULL,
                                          "FixedColumns" = base::list(leftColumns=1)),
                  options = base::list(
                    dom = "BRrltpi",
                    autoWidth = TRUE,
                    columnDefs = base::list(base::list(width = "200px", targets = 0)),
                    lengthMenu = base::list(c(10, 50, -1), c("10", "50", "All")),
                    ColReorder = TRUE,
                    buttons =
                      base::list("copy",
                                 base::list(extend = "collection",
                                            buttons = c("csv", "excel", "pdf"),
                                            text = "Download"),
                                 I("colvis")))) %>%
      # Highlight the rnas/rows that are of possible interest from the presence/absence analysis
      # This matches the css highlighting in the RNA drop down box
      # DT::formatStyle("presence_absence",
      #             target = "row",
      #             backgroundColor = styleEqual(c("in_majority_of_one_group_not_in_several_of_another_group"),
      #                                          c("#bad9f5"))) %>%
      # Highlight the rnas/rows that are significantly differentially expressed
      # A different highlight is used for the three significance levels (1%, 5%, 10%)
      # This matches the css highlighting in the RNA drop down box
      # This highlighting was done last so the differential expression results "trump"
      # when an RNA is both significantly differentially expressed and of interest in the
    # presence/absence analysis
    DT::formatStyle("significance",
                    target = "row",
                    backgroundColor = styleEqual(c("significant_1%",
                                                   "significant_5%",
                                                   "significant_10%"),
                                                 c("#85C659",
                                                   "#febf2a",
                                                   "#ec1515")))
    
  })
  
  # generate boxplot of normalised counts per million averaged over samples in the levels/groups of the main variable of interest the user chooses to view ----
  output$box_plot_cpm <- plotly::renderPlotly({
    
    # print a message if the user hasn't yet selected an RNA
    shiny::validate(need(input$rna_choice, "Select an RNA from the drop down box above to create RNA expression plots!"))
    
    # print a message if no count per million data could be calculated for this data
    shiny::validate(need(subset_count_data()$counts_per_million, "Count per million data could not be calculated for this RNA - the counts were too small"))
    
    plotly::plot_ly(data = (subset_count_data()),
                    x = ~interaction(get(input$main_variable), rna),
                    y = ~counts_per_million,
                    split = ~pipeline,
                    color = ~get(input$main_variable),
                    colors = c("#0097db", "#85C659", "#ec1515", "#febf2a", "#784f96"),
                    type = "box") %>%
      plotly::layout(yaxis = base::list(title = "Counts per million"),
                     xaxis = base::list(title = "", tickangle = 270),
                     margin = base::list(b = 200))
  })
  
  # generate scatterplot of normalised counts per million for all samples in the levels/groups of the main variable of interest the user chooses to view ----
  output$scatterplot_cpm_by_sample <- plotly::renderPlotly({
    
    # print a message if no count per million data could be calculated for this data
    shiny::validate(need(subset_count_data()$counts_per_million, "Count per million data could not be calculated for this RNA"))
    
    subset_count_data() %>%
      base::split(base::list(subset_count_data() %>% dplyr::pull(input$main_variable), subset_count_data()$rna)) %>%
      base::lapply(function(x) {
        plotly::plot_ly(data = x,
                        x = x$sample,
                        y = ~counts_per_million,
                        split = ~pipeline,
                        color = ~get(input$main_variable),
                        colors = c("#0097db", "#85C659", "#ec1515", "#febf2a", "#784f96"),
                        type = "scatter",
                        mode  = "markers",
                        marker = base::list(opacity = 0.5),
                        hoverinfo = "text",
                        text = ~paste("</br> Counts per million:",base::format(counts_per_million, big.mark = ",", scientific = FALSE, digits = 2),
                                      "</br> Sample:", x$sample,
                                      "</br> Treatment:", treatment,
                                      "</br> Pipeline:", pipeline,
                                      "</br> Low sequencing read count:", low_sequencing_read_count,
                                      "</br> Sequencing read count:", base::format(raw_read_count_fastq_file, big.mark = ",", scientific = FALSE, digits = 2))) %>%
          plotly::layout(yaxis = base::list(title = "Counts per million"),
                         xaxis = base::list(title = "", tickangle = 270, type = "category"))
      }) %>% plotly::subplot(shareY = TRUE)
  })
  
  # generate boxplot of raw counts for all samples in the levels/groups of the main variable of interest the user chooses to view ----
  output$box_plot_raw <- plotly::renderPlotly({
    
    # generate boxplot of raw counts per averaged over samples in the levels/groups of the main variable of interest the user chooses to view ----
    plotly::plot_ly(data = (subset_count_data()),
                    x = ~interaction(get(input$main_variable), rna),
                    y = ~raw_counts,
                    split = ~pipeline,
                    color = ~get(input$main_variable),
                    colors = c("#0097db", "#85C659", "#ec1515", "#febf2a", "#784f96"),
                    type = "box") %>%
      plotly::layout(yaxis = base::list(title = "Raw counts"),
                     xaxis = base::list(title = "", tickangle = 270),
                     margin = base::list(b = 200))
  })
  
  # generate scatterplot of raw counts for all sample in the levels/groups of the main variable of interest the user chooses to view ----
  output$scatterplot_raw_by_sample <- plotly::renderPlotly({
    
    subset_count_data() %>%
      base::split(base::list(subset_count_data() %>% dplyr::pull(input$main_variable), subset_count_data()$rna)) %>%
      base::lapply(function(x) {
        plotly::plot_ly(data = x,
                        x = x$sample,
                        y = ~raw_counts,
                        split = ~pipeline,
                        color = ~input$main_variable,
                        colors = c("#0097db", "#85C659", "#ec1515", "#febf2a", "#784f96"),
                        type = "scatter",
                        mode  = "markers",
                        marker = base::list(opacity = 0.5),
                        hoverinfo = "text",
                        text = ~paste("</br> Raw count:", base::format(raw_counts, big.mark = ",", scientific = FALSE, digits = 2),
                                      "</br> Sample:", x$sample,
                                      "</br> Treatment:", treatment,
                                      "</br> Pipeline:", pipeline,
                                      "</br> Low sequencing read count:", low_sequencing_read_count,
                                      "</br> Sequencing read count:", base::format(raw_read_count_fastq_file, big.mark = ",", scientific = FALSE, digits = 2))) %>%
          plotly::layout(yaxis = base::list(title = "Raw counts"),
                         xaxis = base::list(title = "", tickangle = 270, type = "category")) }) %>%
      plotly::subplot(shareY = TRUE)
  })
  
  # create interactive table of the users current selection of rna and rna_species that includes rna counts etc ----
  output$table <- DT::renderDataTable({
    
    DT::datatable(subset_count_data() %>% dplyr::select(rna,
                                                        rna_species,
                                                        sample,
                                                        low_sequencing_read_count,
                                                        raw_read_count_fastq_file,
                                                        pipeline,
                                                        raw_counts,
                                                        counts_per_million,
                                                        treatment) %>%
                    dplyr::mutate(across(c(rna_species,
                                           sample,
                                           low_sequencing_read_count,
                                           pipeline,
                                           treatment), base::as.factor)) %>%
                    dplyr::mutate(across(c(raw_counts,
                                           counts_per_million,
                                           raw_read_count_fastq_file), base::as.integer)),
                  selection = "single",
                  filter = "top",
                  rownames = FALSE,
                  colnames = c("RNA",
                               "RNA species",
                               "Sample",
                               "Low sequencing read count",
                               "Sequencing read count",
                               "Pipeline",
                               "Raw counts",
                               "Counts per million",
                               "Treatment"),
                  extensions = base::list("ColReorder" = NULL,
                                          "Buttons" = NULL,
                                          "FixedColumns" = base::list(leftColumns=1)),
                  options = base::list(
                    dom = "BRrltpi",
                    autoWidth = TRUE,
                    columnDefs = base::list(base::list(width = "200px", targets = 0)),
                    lengthMenu = base::list(c(10, 50, -1), c("10", "50", "All")),
                    ColReorder = TRUE,
                    buttons =
                      base::list("copy",
                                 base::list(extend = "collection",
                                            buttons = c("csv", "excel", "pdf"),
                                            text = "Download"),
                                 I("colvis"))))
  })
}
