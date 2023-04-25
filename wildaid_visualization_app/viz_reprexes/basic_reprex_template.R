# global variables can go here: ----
library(shiny)
library(DT) 
library(tidyverse) 
library(dplyr) 
library(googlesheets4) 
library(googledrive) 

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# get our MPS tracker data
MPS_tracker_data <- read_sheet(url) |> 
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type)

# define the UI here: ----

# define the server here: ----