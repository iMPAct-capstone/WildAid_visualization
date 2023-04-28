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

# THE GOAL OF THIS INTERACTIVE PLOT (NOT INTERACTIVE YET) WILL BE TO VISUALIZE SCORING METRICS AT A GIVEN SITE OVER TIME 

# THE USER WILL BE ABLE TO FILTER FOR THE SITE THEY WANT... POTENTIALLY DIFFERENT SITES 
# AND ALSO FILTER FOR THE SCORING CATEGORY THEY WOULD LIKE TO SEE 

url <- "https://docs.google.com/spreadsheets/d/1cUz4WZ1CRHFicuVUt82kJ_mL9Ur861Dn1c0BYu3NmRY/edit#gid=0"

# get our MPS tracker data
MPS_tracker_data <- read_sheet(url) |> 
  mutate(year = as.factor(year),  # make sure changing these to factor doesn't harm any graphs
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type)

# define the UI here: ----
ui <- fluidPage(
  # title text 
  tags$h2("Visualize scores changing over time"),
  # paragraph text 
  tags$p("select a site and a scoring metric"),
  # add a side bar
  sidebarLayout(
    # add stuff to the sidebar 
    sidebarPanel(
      # add an input widget 
      selectInput(inputId = "site_select", label = h4("Select site"), choices = MPS_tracker_data$site)
      
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
    MPS_tracker_data |> 
    filter(site %in% c(input$site_select), # will add user interactivity here 
           sub_category == "Funding") |>  # and here ... think about how to add multiple at once??
    na.omit() 
  })
  
  # define the output plot 
  output$linegraph <- renderPlot({
    ggplot(data = line_dat(), 
         mapping = aes(x = year, y = score, group = 1)) +  # find out what this group argument is?
    geom_line() + 
    geom_point() + 
    labs(title = "Funding at Galapagos protected site") # change this name ? may be overkill complexity for now 
  })
}


# Run the application ----
shinyApp(ui = ui, server = server)