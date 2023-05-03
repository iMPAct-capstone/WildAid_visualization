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
library(lubridate)
library(scales)

# THE GOAL OF THIS INTERACTIVE PLOT (NOT INTERACTIVE YET) WILL BE TO VISUALIZE SCORING METRICS AT A GIVEN SITE OVER TIME 

# THE USER WILL BE ABLE TO FILTER FOR THE SITE THEY WANT... POTENTIALLY DIFFERENT SITES 
# AND ALSO FILTER FOR THE SCORING CATEGORY THEY WOULD LIKE TO SEE 

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# LEAVE THIS ALONE... MUST BE CONSISTENT... MAKE CHANGES IN REACTIVE DATAFRAME
# get our MPS tracker data MAKE SURE THIS IS CONSISTENT IN GLOBAL.R FILE IN APP
MPS_tracker_data <- read_sheet(url) |> 
  mutate(year = as.factor(year),  # the year is getting super funky with decimals eww!
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type)

# define the UI here: ----
ui <- fluidPage(
  # title text 
  tags$h2("Visualize category scores changing over time"),
  
  # paragraph text 
  tags$p("Please select a site and a scoring metric category. If the plot is blank, this means there is no combination of your selections present in the data at this time. Some sites from previous years may have been renamed or new sites have been created so certain sites may not have enough data points for this plot to be relevant."),
  br(),
  br(),
  # add a side bar
  sidebarLayout(
    # add stuff to the sidebar 
    sidebarPanel(
      # add an input widget for site
      selectInput(inputId = "site_select", label = h4("Select site"), 
                  choices = unique(MPS_tracker_data$site), 
                  selected = c("Pemba Channel Conservation Area"),
                  selectize = FALSE),
      # another one for category
      selectInput(inputId = "category_select", label = h4("Select scoring category"), 
                  choices = unique(MPS_tracker_data$category), 
                  selected = "Fishing Sector Collaboration", 
                  selectize = FALSE)
    ),
    
    # if you have a sidebar panel, you also need a main panel (within sidebar layout function)
    mainPanel(
      plotOutput("linegraph")
    )
  )
)

# define the server here: ----
server <- function(input, output) {
  
  # define the reactive dataframe here with reactive ({})
  line_dat <- reactive({
    
    # insert message to select site and score (this is not working right now)
    # validate(
    #   need(length(input$site_select) > 0, "Please select a site"),
    #   need(length(input$sub_category_select) > 0, "Please select a scoring category")
    # )
    # 
    MPS_tracker_data |> 
      group_by(category, site, year) |> 
      summarise(score = round(mean(score, na.rm = TRUE), 2)) |> 
      filter(site %in% c(input$site_select), # will add user interactivity here 
             category %in% c(input$category_select))  # and here ... think about how to add multiple at once?? might get gnarly
      
  })
  
  # define the output plot 
  output$linegraph <- renderPlot({
    ggplot(data = line_dat(), 
           mapping = aes(x = year, y = score, group = 1)) +  # find out what this group argument is?
      geom_line(color = "#0099f9", size = 2) + 
      geom_point(color = "#0099f9", size = 5) + 
      geom_label(aes(label = score),
                 nudge_x = 0,
                 nudge_y = 0.2) +
      theme_bw() +
      theme(axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            plot.title = element_text(size = 16)) +
      scale_y_continuous(limits = c(1, 5), breaks = c(1,2,3,4,5)) +
      #  scale_x_continuous(limits = c(min(MPS_tracker_data$year), max(MPS_tracker_data$year))) +
      # the above line won't work with year being of class factor but I can't get it to work nicely
      labs(title = paste0(input$category_select," at ", input$site_select, " protected site"))
  })
}


# Run the application ----
shinyApp(ui = ui, server = server)