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

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# get our MPS tracker data
MPS_tracker_data <- read_sheet(url) |>
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category),
         country = as.factor(country)) |>
  select(-indicator_type)
datatable(MPS_tracker_data) # is this necessary? should I store a variable for it? doesn't seem necessary



# THIS CHUNK WORKS: (need to put in the format of the below dt output if silvia says she wants it in the app)
# we want to calculate the percent change for the total average score for each site over the years operated
perc_chg_site <- MPS_tracker_data |> 
  filter(visualization_include == "yes") |> 
  group_by(site, year) |> 
  summarise(score = mean(score, na.rm = TRUE)) |> 
  arrange(site, year) |> 
  mutate(percent_change = (score - lag(score))/lag(score) * 100) |> 
  select(site, year, percent_change) |> 
  pivot_wider(names_from = year, values_from = percent_change) 

# Sort the year columns based on their numeric values
sorted_year_columns <- colnames(perc_chg_site)[order(as.numeric(colnames(perc_chg_site)))]
# Reorder the columns in the dataframe
perc_chg_site <- perc_chg_site[, sorted_year_columns] |> 
  select(site, everything())

# OK now let's do that same thing but with country instead 
perc_country <- MPS_tracker_data |> 
  filter(visualization_include == "yes") |> 
  group_by(country, year) |> 
  summarise(score = mean(score, na.rm = TRUE)) |> 
  arrange(country, year) |> 
  mutate(percent_change = (score - lag(score))/lag(score) * 100) |> 
  select(country, year, percent_change) |> 
  pivot_wider(names_from = year, values_from = percent_change)

# Sort the year columns based on their numeric values
sorted_country_columns <- colnames(perc_country)[order(as.numeric(colnames(perc_country)))]
# Reorder the columns in the dataframe
perc_country <- perc_country[, sorted_country_columns] |> 
  select(country, everything())

# construct shiny app 
shinyApp(
  
  # define user interface UI
  ui = fluidPage(
    # copy the following into the app:
    fluidRow(
      column(width = 12,
             selectInput("tableSelector", "Select Site Level or Country Level:",
                         choices = c("Site Level", "Country Level"),
                         selected = "Site Level")
      ),
  ),
  
  fluidRow(
    column(width = 12,
           uiOutput("perc_chg_table")
    ) 
  )
  # end copy into app
  
  ),
  
  # define server 
  server = function(input, output, session) {
    
    # renders UI input. One of the two tables
    output$perc_chg_table <- renderUI({
      if (input$tableSelector == "Site Level") {
        dataTableOutput("perc_chg_site")
      } else if (input$tableSelector == "Country Level") {
        dataTableOutput("perc_chg_country")
      }
    })
    
    # DT perc change site level ----
    output$perc_chg_site <- DT::renderDataTable(
      DT::datatable(data = perc_chg_site, 
                    rownames = FALSE,
                    caption = "This table shows percent change (positive or negative) for the average of all scores for each site from year to year.  For example, the percent change in the 2022 column reflects the percent change for that site in 2021.  The blank values mean that there was no previous data entrys for that site the previous year, therefore a percent change cannot be calculated.",
                    options = list(
                                   pageLength = 40, 
                                   scrollX = TRUE,
                                   
                                   fixedHeader = TRUE
                    )))
      
    
    # DT perc change table for country level 
    output$perc_chg_country <- DT::renderDataTable(
      DT::datatable(data = perc_country, 
                    rownames = FALSE,
                    caption = "This table shows percent change (positive or negative) for the average of all scores for each country from year to year.  For example, the percent change in the 2022 column reflects the percent change for that country in 2021.  The blank values mean that there was no previous data entrys for that country the previous year, therefore a percent change cannot be calculated.",
                    options = list(
                      pageLength = 40,
                      scrollX = TRUE,
                      fixedHeader = TRUE
                    )
      ))
  }
)