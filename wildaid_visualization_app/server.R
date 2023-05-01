function(input, output, session) {
  
  # DT datatable ----
  output$dt_table <- DT::renderDataTable(
    DT::datatable(data = select(MPS_tracker_data, -visualization_include), # take out a column
                  rownames = FALSE,
                  escape=TRUE, # don't understand what this does could be important
                  caption = "Here is a filter-able compilation of all of our data", 
                  filter = 'top',
                  options = list(
                    pageLength = 10, autoWidth = TRUE,
                    columnDefs = list(list(targets = 5, width = '80px'), 
                                      list(targets = 6, width = '400px'), 
                                      list(targets = 3, width = '10px')), # play with column widths
                    scrollX = TRUE
                  )))
  #browser()
  
  # DT summary datatable ----
  output$summary_table <- DT::renderDataTable(
    DT::datatable(
      summary_table_cat <- MPS_tracker_data %>%
        group_by(year, site, category) %>%
        summarize(mean_score = round(mean(score), 1)) %>%
        pivot_wider(names_from = category,
                    values_from = c(mean_score),
                    names_sep = " "), #finding mean of scores and displaying with categories as header
                  rownames = FALSE,
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
  
}