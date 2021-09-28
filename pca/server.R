# load libraries
library(shiny)
library(shinythemes)
library(shinydashboard)
library(dplyr)
library(plotly)
library(shinycssloaders)
library(DT)
library(crosstalk)
library(gtools)

# linked plotly and datatable based on this stackoverfow question and answer:
# https://stackoverflow.com/questions/54344375/how-do-i-use-crosstalk-in-shiny-to-filter-a-reactive-data-table

# load data ----

# scree plot data 
scree <- read.csv("./data/scree.csv", header = TRUE, stringsAsFactors = FALSE)

# individuals (RNA's)
individuals_1_2 <- read.csv("./data/individuals_1_2.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_1_3 <- read.csv("./data/individuals_1_3.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_1_4 <- read.csv("./data/individuals_1_4.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_1_5 <- read.csv("./data/individuals_1_5.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_2_3 <- read.csv("./data/individuals_2_3.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_2_4 <- read.csv("./data/individuals_2_4.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_2_5 <- read.csv("./data/individuals_2_5.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_3_4 <- read.csv("./data/individuals_3_4.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_3_5 <- read.csv("./data/individuals_3_5.csv", header = TRUE, stringsAsFactors = FALSE)
individuals_4_5 <- read.csv("./data/individuals_4_5.csv", header = TRUE, stringsAsFactors = FALSE)

# variables (samples)
variables_1_2 <- read.csv("./data/variables_1_2.csv", header = TRUE, stringsAsFactors = FALSE)
variables_1_3 <- read.csv("./data/variables_1_3.csv", header = TRUE, stringsAsFactors = FALSE)
variables_1_4 <- read.csv("./data/variables_1_4.csv", header = TRUE, stringsAsFactors = FALSE)
variables_1_5 <- read.csv("./data/variables_1_5.csv", header = TRUE, stringsAsFactors = FALSE)
variables_2_3 <- read.csv("./data/variables_2_3.csv", header = TRUE, stringsAsFactors = FALSE)
variables_2_4 <- read.csv("./data/variables_2_4.csv", header = TRUE, stringsAsFactors = FALSE)
variables_2_5 <- read.csv("./data/variables_2_5.csv", header = TRUE, stringsAsFactors = FALSE)
variables_3_4 <- read.csv("./data/variables_3_4.csv", header = TRUE, stringsAsFactors = FALSE)
variables_3_5 <- read.csv("./data/variables_3_5.csv", header = TRUE, stringsAsFactors = FALSE)
variables_4_5 <- read.csv("./data/variables_4_5.csv", header = TRUE, stringsAsFactors = FALSE)

# make sure the dimensions are read as a character
scree$component <- as.character(scree$component)

# natural sorting of xaxis
scree$component <- factor(scree$component, levels = mixedsort(scree$component))

# define server logic for app ----
server <- function(input, output, session) {
  
  # creating a shared dataframe that links the plotly scatterplot and datatable table (variables/samples)
  linked_data_scree <- reactive({
    
    sd_scree <- SharedData$new(scree)
    
  })
  
  # create a user input switch that will select the pca individuals (RNA's) data based on the users selection of dimensions to view ----
  # also create a shared dataframe that links the plotly scatterplot and datatable table (individuals/RNA's)
  linked_data_individuals <- reactive({
    
    data_ind <- switch(input$dimension_choice,
                       "1 and 2" = individuals_1_2,
                       "1 and 3" = individuals_1_3,
                       "1 and 4" = individuals_1_4,
                       "1 and 5" = individuals_1_5,
                       "2 and 3" = individuals_2_3,
                       "2 and 4" = individuals_2_4,
                       "2 and 5" = individuals_2_5,
                       "3 and 4" = individuals_3_4,
                       "3 and 5" = individuals_3_5,
                       "4 and 5" = individuals_4_5)
    
    sd_individuals <- SharedData$new(data_ind)
    
  })
  
  # create a user input switch that will select the pca variables (samples) data based on the users selection of dimensions to view ----
  # also create a shared dataframe that links the plotly scatterplot and datatable table (variables/samples)
  linked_data_variables <- reactive({
    
    data_var <- switch(input$dimension_choice,
                       "1 and 2" = variables_1_2,
                       "1 and 3" = variables_1_3,
                       "1 and 4" = variables_1_4,
                       "1 and 5" = variables_1_5,
                       "2 and 3" = variables_2_3,
                       "2 and 4" = variables_2_4,
                       "2 and 5" = variables_2_5,
                       "3 and 4" = variables_3_4,
                       "3 and 5" = variables_3_5,
                       "4 and 5" = variables_4_5)
    
    sd_variables <- SharedData$new(data_var)
    
  })
  
  # create a switch that will output the dimensions we're viewing data based on the users selection of dimensions to view ----
  x_dim <- reactive({
    
    switch(input$dimension_choice,
           "1 and 2" = "1",
           "1 and 3" = "1",
           "1 and 4" = "1",
           "1 and 5" = "1",
           "2 and 3" = "2",
           "2 and 4" = "2",
           "2 and 5" = "2",
           "3 and 4" = "3",
           "3 and 5" = "3",
           "4 and 5" = "4")
  })
  
  y_dim <- reactive({
    
    switch(input$dimension_choice,
           "1 and 2" = "2",
           "1 and 3" = "3",
           "1 and 4" = "4",
           "1 and 5" = "5",
           "2 and 3" = "3",
           "2 and 4" = "4",
           "2 and 5" = "5",
           "3 and 4" = "4",
           "3 and 5" = "5",
           "4 and 5" = "5")
  })
  
  # grab variance explained by different dimensions based on the dimensions the user chooses to view ----
  dim_x_variance_explained <- reactive({
    
    scree %>%
      filter(component == x_dim()) %>%
      pull(percentage.of.variance) %>%
      format(big.mark = ",", scientific = FALSE, digits = 2)
    
  })
  
  dim_y_variance_explained <- reactive({
    
    scree %>%
      filter(component == y_dim()) %>%
      pull(percentage.of.variance) %>%
      format(big.mark = ",", scientific = FALSE, digits = 2)
    
  })
  
  # generate scree plot of the pca ----
  output$scree_plot <- renderPlotly({
    
    plot_ly(data = linked_data_scree(),
            type = "bar",
            x = ~component,
            y = ~percentage.of.variance,
            height = "100%",
            hoverinfo = "text",
            text = ~paste("</br> Percentage of variance:", format(percentage.of.variance, big.mark = ",", scientific = FALSE, digits = 2), "%",
                          "</br> Dimension:", component)) %>%
      layout(barmode = "overlay",
             xaxis = list(title = "Dimension"),
             yaxis = list(title = "Percentage of variance", range = c(0, 100))) %>%
      config(displaylogo = FALSE,
             modeBarButtonsToRemove = c("zoomIn2d",
                                        "zoomOut2d",
                                        "autoScale2d",
                                        "hoverClosestCartesian",
                                        "hoverCompareCartesian",
                                        "lasso2d")) %>%
      highlight(on = "plotly_selected",
                opacityDim = 0.2,
                selected = attrs_selected(opacity = 1))
    
  })
  
  # create interactive table of the scree data ----
  output$table_scree <- renderDataTable({
    
    datatable(linked_data_scree(),
              filter = "top",
              rownames = FALSE,
              colnames = c("Dimension",
                           "Eigenvalue",
                           "Percentage of variance (%)",
                           "Cumulative percentage of variance (%)"),
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
                            buttons = c("csv"),
                            text = "Download"),
                       I("colvis")))) %>%
      highlight(on = "plotly_click",
                opacityDim = 0.2,
                selected = attrs_selected(opacity = 1))
    
  }, server = FALSE)
  
  # generate scatterplot of the pca (individuals - RNA's) based on the dimensions the user chooses to view ----
  output$individuals_plot <- renderPlotly({
    
    p <- plot_ly(data = linked_data_individuals(),
                 x = ~x_coord,
                 y = ~y_coord,
                 color = ~x_cos,
                 height = "100%",
                 type = "scatter",
                 hoverinfo = "text",
                 text = ~paste("</br> RNA:", rna,
                               "</br> Dim ", x_dim(), ":", format(x_coord, big.mark = ",", scientific = FALSE, digits = 0),
                               "</br> Dim ", y_dim(), ":", format(y_coord, big.mark = ",", scientific = FALSE, digits = 0),
                               "</br> Dim ", x_dim(), "cos2:", format(x_cos, big.mark = ",", scientific = FALSE, digits = 2))) %>%
      add_markers() %>%
      layout(xaxis = list(title = paste0("Dim ", x_dim(), " (", dim_x_variance_explained(), "% of variance)")),
             yaxis = list(title = paste0("Dim ", y_dim(), " (", dim_y_variance_explained(), "% of variance)"))) %>%
      colorbar(title = paste0("Dim ", x_dim(), " cos2")) %>%
      config(displaylogo = FALSE,
             modeBarButtonsToRemove = c("zoomIn2d",
                                        "zoomOut2d",
                                        "select2d",
                                        "autoScale2d",
                                        "hoverClosestCartesian",
                                        "hoverCompareCartesian")) %>%
      layout(dragmode = "lasso", showlegend = FALSE) %>%
      highlight(on = "plotly_selected",
                opacityDim = 0.2,
                selected = attrs_selected(opacity = 1))
    
    toWebGL(p)
    
  })
  
  # create interactive table of pca (individuals - RNA's) based on the dimensions the user chooses to view ----
  output$table_individuals <- renderDataTable({
    
    datatable(linked_data_individuals(),
              filter = "top",
              rownames = FALSE,
              colnames = c("RNA",
                           paste0("Dim ", x_dim(), " coord"),
                           paste0("Dim ", y_dim(), " coord"),
                           paste0("Dim ", x_dim(), " cos"),
                           paste0("Dim ", y_dim(), " cos")),
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
                            buttons = c("csv"),
                            text = "Download"),
                       I("colvis")))) %>%
      highlight(on = "plotly_selected",
                opacityDim = 0.2,
                selected = attrs_selected(opacity = 1))
    
  }, server = FALSE)
  
  # generate scatterplot of the pca (variables - samples) based on the dimensions the user chooses to view ----
  output$variables_plot <- renderPlotly({
    
    plot_ly(data = (linked_data_variables()),
            x = ~x_coord,
            y = ~y_coord,
            color = ~x_cos,
            type = "scatter",
            height = "100%",
            hoverinfo = "text",
            text = ~paste("</br> Sample:", sample,
                          "</br> Treatment:", Treatment,
                          "</br> Dim ", x_dim(), ":", format(x_coord, big.mark = ",", scientific = FALSE, digits = 2),
                          "</br> Dim ", y_dim(), ":", format(y_coord, big.mark = ",", scientific = FALSE, digits = 2),
                          "</br> Dim ", x_dim(), "cos2:", format(x_cos, big.mark = ",", scientific = FALSE, digits = 2))) %>%
      layout(xaxis = list(title = paste0("Dim ", x_dim(), " (", dim_x_variance_explained(), "% of variance)"), range = c(-1.2, 1.2)),
             yaxis = list(title = paste0("Dim ", y_dim(), " (", dim_y_variance_explained(), "% of variance)"), range = c(-1.2, 1.2))) %>%
      colorbar(title = paste0("Dim ", x_dim(), " cos2")) %>%
      config(displaylogo = FALSE,
             modeBarButtonsToRemove = c("zoomIn2d",
                                        "zoomOut2d",
                                        "select2d",
                                        "autoScale2d",
                                        "hoverClosestCartesian",
                                        "hoverCompareCartesian")) %>%
      layout(dragmode = "lasso", showlegend = FALSE) %>%
      highlight(on = "plotly_selected",
                opacityDim = 0.1,
                selected = attrs_selected(opacity = 1))
  })
  
  # create interactive table of pca (variables - RNA's) based on the dimensions the user chooses to view ----
  output$table_variables <- renderDataTable({
    
    datatable(linked_data_variables(),
              filter = "top",
              rownames = FALSE,
              colnames = c("Sample",
                           "Treatment",
                           paste0("Dim ", x_dim(), " coord"),
                           paste0("Dim ", y_dim(), " coord"),
                           paste0("Dim ", x_dim(), " cos"),
                           paste0("Dim ", y_dim(), " cos")),
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
                            buttons = c("csv"),
                            text = "Download"),
                       I("colvis")))) %>%
      highlight(on = "plotly_selected",
                opacityDim = 0.01,
                selected = attrs_selected(opacity = 1))
    
  }, server = FALSE)
}
