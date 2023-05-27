library(shiny) 
library(shinydashboard) 

# Dashboard Page ----
dashboardPage(
  
  # set title of webpage
  title = "Marine Protection Data Visualization Tool",
  
  # # Dashboard Theme/Skin ----
  skin = "black",
  # Dashboard Header ----  
  dashboardHeader(title = span(
        tags$img(src = "logo.png", height = "30px"),
        "WildAid Marine MPS Tracker Data Explorer", # main site title
        style = "color: #094074; font-size: 28px; font-family: 'Impact'"),
                  titleWidth = 400, # how big you want the title
                  tags$li(class = "dropdown", 
                          tags$a(href = "https://marine.wildaid.org/", 
                                 icon("fish"), # here I just put a fish icon for the wildaid marine website 
                                 "WildAid Marine")), 
                  tags$li(class = "dropdown", 
                          tags$a(href = "https://github.com/iMPAct-capstone/WildAid_visualization", 
                                 icon("github-alt"), # github link 
                                 "Github"))
  ), # end dashboard header
  
  # Dashboard Sidebar ----
  
  # dashboard sidebar ----------------------
  sidebar <- dashboardSidebar(
    collapsed = TRUE, sidebarMenuOutput("sidebar")
  ), # END Dashboard sidebar
  
  
  # Dashboard Body ----
  dashboardBody(
    
    #LOGIN STUFF
    div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
    # add login panel UI function
    shinyauthr::loginUI(id = "login"),
    # setup table output to show user info after login
    tableOutput("user_table"),
    
    # link stylesheet
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    ),
    
    # tabItems ----
    tabItems(
      
      # Welcome tab ----
      tabItem(tabName = "welcome", 
              #tab box 
              tabBox(id = "tab_box1", width = 12, 
                     # tab panels
                     tabPanel(title = "About", icon = icon("address-card"),
                              fluidRow(
                                  column(6,
                                    tags$h2(style = "font-size: 24px;",
                                            "Our Mission"),  
                                    tags$p(style = "font-size: 16px;",
                                           includeMarkdown("text/mission.md")),
                                    h2(style = "font-size: 24px;",
                                       "About this App"),
                                    p(style = "font-size: 16px;",
                                       includeMarkdown("text/about_app.md"))
                                    ), # end column
                                  column(6,
                                    tags$img(src = "collage.png", 
                                             style = "max-width: 100%;")
                                    ) # end column
                     ) # end fluid row
                     ), # end tab panel
                     tabPanel(title = "Site Map", icon = icon("map"), leafletOutput(outputId = "MPA_map")))
      ), # end welcome tab
      
      # Data tab ----
      tabItem(tabName = "data", 
              #tab box 
              tabBox(id = "tab_box2", width = 12, 
                     # tab panels
                     tabPanel(title = "About", icon = icon("address-card"),
                              fluidRow(
                                column(6,
                                      tags$h2(style = "font-size: 24px;",
                                      "Our Data"),
                                      p(style = "font-size: 16px;",
                                      includeMarkdown("text/about_data.md"))),
                                column(6,
                                       tags$img(src = "categories.png",
                                                style = "max-width: 100%;"))
                              ) # end fluid row
                              ), # end tab panel
                     # explore all the data here 
                     tabPanel(title = "Explore Data", icon = icon("magnifying-glass"),
                              tags$h4("Scroll through all of our enforcement data and use the filters above each column to subset the data to what you would like to see. Note: to see all of the notes in the comments section, hover the mouse over the text."),
                              DTOutput("dt_table")),
                     # summary tables here 
                     tabPanel(title = "Summary Table (Site-level)", icon = icon("table"), DTOutput("summary_table_site")), 
                    tabPanel(title = "Summary Table (Country-level)", icon = icon("table"), DTOutput("summary_table_country"))) 
    
  ),
      # end data tab
      
      # Visualization tab ----
      tabItem(tabName = "visualizations",
              # tab box
              tabBox(id = "tab_box3", width = 12, 
                     # tab panels NOTE: there's an additional argument "value" that could be useful... look later
                     
                     
                     tabPanel(title = "Compare category scores between MPA sites", icon = icon("square-poll-horizontal"),
                              tags$h3("Select year and up to four sites accross which you would like to compare category scores."),
                              tags$p("NOTE: If there is no output for what you selected, the data for the site and year you have selected does not exist. (See error below when this happens.)"),
                              sidebarLayout(
                                sidebarPanel(width = 3,
                                  selectInput("year_selection", 
                                              label = h3("Select year"), 
                                              choices = unique(MPS_tracker_data$year), # having trouble making this appear in order
                                              selected = c(2022),
                                              selectize = FALSE), # is this necessary?? don't think so let's try later
                                  selectInput("site_1", 
                                              label = h3("Select site 1"), 
                                              choices = unique(MPS_tracker_data$site), # having trouble making this appear in order
                                              selected = c("Reserva Ecológica Manglares Churute"),
                                              selectize = FALSE),
                                  selectInput("site_2",
                                              label = h3("Select site 2"), 
                                              choices = unique(MPS_tracker_data$site), # having trouble making this appear in order
                                              selected = c("Galapagos Marine Reserve"),
                                              selectize = FALSE),
                                  selectInput("site_3",
                                              label = h3("Select site 3"), 
                                              choices = unique(MPS_tracker_data$site), # having trouble making this appear in order
                                              selected = c("Parque Nacional Machalilla"),
                                              selectize = FALSE),
                                  selectInput("site_4",
                                              label = h3("Select site 4"), 
                                              choices = unique(MPS_tracker_data$site), # having trouble making this appear in order
                                              selected = c("Refugio de Vida Silvestre Manglares El Morro"),
                                              selectize = FALSE)
                                ),
                                
                                # Show a plot of the generated distribution
                                mainPanel(
                                  plotOutput("lolliPlot", width = 800, height = 600)
                                )
                              )
                     ),
                     
                     tabPanel(title = "Category scores over time", icon = icon("chart-line"), 
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
                                  plotOutput("linegraph"))
                                )
                              ),
                     tabPanel(title = "Compare Score by Country", icon = icon("earth"),
                              br(),
                              h2("Distributions of scores for the countries that WildAid Marine works with"),
                              p("Here are the density historgrams depicting the current scores at each of the countries where WildAid helps facilitate their marine protection enforcement. The vertical line shows the mean score across the entire country."),
                              br(),
                              br(),
                              mainPanel(
                                plotOutput("facet_hist", height = 500, width = 900))
                     ))
      ) # end viz tab
      
    ) # end Tab ItemSSS 
  ) # end Dashboard body
) # end Dashboard Page


  