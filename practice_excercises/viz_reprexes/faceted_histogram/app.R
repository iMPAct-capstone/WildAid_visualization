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

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# get our MPS tracker data
MPS_tracker_data <- read_sheet(url) |> 
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type)

# define the UI here: ----
ui <- fluidPage(
  
  # copy the following into the app:
  # NOTE: would it be possible to (yes, but how hard is it) lets the user select site and year for each frame.... 
  # we would have to change the histogram from faceted to just single 
  # would need 8 user inputs... 2 for each of the four plots
  # ok super stretch goal! what if we made this one of those stacked up dot histogram type deals and wrapped it in plotly to be able to show all the details of that specific entry.... I think i might have just thought of the best visualization ever at the last moment. But that's ok because sometimes things happen that way ... don't worry about it.
  fluidRow(
    column(width = 12,
           selectInput("hist_year_select", "Select Year:",
                       choices = c("Site Level", "Country Level"),
                       selected = "Site Level"),
           selectInput("hist_site_select1", "Select Site Level or Country Level:",
                       choices = c("Site Level", "Country Level"),
                       selected = "Site Level"),
           selectInput("hist_site_select2", "Select Site Level or Country Level:",
                       choices = c("Site Level", "Country Level"),
                       selected = "Site Level"),
           selectInput("hist_site_select3", "Select Site Level or Country Level:",
                       choices = c("Site Level", "Country Level"),
                       selected = "Site Level"),
           selectInput("hist_site_select4", "Select Site Level or Country Level:",
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
  
  
)

# define the server here: ----
server <- function(input, output) {
  
  # ok lets try a simple histogram faceted by country so we can do fancier stuff
  
  # create a little dataframe with the mean score of each so we can place the vertical lines over the histograms 
  mean_data <- MPS_tracker_data |> 
    select(country, score) |> 
    na.omit() |> 
    group_by(country) |> 
    summarise(mean_score = mean(score))
  
  facet_hist <- MPS_tracker_data |> 
    select(country, score) |> 
    na.omit() |> 
    ggplot(aes(x = score, fill = country)) + 
    geom_histogram(aes(y = ..density..), 
                   binwidth = 1, bins = 5) + 
    geom_vline(data = mean_data, aes(xintercept = mean_score), color = "black",alpha = 0.3) +
    facet_wrap(~country, ncol = 2, scales = 'free') + 
    scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
    scale_y_continuous(limits = c(0,0.6)) +
    theme_bw() + 
    theme(legend.position = "none") + 
    scale_fill_brewer(palette = "Set2")
  
  facet_hist
  
  
}


# Run the application ----
shinyApp(ui = ui, server = server)