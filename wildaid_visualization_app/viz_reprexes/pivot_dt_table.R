# # global variables can go here: ----
# library(shiny)
# library(dplyr) 
# library(tidyverse) 
# library(leaflet) 
# library(plotly) 
# library(ggplot2) 
# library(googledrive) 
# library(googlesheets4)
# library(radiant.data)
# library(DT)
# library(janitor)
# library(shinycssloaders)
# library(hrbrthemes)
# library(shinyWidgets) 
# 
# # define the UI here: ----
# ui <- fluidPage(
#   mainPanel(
#     DTOutput("dt_table")
#   )
#  
# )# end UI fluid page
# 
# # define the server here: ----
# 
# function(input, output) {
#   
#   url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"
#   
#   # get our MPS tracker data
#   MPS_tracker_data <- read_sheet(url) |> 
#     mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
#            category = as.factor(category), 
#            country = as.factor(country)) |> 
#     select(-indicator_type)
#   datatable(MPS_tracker_data) # is this necessary? should I store a variable for it? doesn't seem necessary
#   
#   
#   # DT datatable ----
#   output$dt_table <- DT::renderDataTable(
#     DT::datatable(data = select(MPS_tracker_data, -visualization_include), # take out a column
#                   rownames = FALSE,
#                   escape=TRUE, # don't understand what this does could be important
#                   caption = "Here is a filter-able compilation of all of our data", 
#                   filter = 'top',
#                   options = list(
#                     pageLength = 10, autoWidth = TRUE,
#                     columnDefs = list(list(targets = 5, width = '80px'), 
#                                       list(targets = 6, width = '400px'), 
#                                       list(targets = 3, width = '10px')), # play with column widths
#                     scrollX = TRUE
#                   )))
#   
# }
# 
# # Run the application 
# shinyApp(ui = ui, server = server)


### TRY AGAIN

shinyApp(
  ui = fluidPage(
    
    DTOutput("dt_table")
    
  ),
  server = function(input, output, session) {
    url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

      # get our MPS tracker data
      MPS_tracker_data <- read_sheet(url) |>
        mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
               category = as.factor(category),
               country = as.factor(country)) |>
        select(-indicator_type)
      datatable(MPS_tracker_data) # is this necessary? should I store a variable for it? doesn't seem necessary


      # DT datatable ----
      output$dt_table <- DT::renderDataTable(
        DT::datatable(data = select(MPS_tracker_data, -visualization_include), # take out a column
                      rownames = FALSE,
                      escape=TRUE, # don't understand what this does could be important
                      caption = "Here is a filter-able compilation of all of our data",
                      filter = 'top',
                      options = list(
                        pageLength = 10, autoWidth = TRUE,
                        columnDefs = list(list(targets = 5, width = '80px'),
                                          list(targets = 6, width = '400px'),
                                          list(targets = 3, width = '10px')), # play with column widths
                        scrollX = TRUE
                      )))
  }
)
