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
  # start copy paste
  fluidRow(
    column(6,
           selectInput("hist_country_select1", "Select Country:", choices = unique(data_ordered$country)),
           selectInput("hist_year_select1", "Select Year:", choices = c("All", as.character(unique(data_ordered$year)))),
           plotOutput("histogram_plot1")
), # end first quadrant
    column(6,
           selectInput("hist_country_select2", "Select Country:", choices = unique(data_ordered$country)),
           selectInput("hist_year_select2", "Select Year:", choices = c("All", as.character(unique(data_ordered$year)))),
           plotOutput("histogram_plot2")
    ) # end second quadrant
  ), # end fluid row 1
  
  fluidRow(
    column(6,
           selectInput("hist_country_select3", "Select Country:", choices = unique(data_ordered$country)),
           selectInput("hist_year_select3", "Select Year:", choices = c("All", as.character(unique(data_ordered$year)))),
           plotOutput("histogram_plot3")),
    column(6,
           selectInput("hist_country_select4", "Select Country:", choices = unique(data_ordered$country)),
           selectInput("hist_year_select4", "Select Year:", choices = c("All", as.character(unique(data_ordered$year)))),
           plotOutput("histogram_plot4"))
    ) # end copy paste
  )




# define the server here: ----
server <- function(input, output) {
  
  output$histogram_plot1 <- renderPlot({
    selected_country1 <- input$hist_country_select1
    selected_year1 <- input$hist_year_select1

    if (selected_year1 == "All") {
      filtered_data <- MPS_tracker_data %>%
        filter(country == selected_country1) %>%
        select(country, score) %>%
        na.omit()
      
      mean_data <- filtered_data %>%
        group_by(country) %>%
        summarise(mean_score = mean(score))
    } else {
      filtered_data <- MPS_tracker_data %>%
        filter(country == selected_country1, year == as.integer(selected_year1)) %>%
        select(country, score) %>%
        na.omit()
      
      mean_data <- filtered_data %>%
        group_by(country) %>%
        summarise(mean_score = mean(score))
    }
    
    facet_hist <- ggplot(filtered_data, aes(x = score)) + 
      geom_histogram(aes(y = ..density..), fill = "#00A6A6", color = "black",
                     binwidth = 1, bins = 5) + 
      geom_vline(data = mean_data, aes(xintercept = mean_score), color = "red",alpha = 0.7) +
      geom_text(data = mean_data, aes(x = mean_score, y = 0.5, label = paste0("Mean Score: ", round(mean_score, 2))),
                color = "black", vjust = 0.5, hjust = -0.5) +
      scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
      scale_y_continuous(limits = c(0,0.6)) +
      theme_bw() + 
      theme(legend.position = "none") 
    
    print(facet_hist)
    
    })
    
    output$histogram_plot2 <- renderPlot({
      selected_country2 <- input$hist_country_select2
      selected_year2 <- input$hist_year_select2
      
      if (selected_year2 == "All") {
        filtered_data <- MPS_tracker_data %>%
          filter(country == selected_country2) %>%
          select(country, score) %>%
          na.omit()
        
        mean_data <- filtered_data %>%
          group_by(country) %>%
          summarise(mean_score = mean(score))
      } else {
        filtered_data <- MPS_tracker_data %>%
          filter(country == selected_country2, year == as.integer(selected_year2)) %>%
          select(country, score) %>%
          na.omit()
        
        mean_data <- filtered_data %>%
          group_by(country) %>%
          summarise(mean_score = mean(score))
      }
    
  
  facet_hist <- ggplot(filtered_data, aes(x = score)) + 
    geom_histogram(aes(y = ..density..), fill = "#F79256", color = "black",
                   binwidth = 1, bins = 5) + 
    geom_vline(data = mean_data, aes(xintercept = mean_score), color = "red",alpha = 0.7) +
    geom_text(data = mean_data, aes(x = mean_score, y = 0.5, label = paste0("Mean Score: ", round(mean_score, 2))),
              color = "black", vjust = 0.5, hjust = -0.5) +
    scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
    scale_y_continuous(limits = c(0,0.6)) +
    theme_bw() + 
    theme(legend.position = "none") 
  
  print(facet_hist)
  
    }) 
    
    
    output$histogram_plot3 <- renderPlot({
      selected_country3 <- input$hist_country_select3
      selected_year3 <- input$hist_year_select3
      
      if (selected_year3 == "All") {
        filtered_data <- MPS_tracker_data %>%
          filter(country == selected_country3) %>%
          select(country, score) %>%
          na.omit()
        
        mean_data <- filtered_data %>%
          group_by(country) %>%
          summarise(mean_score = mean(score))
      } else {
        filtered_data <- MPS_tracker_data %>%
          filter(country == selected_country3, year == as.integer(selected_year3)) %>%
          select(country, score) %>%
          na.omit()
        
        mean_data <- filtered_data %>%
          group_by(country) %>%
          summarise(mean_score = mean(score))
      }
      
      facet_hist <- ggplot(filtered_data, aes(x = score)) + 
        geom_histogram(aes(y = ..density..), fill = "#7FB069", color = "black", 
                       binwidth = 1, bins = 5) + 
        geom_vline(data = mean_data, aes(xintercept = mean_score), color = "red",alpha = 0.7) +
        geom_text(data = mean_data, aes(x = mean_score, y = 0.5, label = paste0("Mean Score: ", round(mean_score, 2))),
                  color = "black", vjust = 0.5, hjust = -0.5) +
        scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
        scale_y_continuous(limits = c(0,0.6)) +
        theme_bw() + 
        theme(legend.position = "none") 
      
      print(facet_hist)
      
    })
  
    output$histogram_plot4 <- renderPlot({
      selected_country4 <- input$hist_country_select4
      selected_year4 <- input$hist_year_select4
      
      if (selected_year4 == "All") {
        filtered_data <- MPS_tracker_data %>%
          filter(country == selected_country4) %>%
          select(country, score) %>%
          na.omit()
        
        mean_data <- filtered_data %>%
          group_by(country) %>%
          summarise(mean_score = mean(score))
      } else {
        filtered_data <- MPS_tracker_data %>%
          filter(country == selected_country4, year == as.integer(selected_year4)) %>%
          select(country, score) %>%
          na.omit()
        
        mean_data <- filtered_data %>%
          group_by(country) %>%
          summarise(mean_score = mean(score))
      }
      
      facet_hist <- ggplot(filtered_data, aes(x = score)) + 
        geom_histogram(aes(y = ..density..), fill = "#E88B84", color = "black",
                       binwidth = 1, bins = 5) + 
        geom_vline(data = mean_data, aes(xintercept = mean_score), color = "red",alpha = 0.7) +
        geom_text(data = mean_data, aes(x = mean_score, y = 0.5, label = paste0("Mean Score: ", round(mean_score, 2))),
                  color = "black", vjust = 0.5, hjust = -0.5) +
        scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
        scale_y_continuous(limits = c(0,0.6)) +
        theme_bw() + 
        theme(legend.position = "none") 
      
      print(facet_hist)
      
    })
}


# Run the application ----
shinyApp(ui = ui, server = server)