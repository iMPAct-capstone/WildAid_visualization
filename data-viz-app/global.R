# Load packages ----
library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(googlesheets4)
library(leaflet)

# Read in the MPS data ----

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"
MPS_tracker_data <- read_sheet(url)
test <- MPS_tracker_data |> group_by(year, site, sub_category) |> summarize(n())

# Read in the MPA_map data ----



#Wrangle Data


