function(input, output, session) {
  
  # LOGIN  ----
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init()),
    reload_on_logout = TRUE
  )
  
  # call the logout module with reactive trigger to hide/show
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  # this opens or closes the sidebar on login/logout
  observe({
    if (credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  # only when credentials()$user_auth is TRUE, render your desired sidebar menu
  output$sidebar <- renderMenu({
    req(credentials()$user_auth)
    
    # render menu if authorized
    sidebarMenu(
          id = "sidebar",

          # Menu Items
          menuItem(text = "Welcome", tabName = "welcome", icon = icon("hand-peace")),
          menuItem(text = "Data", tabName = "data", icon = icon("table")),
          menuItem(text = "Visualizations", tabName = "visualizations", icon = icon("chart-simple"))

        ) # end Sidebar menu(items)
       # end sidebar
  })
  
  # DT datatable ----
  output$dt_table <- DT::renderDataTable(
    DT::datatable(data = MPS_tracker_data |> 
                    filter(visualization_include == "yes") |> 
                    select(-visualization_include), # take out a column
                  rownames = FALSE,
                  selection = "none",
                  escape=TRUE, # don't understand what this does could be important
                  caption = "Here is a filter-able compilation of all of our data. Please scroll to the right to view comments and the site managers who entered each observation", 
                  filter = 'top', 
                  extensions = "Responsive",  
                  options = list(
                    responsive = TRUE,
                    pageLength = 10, 
                    autoWidth = TRUE,
                    scrollCollapse = TRUE,
                    scroller = TRUE,
                    columnDefs = list(list(targets = 5, width = '80px'), 
                                      list(targets = 6, width = '1000px'), 
                                      list(targets = 3, width = '1px')), # play with column widths
                    scrollX = TRUE
                  ) ) |> DT::formatStyle(columns = c(1, 2, 3, 4, 5, 6, 7, 8), fontSize = '70%')) 
  #browser()
  
  # DT summary datatable ----
  output$summary_table <- DT::renderDataTable(
    DT::datatable(
      summary_table_cat <- MPS_tracker_data %>%
        filter(visualization_include == "yes") %>%
        group_by(year, site, category) %>%
        summarize(mean_score = round(mean(score, na.rm = TRUE), 1)) %>%
        pivot_wider(names_from = category,
                    values_from = c(mean_score),
                    names_sep = " "), #finding mean of scores and displaying with categories as header
                  rownames = FALSE,
                  selection = "none",
                  escape=TRUE, # don't understand what this does could be important
                  caption = "Here is a summary table showing annual mean scores for each site.",
                  filter = 'top',
                  options = list(
                    pageLength = 10, autoWidth = TRUE,
                    scrollX = TRUE
                  )))
  
  # LEAFLET MAP  ----
  
  # Define your scoring scale and associated colors
  score_scale <- c(1, 2, 3, 4, 5, 6)  # Example scoring scale
  color_palette <- c("#00A6A6", "#7FB069", "#094074", "#F4D067", "#E88B84", "#E17000")
  status_word <- c("1: Discovery", "2: Partnership", "3: Enforcement design", "4: Implimentation", "5: Mentorship", "6: Regional Leadership")
  
  # make a little dataframe to join the colors to the number column 
  color_df <- data.frame(status_numb = score_scale, 
                         colors = color_palette, 
                         word = status_word)
  
  # left join to the status_numb column 
  sites_w_color <- left_join(map_data, color_df, by = "status_numb")
  
  # map output
  output$MPA_map <- renderLeaflet({
    leaflet(data = sites_w_color) %>%
      addProviderTiles(providers$Esri.WorldStreetMap,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addCircleMarkers(lng = ~longitude, 
                       lat = ~latitude,
                       radius = 10,
                       color = ~colors,
                       fillOpacity = 0.8,
                       popup = paste0("Site: ", sites_w_color$site, "<br>",
                                      "Country: ", sites_w_color$country, "<br>",
                                      "Partners: ", sites_w_color$partners, "<br>",
                                      "Site Manager(s): ", sites_w_color$p_ms, "<br>", 
                                      "Implementation Status: ", sites_w_color$status)) |> 
      addLegend(colors = color_palette,
                labels = status_word,
                position = "bottomright")
  })
  
  # LOLLIPOP PLOT ----
  
  # order the data by year
  data_ordered <- MPS_tracker_data |>
    filter(visualization_include == "yes") |> 
    arrange(year)
  
  # build reactive dataframe
  lollidat <- reactive({data_ordered |> 
      arrange(year) |> 
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
      geom_segment( aes(x=category, xend=category, y=1, yend=score), color="grey") +
      geom_point( aes(x=category, y=score, color=site), size=3 ) +
      coord_flip()+
      theme_ipsum() +
      theme(
        text = element_text(family = "Arial"),
        legend.position = "none",
        panel.border = element_blank(),
        panel.spacing = unit(0.1, "lines"),
        strip.text.x = element_text(size = 15,
                                    family = "Arial"), 
        axis.text.y = element_text(size = 15,
                                   family = "Arial"), 
        plot.title = element_text(size = 15,
                                  family = "Arial"),
        axis.title.x = element_text(hjust = 0.5,
                                    margin = margin(r = 50),
                                    size = 12,
                                    family = "Arial"),
        axis.title.y = element_text(hjust = 0.5,
                                    margin = margin(r = 30),
                                    size = 12,
                                    family = "Arial")
      ) +
      scale_y_continuous(limits = c(1, 5)) +
      xlab("Scoring Category") +
      ylab("Score") +
      facet_wrap(~site, ncol=1, scale="free_y")
  })
  
  
  
  # LINE GRAPH ----
  
  # define the reactive dataframe here with reactive ({})
  line_dat <- reactive({
    
    # insert message to select site and score (this is not working right now)
    # validate(
    #   need(length(input$site_select) > 0, "Please select a site"),
    #   need(length(input$sub_category_select) > 0, "Please select a scoring category")
    # )
    # 
    MPS_tracker_data |> 
      filter(visualization_include == "yes") |> 
      group_by(category, site, year) |> 
      summarise(score = round(mean(score, na.rm = TRUE), 2)) |> 
      filter(site %in% c(input$site_select), # could add multiple in future here
             category %in% c(input$category_select))  # could add multiple in future here
    
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
  
  # FACETED HISTOGRAM SCORE BY COUNTRY GRAPH
  output$facet_hist <- renderPlot({
    MPS_tracker_data |> 
    select(country, score) |> 
    na.omit() |> 
    ggplot(aes(x = score, fill = country)) + 
    geom_histogram(aes(y = ..density..), 
                   binwidth = 1, bins = 5) + 
    geom_vline(data = mean_data, aes(xintercept = mean_score), color = "black",alpha = 0.3) +
    facet_wrap(~country, ncol = 3, scales = 'free') + 
    scale_x_continuous(breaks = c(1,2,3,4,5), limits = c(0,6)) +
    scale_y_continuous(limits = c(0,0.6)) +
    theme_bw() + 
    theme(legend.position = "none",
          axis.title.x = element_text(size = 14, hjust = 0.5),
          axis.title.y = element_text(size = 14, hjust = 0.5,
                                      margin = margin(r = 20))) + 
    scale_fill_brewer(palette = "Set2") +
    labs(title = "Score Density by Country") 
    
  })
}