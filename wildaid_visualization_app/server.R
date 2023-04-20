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
                                      "Implimentation Status: ", sites_w_color$status)) |> 
      addLegend(colors = color_palette,
                labels = status_word,
                position = "bottomright")
  })
  
  
  
  
  
}