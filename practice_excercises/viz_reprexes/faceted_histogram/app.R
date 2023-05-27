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

# the above is already within the app^^^^
# copy and paste the following

# remove NA years 
data_ordered <- MPS_tracker_data |>
  filter(visualization_include == "yes") |> 
  arrange(year)

# define the UI here: ----
ui <- fluidPage(
  titlePanel("Histogram Visualization"),
  sidebarLayout(
    sidebarPanel(
      selectInput("country_select", "Select Country:", choices = unique(MPS_tracker_data$country)),
      selectInput("year_select", "Select Year:", choices = c("All", as.character(unique(data_ordered$year))))
    ),
    mainPanel(
      plotOutput("histogram_plot")
    )
  )
)

# define the server here: ----
server <- function(input, output) {
  
  output$histogram_plot <- renderPlot({
    selected_country <- input$country_select
    selected_year <- input$year_select

    if (selected_year == "All") {
      filtered_data <- MPS_tracker_data %>%
        filter(country == selected_country) %>%
        select(country, score) %>%
        na.omit()
      
      mean_data <- filtered_data %>%
        group_by(country) %>%
        summarise(mean_score = mean(score))
    } else {
      filtered_data <- MPS_tracker_data %>%
        filter(country == selected_country, year == as.integer(selected_year)) %>%
        select(country, score) %>%
        na.omit()
      
      mean_data <- filtered_data %>%
        group_by(country) %>%
        summarise(mean_score = mean(score))
    }
  
  
  facet_hist <- ggplot(filtered_data, aes(x = score, fill = country)) + 
    geom_histogram(aes(y = ..density..), 
                   binwidth = 1, bins = 5) + 
    geom_vline(data = mean_data, aes(xintercept = mean_score), color = "red",alpha = 0.7) +
    geom_text(data = mean_data, aes(x = mean_score, y = 0.5, label = paste0("Mean Score: ", round(mean_score, 2))),
              color = "black", vjust = 0.5, hjust = -0.5) +
    scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
    scale_y_continuous(limits = c(0,0.6)) +
    theme_bw() + 
    theme(legend.position = "none") + 
    scale_fill_brewer(palette = "Set2")
  
  print(facet_hist)
  
  })
  
  
}


# Run the application ----
shinyApp(ui = ui, server = server)