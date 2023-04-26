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
  mutate(year = as.factor(year),
         category = as.factor(category), 
         country = as.factor(country)) |> 
  select(-indicator_type) |> 
  arrange(year) # useful for user input readability to arrange the order by year

# Define UI for application 
ui <- fluidPage(

    # Application title
    tags$h2("Comparing Category-level Scores Across Sites"),
    
    # Application subtext (instructions)
    tags$p("Select year and up to four sites accross which you would like to compare category scores.  If there is no output for what you selected, the data for the site and year you have selected does not exist."), # p for new paragraph

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("year_selection", 
                        label = h3("Select year"), 
                        choices = MPS_tracker_data$year, # having trouble making this appear in order
                        selected = 2022), # is this necessary?? don't think so let's try later
            selectInput("site_1", 
                        label = h3("Select site 1"), 
                        choices = MPS_tracker_data$site, # having trouble making this appear in order
                        selected = "Reserva Ecológica Manglares Churute"),
            selectInput("site_2",
                        label = h3("Select site 2"), 
                        choices = MPS_tracker_data$site, # having trouble making this appear in order
                        selected = "Galapagos Marine Reserve"),
            selectInput("site_3",
                        label = h3("Select site 3"), 
                        choices = MPS_tracker_data$site, # having trouble making this appear in order
                        selected = "Parque Nacional Machalilla"),
            selectInput("site_4",
                        label = h3("Select site 4"), 
                        choices = MPS_tracker_data$site, # having trouble making this appear in order
                        selected = "Refugio de Vida Silvestre Manglares El Morro")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("lolliPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  lollidat <- reactive({MPS_tracker_data |> 
      filter(year %in% c(input$year_selection), # user picks year
             site %in% c(input$site_1, # user picks sites
                         input$site_2,
                         input$site_3,
                         input$site_4)) |> 
      group_by(category, site) |> 
      summarise(score = mean(score, na.rm = TRUE))
  })
    
  # make our grouped lollipop plot
  

    output$lolliPlot <- renderPlot({
      ggplot(lollidat()) +
        geom_segment( aes(x=category, xend=category, y=0, yend=score), color="grey") +
        geom_point( aes(x=category, y=score, color=site), size=3 ) +
        coord_flip()+
        theme_ipsum() +
        theme(
          legend.position = "none",
          panel.border = element_blank(),
          panel.spacing = unit(0.1, "lines"),
          strip.text.x = element_text(size = 8), 
          axis.text.y = element_text(size = 7), 
          plot.title = element_text(size = 12)
        ) +
        xlab("Scoring Category") +
        ylab("Score") +
        facet_wrap(~site, ncol=1, scale="free_y")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
