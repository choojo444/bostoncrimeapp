


server <- function(input, output, session) {
  #set global var to indicate whether clustering has run
  clust_glob_bol <<- FALSE
  #array of all possible colors for markers
  all_col <- c("red", "darkred", "lightred", "orange", "beige", "green", "darkgreen", "lightgreen", "blue", "darkblue", "lightblue", "purple", "darkpurple", "pink", "cadetblue", "white", "gray", "lightgray", "black")
  
  output$mymap <- renderLeaflet({
    #make sure map will refresh when button is clicked
    re <- input$refresh
    crData2 <- crData
    #if cluster has run add cluster column to array
    if(clust_glob_bol ){
      crData2$Cluster = clust_glob$Cluster
    }
    #filter by user selected date, map will crash with more data so can only display one day at a time
    crData_month_year <-crData2 %>% filter(  (YEAR == input$year) ) %>% filter( MONTH== input$month)  %>% filter( DAY== input$day ) 
    #if cluster has run set color by cluster
    if(clust_glob_bol ){
      clus_pres <- crData2 %>% group_by(Cluster) %>% summarise(N = n())
      colorx <- palette(rainbow(length(clus_pres$Cluster)))
      num_a <-clus_pres$Cluster
      crData_month_year$LAB = paste(crData_month_year$LAB, " Clus: ", crData_month_year$Cluster)
      
    }
    #set up get color function that colors by cluster
    getColor <- function(cd) {
      sapply(cd$Cluster, function(Cluster) {
        all_col[Cluster%%length(all_col)]
      })
    }
    #created icons
    icons <- awesomeIcons(
      icon = 'ios-close',
      iconColor = 'black',
      library = 'ion',
      if(!clust_glob_bol ){
        markerColor = 'red'
      } else {
        markerColor = getColor(crData_month_year)
      }
    )
    
    #create leaflet map with markers for each crime
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addAwesomeMarkers(lng=crData_month_year$Long, lat=crData_month_year$Lat, popup = crData_month_year$LAB, icon = icons)
  })
  
  #calculate and display day of the week from selecte date
  output$day_of_week <- renderText({ 
    crData_month_year <-crData %>% filter(  (YEAR == input$year) ) %>% filter( MONTH== input$month)  %>% filter( DAY== input$day )
    paste("Day of the Week ",crData_month_year$DAY_OF_WEEK[1])
  })
  
  output$distPlot <- renderPlot({
    #Create bar plot based on variable user selects
    labelx <- ""
    if(input$group_by == "m"){
      crData_month_count <- crData %>% filter(  (YEAR != 2015))%>% filter(  (YEAR != 2018))%>% group_by(MONTH) %>% summarise(N = n()) 
      crd = crData_month_count$MONTH
      labelx <- "Month"
    }else if(input$group_by == "dy"){
      crData_month_count <- crData %>% filter(  (YEAR != 2015))%>% filter(  (YEAR != 2018))%>% group_by(DAY_OF_YEAR) %>% summarise(N = n()) 
      crd = crData_month_count$DAY_OF_YEAR
      labelx <- "Day"
    }else if (input$group_by == "y"){
      crData_month_count <- crData %>% group_by(YEAR) %>% summarise(N = n())
      crd = crData_month_count$YEAR
      labelx <- "Year"
    }else if (input$group_by == "h"){
      crData_month_count <- crData %>% group_by(HOUR) %>% summarise(N = n())
      crd = crData_month_count$HOUR
      labelx <- "Hour"
    }else if (input$group_by == "dw"){
      crData_month_count <- crData %>% group_by(DAY_OF_WEEK) %>% summarise(N = n())
      crd = crData_month_count$DAY_OF_WEEK
      labelx <- "Day of the Week"
    }else if (input$group_by == "ds"){
      crData_month_count <- crData %>% group_by(DISTRICT) %>% summarise(N = n())
      crd = crData_month_count$DISTRICT
      labelx <- "District"
    }else if (input$group_by == "ct"){
      crData_month_count <- crData %>% group_by(OFF_GR) %>% summarise(N = n())
      crd = crData_month_count$OFF_GR
      labelx <- "Offense Type"
    }
    barplot(crData_month_count$N, names.arg =  crd, col = "#75AADB", border = "white", ylab = "Number of Crimes", xlab = labelx)
    
  })
  
  

  output$barPlot1 <- renderPlot({
    crData_month_count <- crData %>% group_by(HOUR) %>% summarise(N = n())
    crd = crData_month_count$HOUR
    labelx <- "Hour"
    barplot(crData_month_count$N, names.arg =  crd, col = "#75AADB", border = "white", ylab = "Number of Crimes", xlab = labelx)
     })
  
  output$barPlot2 <- renderPlot({
    crData_month_count <- crData %>% group_by(DAY_OF_WEEK) %>% summarise(N = n())
    crd = crData_month_count$DAY_OF_WEEK
    labelx <- "Day of the Week"
    barplot(crData_month_count$N, names.arg =  crd, col = "#75AADB", border = "white", ylab = "Number of Crimes", xlab = labelx)
  })
  output$clusPlot <- renderPlot({
    #create data fram with only the first column
    crData_loc_id = crData %>% select(1)
    
    num<-0
    #normalized lat and long and add to df if selected
    if(input$locc){
      crData_loc_id$Lat = (crData$Lat-min(crData$Lat))/max(crData$Lat) 
      crData_loc_id$Long = (crData$Long-min(crData$Long))/max(crData$Long)
      num=num+2
    }
    #normalized hour and add to df if selected
    if(input$hourc){
      crData_loc_id$HOUR = (crData$HOUR-min(crData$HOUR))/max(crData$HOUR)
      num=num+1
    }
    #normalized day and add to df if selected
    if(input$dayyc){
      crData_loc_id$DAY_OF_YEAR = (crData$DAY_OF_YEAR-min(crData$DAY_OF_YEAR))/max(crData$DAY_OF_YEAR)
      num=num+1
    }
    #normalized day of the week and add to df if selected
    if(input$daywc){
      crData_loc_id$DAY_OF_WEEK = (crData$DAY_OF_WEEK_NUM-min(crData$DAY_OF_WEEK_NUM))/max(crData$DAY_OF_WEEK_NUM)
      num=num+1
    }
    #normalized crime type and add to df if selected
    if(input$ctc){
      crData_loc_id$OFF_NUM = (crData$OFF_NUM-min(crData$OFF_NUM))/max(crData$OFF_NUM)
      num=num+1
    }
    #if nothing is selected default to location
  
      #crData_loc_id$Lat = (crData$Lat-min(crData$Lat))/max(crData$Lat) 
      #crData_loc_id$Long = (crData$Long-min(crData$Long))/max(crData$Long)
      #input$locc = TRUE
      validate(
        need(num>=2,
             'Plese select at least two inputs, or location')
      )
    #remove the incident id column
    crData_loc <- crData_loc_id %>% subset( select = -c(1))
    
    #run the clustering algorithem
    karray = kmeans(crData_loc, centers=1)
    clusters = kmeans(crData_loc, input$num_cl)
    crData_loc_id$Cluster = clusters$cluster
    #set global var to allow the other function to access clusters
    clust_glob <<- crData_loc_id
    clust_glob_bol <<- TRUE
    
    
    clusplot(crData_loc, clusters$cluster, color=T, shade=F,labels=0,lines=0, main='k-Means Cluster Analysis')
    paste("Day of the Week ")
  })
    
    plot1 = reactive({
      sel1=2;
      sel2= 3;
      if(input$sse_sel == "av"){
        sel1 = 2;
        sel2 =3;
      }else  if(input$sse_sel == "loc"){
        sel1 = 10;
        sel2 =11;       
      }else  if(input$sse_sel == "h"){
        sel1 = 8;
        sel2 =9;  
      }else  if(input$sse_sel == "d"){
        sel1 = 4;
        sel2 =5;  
      }else  if(input$sse_sel == "dw"){
        sel1 = 6;
        sel2 =7;  
      }else  if(input$sse_sel == "o"){
        sel1 = 12;
        sel2 =13;  
      }
      sse <- sse_a %>% select(1, sel1, sel2)
      names(sse)[2] = 'Clusters'
      names(sse)[3] = 'SSE'
      sse_plot <- sse %>%
        ggvis(~Clusters, ~SSE) %>% 
        layer_points(fill := 'blue') %>% 
        layer_lines() %>%
        set_options(height = 300, width = 400) 
    })
    
    plot1 %>%
      bind_shiny("p", "p_ui")
}