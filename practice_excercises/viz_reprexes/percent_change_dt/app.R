# global variables can go here: ----
library(shiny)
library(dplyr)
library(tidyverse)
library(leaflet)
library(plotly)
library(ggplot2)
library(googledrive)
library(googlesheets4)
library(radiant.data)
library(DT)
library(janitor)
library(shinycssloaders)
library(hrbrthemes)
library(shinyWidgets)
library(tidyr)
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

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# get our MPS tracker data
MPS_tracker_data <- read_sheet(url) |>
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category),
         country = as.factor(country)) |>
  select(-indicator_type)
datatable(MPS_tracker_data) # is this necessary? should I store a variable for it? doesn't seem necessary



# # arrange data by year and site so the lag() function can reference properly
# arranged_mps <- MPS_tracker_data |> 
#   arrange(site, year)
# 
# perc_chg_mps <- arranged_mps |> 
#   group_by(site) |> 
#   mutate(percent_change = (score - lag(score))/lag(score) * 100) |> 
#   ungroup()
# 
# # Pivot the table to wide format with years as columns
# wider_perc_chg <- perc_chg_mps %>%
#   pivot_wider(names_from = year, values_from = percent_change)
# 
# # Create an index column with site names
# final_perc_chg <- wider_perc_chg %>%
#   mutate(index = site) %>%
#   select(index, everything())
# 
# # View the final table
# final_table


# THIS CHUNK WORKS: (need to put in the format of the below dt output if silvia says she wants it in the app)
# we want to calculate the percent change for the total average score for each site over the years operated
perc_1 <- MPS_tracker_data |> 
  filter(visualization_include == "yes") |> 
  group_by(site, year) |> 
  summarise(score = mean(score, na.rm = TRUE)) |> 
  arrange(site, year) |> 
  mutate(percent_change = (score - lag(score))/lag(score) * 100) |> 
  select(site, year, percent_change) |> 
  pivot_wider(names_from = year, values_from = percent_change) 

# Sort the year columns based on their numeric values
sorted_year_columns <- colnames(perc_1)[order(as.numeric(colnames(perc_1)))]
# Reorder the columns in the dataframe
perc_2 <- perc_1[, sorted_year_columns] |> 
  select(site, everything())



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
    
    DTOutput("perc_chg_dt")
    
  ),
  server = function(input, output, session) {
    # url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"
    # 
    # # get our MPS tracker data
    # MPS_tracker_data <- read_sheet(url) |>
    #   mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
    #          category = as.factor(category),
    #          country = as.factor(country)) |>
    #   select(-indicator_type)
    # datatable(MPS_tracker_data) # is this necessary? should I store a variable for it? doesn't seem necessary
    # 
    
    # DT datatable ----
    output$perc_chg_dt <- DT::renderDataTable(
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