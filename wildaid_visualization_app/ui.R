library(shiny) 
library(shinydashboard) 

# Dashboard Page ----
dashboardPage(
  
  # Dashboard Header ----  
  dashboardHeader(title = "WildAid Marine MPS Tracker Data Explorer", # main site title
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
  dashboardSidebar(
    
    # Sidebar Menu ----
    sidebarMenu(
      id = "sidebar", 
      
      # Menu Items
      menuItem(text = "Welcome", tabName = "welcome", icon = icon("hand-peace")), 
      menuItem(text = "Data", tabName = "data", icon = icon("table")), 
      menuItem(text = "Visualizations", tabName = "visualizations", icon = icon("chart-simple"))
      
    ) # end Sidebar menu(items)
  ), # end sidebar
  
  # Dashboard Body ----
  dashboardBody(
    tabItems(
      
      # Welcome tab ----
      tabItem(tabName = "welcome", 
              #tab box 
              tabBox(id = "tab_box1", width = 12, 
                     # tab panels
                     tabPanel(title = "About", icon = icon("address-card"), h4("(h4) tabpanel placeholder")),
                     tabPanel(title = "Map", icon = icon("map"), leafletOutput(outputId = "MPA_map")))
      ), # end welcome tab
      
      # Data tab ----
      tabItem(tabName = "data", 
              #tab box 
              tabBox(id = "tab_box2", width = 12, 
                     # tab panels
                     tabPanel(title = "Data About", icon = icon("bookmark"), h1("(h1) tabpanel placeholder")),
                     tabPanel(title = "Explore Data", icon = icon("magnifying-glass"), DTOutput("dt_table")),
                     tabPanel(title = "Summary Table", icon = icon("table"), DTOutput("summary_table"))) # NOTE: maybe add length on the 
      ), # end data tab
      
      # Visualization tab ----
      tabItem(tabName = "visualizations",
              # tab box
              tabBox(id = "tab_box3", width = 12, 
                     # tab panels NOTE: theres an additional argument "value" that could be useful... look later
                     
                     
                     tabPanel(title = "Compare category scores between MPA sites", icon = icon("question")
                     ),
                     
                     tabPanel(title = "Viz 2", icon = icon("question"), h4("(h4) tabpanel placeholder")),
                     tabPanel(title = "Viz 3", icon = icon("question"), h4("(h4) tabpanel placeholder")))
      ) # end viz tab
      
    ) # end Tab ItemSSS 
  ) # end Dashboard body
) # end Dashboard Page
