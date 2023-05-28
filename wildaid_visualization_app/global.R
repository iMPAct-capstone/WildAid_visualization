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

# order the data by year (for some plots)
data_ordered <- MPS_tracker_data |>
  filter(visualization_include == "yes") |>
  arrange(year)

# read in the map data ----
map_url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit?usp=sharing"

map_data <- read_sheet(map_url) |> 
  clean_names() |> 
  filter(active_site == "current") |> 
  separate(status, into = c("status_numb", "status_key"), sep = " - ", remove = FALSE) |> 
  mutate(status_numb = as.numeric(status_numb)) |> 
  mutate(latitude = as.numeric(latitude)) |> 
  mutate(longitude = as.numeric(longitude)) |> 
  filter(active_site == "current")

# mean_data for faceted histogram
mean_data <- MPS_tracker_data |> 
  select(country, score) |> 
  na.omit() |> 
  group_by(country) |> 
  summarise(mean_score = mean(score))

# PERCENT CHANGE TABLE SETUP ----
perc_chg_site <- MPS_tracker_data |> 
  filter(visualization_include == "yes") |> 
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
  filter(visualization_include == "yes") |> 
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


