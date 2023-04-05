# Load packages ----
library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(googlesheets4)
library(leaflet)

# Read in the data ----

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"
MPS_tracker_data <- read_sheet(url)

# keep in mind there might be something that we can do that will automate the google drive account selection process 

# Store the data in a csv file ----
# this will live in our data folder... will this be re-written every time the data is updated or the app is run?

#write_csv(MPS_tracker_data, ) gonna leave this step out for now
