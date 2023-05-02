# load required dependencies 
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
library(sass)
library(shiny)
library(lubridate)
library(scales)
library(ggridges)
library(viridis)
library(gargle)
library(rsconnect)
library(shinyauthr)

# auto-authenticate google sheets ... this will have you interactively authenticate using browser the first time and then after that, you are good to go!

options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "jaredpetry@ucsb.edu")
gs4_auth(token = drive_token())

# USER LOGIN INFORMATION 

# dataframe that holds usernames, passwords and other user data
user_base <- tibble::tibble(
  user = c("user1", "user2"),
  password = c("pass1", "pass2"),
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)


# Read in our MPS data ----

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"
MPS_tracker_data <- read_sheet(url)

datatable(MPS_tracker_data)

# make the year column numeric to make the filtering better
MPS_tracker_data <- MPS_tracker_data |> 
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type) |> # take out indicator type because obsolete 
  arrange(year)


# read in the map data ----
map_url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit?usp=sharing"

map_data <- read_sheet(map_url) |> 
  clean_names() |> 
  filter(active_site == "current") |> 
  separate(status, into = c("status_numb", "status_key"), sep = " - ", remove = FALSE) |> 
  mutate(status_numb = as.numeric(status_numb)) |> 
  filter(active_site == "current")

# mean_data for faceted histogram
mean_data <- MPS_tracker_data |> 
  select(country, score) |> 
  na.omit() |> 
  group_by(country) |> 
  summarise(mean_score = mean(score))

