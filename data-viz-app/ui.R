#........................dashboardHeader.........................
header <- dashboardHeader(

  # add title ----
  title = "WildAid Marine MPS Tracker Data Explorer",
  titleWidth = 400

) # END dashboardHeader

#........................dashboardSidebar........................
sidebar <- dashboardSidebar(

  # sidebarMenu ----
  sidebarMenu(

    menuItem(text = "Welcome", tabName = "welcome", icon = icon("star")),
    menuItem(text = "Dashboard", tabName = "dashboard", icon = icon("gauge"))

  ) # END sidebarMenu

) # END dashboardSidebar

#..........................dashboardBody.........................
body <- dashboardBody(

  # tabItems ----
  tabItems(

    # welcome tabItem ----
    tabItem(tabName = "Welcome",

            # left-hand column ----
            column(width = 6,

                   # background info box ----
                   box(width = NULL,

                       "background info here"

                   ), # END background info box

            ), # END left-hand column

            # right-hand column ----
            column(width = 6,

                   # first fluidRow ----
                   fluidRow(

                     # data source box ----
                     box(width = NULL,

                         "data citation here"

                     ) # END data source box

                   ), # END first fluidRow

                   # second fluiRow ----
                   fluidRow(

                     # disclaimer box ----
                     box(width = NULL,

                         "disclaimer here"

                     ) # END disclaimer box

                   ) # END second fluidRow

            ) # END right-hand column

    ), # END welcome tabItem

    # dashboard tabItem ----
    tabItem(tabName = "Dashboard",

            # fluidRow ----
            fluidRow(

              # input box ----
              box(width = 4,

                  "sliderInputs here"

              ), # END input box

              # leaflet box ----
              box(width = 8,

                  "leaflet output here"

              ) # END leaflet box

            ) # END fluidRow

    ) # END dashboard tabItem

  ) # END tabItems

) # END dashboardBody

#..................combine all in dashboardPage..................
dashboardPage(header, sidebar, body)
