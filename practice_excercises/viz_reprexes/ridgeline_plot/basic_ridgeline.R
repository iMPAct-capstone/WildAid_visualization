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
library(lubridate)
library(scales)
library(ggridges)
library(viridis)

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# LEAVE THIS ALONE... MUST BE CONSISTENT... MAKE CHANGES IN REACTIVE DATAFRAME
# get our MPS tracker data MAKE SURE THIS IS CONSISTENT IN GLOBAL.R FILE IN APP
MPS_tracker_data <- read_sheet(url) |> 
  mutate(year = as.factor(year),  # the year is getting super funky with decimals eww!
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type)

# add below to the app 

ridgeplot <- MPS_tracker_data |> 
  select(country, score) |> 
  na.omit() |> 
  ggplot(aes(x = score, y = country, fill = country)) +
  stat_binline(scale = 0.9, stat = "binline", bins = 5, binwidth = 1, 
                       draw_baseline = FALSE,
                       quantile_lines=TRUE,
                       quantiles = 2,
                       quantile_fun=function(x,...)mean(x)) +
  scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
  theme(panel.spacing = unit(1, "lines"),  # i forgot what this line does 
        legend.position = 'none', 
        axis.title.y = element_blank(), 
        axis.title.x = element_text(hjust = 0.5)) + 
  labs(title = "Score distributions by country")


ridgeplot

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
  scale_fill_brewer(palette = "Set2", alpha = 0.2)

facet_hist

# best options so far for color pallete
# brewer set 2
# ipsum

