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
library(shiny) 
library(shinydashboard) 

# auto-authenticate google sheets ... this will have you interactively authenticate using browser the first time and then after that, you are good to go!

options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "adelaide.robinson445@gmail.com")
gs4_auth(token = drive_token())

# USER LOGIN INFORMATION 

# # dataframe that holds usernames, passwords and other user data
password_url <- "https://docs.google.com/spreadsheets/d/1pTWPJ10x66DgMFtFqy_8wZFPh8hgygkiBuGsW4BtejI/edit#gid=0"
password_sheet <- read_sheet(password_url, sheet = "visualization")


user_base <- tibble::tibble(
  user = password_sheet$username,
  password = purrr::map_chr(password_sheet$password, sodium::password_store),
  permissions = password_sheet$permission,
  name = password_sheet$name
)

# Read in our MPS data ----

folder_url <- "https://drive.google.com/drive/u/1/folders/1AvavGBfoZx_ThcXVn5gL_buQkip76ZtQ"
files <- drive_ls(folder_url) |>
  filter(name == "mps_tracker_data")
main_sheet_id <- as_id(files)

MPS_tracker_data <- read_sheet(main_sheet_id)


# make the year column numeric to make the filtering better
MPS_tracker_data <- MPS_tracker_data |> 
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type) |> # take out indicator type because obsolete 
  arrange(year) |> 
  filter(visualization_include == "yes") |> 
  select(-visualization_include) |> 
  droplevels()

# order the data by year (for some plots)
data_ordered <- MPS_tracker_data |> 
  arrange(year)

# read in the map data ----
map_url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit#gid=1669338265"

# clean the map data and prepare for visualization in server 
map_data <- read_sheet(map_url) |> 
  clean_names() |> 
  filter(active_site == "current") |>  # make sure that the data is only used if the entry is marked "current"
  separate(status, into = c("status_numb", "status_key"), sep = " - ", remove = FALSE) |> 
  mutate(status_numb = as.numeric(status_numb)) |> 
  mutate(latitude = as.numeric(latitude)) |> 
  mutate(longitude = as.numeric(longitude)) |> 
  filter(complete.cases(latitude, longitude))

# mean_data for faceted histogram
mean_data <- MPS_tracker_data |> 
  select(country, score) |> 
  na.omit() |> 
  group_by(country) |> 
  summarise(mean_score = mean(score))

# PERCENT CHANGE TABLE SETUP ----
perc_chg_site <- MPS_tracker_data |> # make sure that the data is only used if the entry is marked "yes"
  group_by(site, year) |> 
  summarise(score = mean(score, na.rm = TRUE)) |> 
  arrange(site, year) |> 
  mutate(percent_change = round((score - lag(score))/lag(score) * 100, 3)) |> 
  select(site, year, percent_change) |> 
  pivot_wider(names_from = year, values_from = percent_change) 

# Sort the year columns based on their numeric values
sorted_year_columns <- colnames(perc_chg_site)[order(as.numeric(colnames(perc_chg_site)))]
# Reorder the columns in the dataframe
perc_chg_site <- perc_chg_site[, sorted_year_columns] |> 
  select(site, everything())

# Add percent symbols 
columns_format_site <- names(perc_chg_site)[2:length(names(perc_chg_site))]

perc_chg_site[columns_format_site] <- lapply(perc_chg_site[columns_format_site], function(x) {
  x[!is.na(x)] <- paste0(x[!is.na(x)], "%")
  x
})

# OK now let's do that same thing but with country instead 
perc_country <- MPS_tracker_data |> 
  group_by(country, year) |> 
  summarise(score = mean(score, na.rm = TRUE)) |> 
  arrange(country, year) |> 
  mutate(percent_change = round((score - lag(score))/lag(score) * 100, 3)) |> 
  select(country, year, percent_change) |> 
  pivot_wider(names_from = year, values_from = percent_change)

# Sort the year columns based on their numeric values
sorted_country_columns <- colnames(perc_country)[order(as.numeric(colnames(perc_country)))]
# Reorder the columns in the dataframe
perc_country <- perc_country[, sorted_country_columns] |> 
  select(country, everything())

# Add percent symbols 
columns_format_country <- names(perc_country)[2:length(names(perc_country))]

perc_country[columns_format_country] <- lapply(perc_country[columns_format_country], function(x) {
  x[!is.na(x)] <- paste0(x[!is.na(x)], "%")
  x
})


