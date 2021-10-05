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

# load database data ----
db <- dbConnect(RSQLite::SQLite(), "./data/master-count.sqlite")
counts <- tbl(db, "counts")
species <- tbl(db, "species")
rna_species_pairs <- tbl(db, "rna_choices")

# load differential expression data ----
diff_expr_data <- read.csv("./data/master_diff_expr_data.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_1 <- read.csv("./data/master_sig_diff_expr_data_1.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_5 <- read.csv("./data/master_sig_diff_expr_data_5.csv", header = TRUE, stringsAsFactors = FALSE)
sig_diff_expr_data_10 <- read.csv("./data/master_sig_diff_expr_data_10.csv", header = TRUE, stringsAsFactors = FALSE)

# read in yaml config file
config <- yaml::yaml.load_file("config.yaml")

# get list of rna_species ----
rna_species_choices <- species %>% distinct() %>% pull()

# define server logic for app ----
server <- function(input, output, session) {
  
  # get the current rna species the user has chosen ----
  updateSelectizeInput(session, "rna_species_choice", choices = rna_species_choices, selected = "mirna", server = TRUE)
  
  # return rnas available for the user to choose from (depends on the users choice of rna species) ----
  rna_choices <- reactive({
    if(is.null(input$rna_species_choice)){
      return(rna_species_pairs %>% distinct() %>% pull())
    }
    
    rna_species_pairs %>% filter(rna_species==local(input$rna_species_choice)) %>% distinct() %>% pull()
  })
  
  # get the current rna the user has chosen ----
  observe({
    updateSelectizeInput(session, "rna_choice", choices = rna_choices(), server=TRUE)
  })
  
  # subset count data based on the user choice of rna_species and rna ----
  # the collect() function is required to force evaluation of "input$rna_choice" and "input$rna_species_choice" - otherwise is does lazy evaluation
  # the !! syntax is required to force dplyr to evaluate the user inputs (eg. input$rna_species_choice) before operating on it (eg. filter())
  subset_count_data <- reactive({
    
    req(input$rna_species_choice, input$rna_choice)
    
    counts %>%
      filter(rna_species==!!input$rna_species_choice & rna %in% !!input$rna_choice) %>%
      collect() %>%
      # order the levels of the data so they plot in a sensible order on the xaxes of the plots, user specifies in configuration file
      mutate(treatment = factor(treatment, levels = c(config$treatment_order))) %>%
      # also format logical variable so it renders properly
      mutate(low_sequencing_read_count = as.logical(low_sequencing_read_count))
  })
  
  # subset differential expression data based on the user choice of rna_species and rna ----
  # the collect() function is required to force evaluation of "input$rna_choice" and "input$rna_species_choice" - otherwise is does lazy evaluation
  # the !! syntax is required to force dplyr to evaluate the user inputs (eg. input$rna_species_choice) before operating on it (eg. filter())
  subset_diff_expr_data <- reactive({
    
    req(input$rna_species_choice, input$rna_choice)
    
    diff_expr_data %>% 
      filter(rna_species==!!input$rna_species_choice & rna %in% !!input$rna_choice) %>%
      collect()
  })
  
  # create a user input switch that will let the user view the data based on their main variable of interest ----
  main_variable <- reactive({
    switch(input$variable_of_interest,
           "Treatment" = "treatment")
  })
  
  # create interactive table of the users current selection of rna and rna_species that show differential expressions results ----
  output$table_diff_expr <- renderDataTable({
    
    datatable(subset_diff_expr_data() %>% select(rna,
                                                 rna_species,
                                                 comparison,
                                                 pipeline,
                                                 diff_expr_method,
                                                 log_fc,
                                                 adj_p_value,
                                                 significance),
              filter = "top",
              rownames = FALSE,
              colnames = c("RNA",
                           "RNA species",
                           "Treatment comparison",
                           "Pipeline",
                           "Differential expression method",
                           "Log fold change",
                           "Adjusted p-value",
                           "Significance"),
              extensions = list("ColReorder" = NULL,
                                "Buttons" = NULL,
                                "FixedColumns" = list(leftColumns=1)),
              options = list(
                dom = "BRrltpi",
                autoWidth = TRUE,
                columnDefs = list(list(width = "200px", targets = 0)),
                lengthMenu = list(c(10, 50, -1), c("10", "50", "All")),
                ColReorder = TRUE,
                buttons =
                  list("copy",
                       list(extend = "collection",
                            buttons = c("csv", "excel", "pdf"),
                            text = "Download"),
                       I("colvis")))) %>%
      # Highlight the rnas/rows that are of possible interest from the presence/absence analysis
      # This matches the css highlighting in the RNA drop down box
      # formatStyle("presence_absence",
      #             target = "row",
      #             backgroundColor = styleEqual(c("in_majority_of_one_group_not_in_several_of_another_group"),
      #                                          c("#bad9f5"))) %>%
      # Highlight the rnas/rows that are significantly differentially expressed
      # A different highlight is used for the three significance levels (1%, 5%, 10%)
      # This matches the css highlighting in the RNA drop down box
      # This highlighting was done last so the differential expression results "trump"
      # when an RNA is both significantly differentially expressed and of interest in the
    # presence/absence analysis
    formatStyle("significance",
                target = "row",
                backgroundColor = styleEqual(c("significant_1%",
                                               "significant_5%",
                                               "significant_10%"),
                                             c("#ffe342",
                                               "#ffef8a",
                                               "#fff5b8")))
    
  })
  
  # generate boxplot of normalised counts per million averaged over samples in the levels/groups of the main variable of interest the user chooses to view ----
  output$box_plot_cpm <- renderPlotly({
    
    # print a message if the user hasn't yet selected an RNA
    validate(need(input$rna_choice, "Select an RNA from the drop down box above to create RNA expression plots!"))
    
    # print a message if no count per million data could be calculated for this data
    validate(need(subset_count_data()$counts_per_million, "Count per million data could not be calculated for this RNA - the counts were too small"))
    
    plot_ly(data = (subset_count_data()),
            x = ~interaction(get(main_variable()), rna),
            y = ~counts_per_million,
            split = ~pipeline,
            color = ~get(main_variable()),
            type = "box",
            box = list(visible = T),
            meanline = list(visible = T)) %>%
      layout(yaxis = list(title = "Counts per million"),
             xaxis = list(title = "", tickangle = 270),
             margin = list(b = 200))
  })
  
  # generate scatterplot of normalised counts per million for all samples in the levels/groups of the main variable of interest the user chooses to view ----
  output$scatterplot_cpm_by_sample <- renderPlotly({
    
    # print a message if no count per million data could be calculated for this data
    validate(need(subset_count_data()$counts_per_million, "Count per million data could not be calculated for this RNA"))
    
    subset_count_data() %>%
      split(list(subset_count_data() %>% pull(!!main_variable()), subset_count_data()$rna)) %>%
      lapply(function(x) {
        plot_ly(data = x,
                x = x$sample,
                y = ~counts_per_million,
                split = ~pipeline,
                color = ~get(main_variable()),
                type = "scatter",
                mode  = "markers",
                marker = list(opacity = 0.5),
                hoverinfo = "text",
                text = ~paste("</br> Counts per million:", format(counts_per_million, big.mark = ",", scientific = FALSE, digits = 2),
                              "</br> Sample:", x$sample,
                              "</br> Treatment:", treatment,
                              "</br> Pipeline:", pipeline,
                              "</br> Low sequencing read count:", low_sequencing_read_count)) %>%
          layout(showlegend = FALSE) %>%
          layout(yaxis = list(title = "Counts per million"),
                 xaxis = list(title = "", tickangle = 270, type = "category"))
      }) %>% subplot(shareY = TRUE)
  })
  
  # generate boxplot of raw counts for all samples in the levels/groups of the main variable of interest the user chooses to view ----
  output$box_plot_raw <- renderPlotly({
    
    # generate boxplot of raw counts per averaged over samples in the levels/groups of the main variable of interest the user chooses to view ----
    plot_ly(data = (subset_count_data()),
            x = ~interaction(get(main_variable()), rna),
            y = ~raw_counts,
            split = ~pipeline,
            color = ~get(main_variable()),
            type = "box",
            box = list(visible = T),
            meanline = list(visible = T)) %>%
      layout(yaxis = list(title = "Raw counts"),
             xaxis = list(title = "", tickangle = 270),
             margin = list(b = 200))
  })
  
  # generate scatterplot of raw counts for all sample in the levels/groups of the main variable of interest the user chooses to view ----
  output$scatterplot_raw_by_sample <- renderPlotly({
    
    subset_count_data() %>%
      split(list(subset_count_data() %>% pull(!!main_variable()), subset_count_data()$rna)) %>%
      lapply(function(x) {
        plot_ly(data = x,
                x = x$sample,
                y = ~raw_counts,
                split = ~pipeline,
                color = ~get(main_variable()),
                type = "scatter",
                mode  = "markers",
                marker = list(opacity = 0.5),
                hoverinfo = "text",
                text = ~paste("</br> Raw count:", format(raw_counts, big.mark = ",", scientific = FALSE, digits = 2),
                              "</br> Sample:", x$sample,
                              "</br> Treatment:", treatment,
                              "</br> Pipeline:", pipeline,
                              "</br> Low sequencing read count:", low_sequencing_read_count)) %>%
          layout(showlegend = FALSE) %>%
          layout(yaxis = list(title = "Raw counts"),
                 xaxis = list(title = "", tickangle = 270, type = "category")) }) %>%
      subplot(shareY = TRUE)
  })
  
  # create interactive table of the users current selection of rna and rna_species that includes rna counts etc ----
  output$table <- renderDataTable({
    
    datatable(subset_count_data() %>% select(rna,
                                             rna_species,
                                             sample,
                                             low_sequencing_read_count,
                                             pipeline,
                                             raw_counts,
                                             counts_per_million,
                                             treatment) %>%
                mutate_if(is.numeric, format, big.mark = ",", scientific = FALSE, digits = 0),
              selection = "single",
              filter = "top",
              rownames = FALSE,
              colnames = c("RNA",
                           "RNA species",
                           "Sample",
                           "Low sequencing read count",
                           "Pipeline",
                           "Raw counts",
                           "Counts per million",
                           "Treatment"),
              extensions = list("ColReorder" = NULL,
                                "Buttons" = NULL,
                                "FixedColumns" = list(leftColumns=1)),
              options = list(
                dom = "BRrltpi",
                autoWidth = TRUE,
                columnDefs = list(list(width = "200px", targets = 0)),
                lengthMenu = list(c(10, 50, -1), c("10", "50", "All")),
                ColReorder = TRUE,
                buttons =
                  list("copy",
                       list(extend = "collection",
                            buttons = c("csv", "excel", "pdf"),
                            text = "Download"),
                       I("colvis"))))
  })
}
