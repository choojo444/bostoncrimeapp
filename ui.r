# Define UI for app that draws a histogram ----
ui <- fluidPage(
  # App title ----
  titlePanel("Crime in Boston"),
  # Sidebar layout with input and output definitions ----
  
  tabsetPanel(
    tabPanel("Map", fluid = TRUE,
             
             fluidRow(
               #map with markers for each crime
               column(12,
                      leafletOutput("mymap"))
             ),
             fluidRow(
               #allow the user to chose the data
               column(2,
                      sliderInput(inputId = "year",
                                  label = "Year:",
                                  min = 2015,
                                  max = 2018,
                                  value = 2017)),
               column(2,
                      sliderInput(inputId = "month",
                                  label = "Month:",
                                  min = 1,
                                  max = 12,
                                  value = 4)),
               column(2,
                      sliderInput(inputId = "day",
                                  label = "Day:",
                                  min = 1,
                                  max = 31,
                                  value = 4)),
               column(2,actionButton("refresh", "Refresh")),
               column(4, textOutput("day_of_week"))
             ),
             fluidRow(
               column(12, 
                      p("The data analyze by this app is crime data collected in the city of Boston over the years of 2015-2018. For each crime the data set includes a description of the offense, District, date and time, latitude and longitude, and street. This page shows a map of Boston with the crimes plotted. You can select the day and the crimes reported on that day will show up with descriptions. Initially all of the crimes will display in one color, but once the clustering calculations are done you can click refresh on this page and the crime markers will be colored based on the cluster it is in.")
               )
               )
             ),  
    
    tabPanel("Barplot", fluid = TRUE,
             #display various bar charts the user can chose from to get a sense of the data
             sidebarLayout(
               selectInput("group_by", "Group By:",
                           c("Month" = "m",
                             "Hour of Day" = "h",
                             "Day of the Week" = "dw",
                             "Day of the Year" = "dy",
                             "District" = "ds",
                             "Crime Type" = "ct")),
               mainPanel(fluidRow(
                 column(10,     plotOutput(outputId = "distPlot"))
               ),
               fluidRow(
                 column(10, 
                        p("This page allows you to select a variable to view a bar plot, to get a general idea of some of the data trends. For example the bar chart by month shows that crime tends to be higher in the summer months.")
                 )
               )
               
               )
             )
    ),
    tabPanel("Cluster", fluid = TRUE,
             #display the culster plot and allow the user to select number of clusters and
             #which vars to cluster on
             fluidRow(
               column(10,     plotOutput(outputId = "clusPlot"))
             ),
             fluidRow(
               column(2, checkboxInput("locc", "Location", TRUE)),
               column(2, checkboxInput("hourc", "Hour", FALSE)),
               column(2, checkboxInput("dayyc", "Day of the Year", FALSE)),
               column(2, checkboxInput("daywc", "Day of the Week", FALSE)),
               column(2, checkboxInput("ctc", "Crime Type", FALSE))
             ),
             fluidRow(
               column(10,  sliderInput("num_cl", "Number of Clusters:", min = 2, max = 50, value = 19, sep='')   )
             ),
             fluidRow(
               column(12, 
                      strong("Note: Please wait until this page has finished loaing before switching to another plot")
               )
             ),
             fluidRow(
               column(12, 
                      p("This page allows you to select variables and the number of clusters to run the clustering algorithm. It will look for groups of similar crimes within the dataset. For the clustering to work properly there needs to be at least two variable selected, with the exception of location, which already has two components (longitude and latitude). The clustering algorithm may take a few minutes to run. Once the clustering plot appears the clustering should be finished. You can then return to the map tab, click refresh, and the crime markers on the map with be colored based on their cluster.")
               )
             ),
             fluidRow(
               column(12, 
                      p("The clustering algorithm used here is called kmeans clustering. It calculates the clusters iteratively by first selecting some random points to be the center of each cluster, then assigning each data-point to one of the clusters based which center point it is closest too (or has the nearest mean). Once all the data points are assigned the centers are recalculated for each cluster. Then the points are re-assigned again. This continues until the clusters and center-points no longer change with each iteration. At that point we can say the clusters have converged and the most similar points should be grouped together in Clusters. ")
               )
             ),
             fluidRow(
               column(12, 
                      p("The plot that displays on this page shows the general result of this clustering. If there are only two variables it plots normalized versions of those variables with circles around the clusters. If the clustering is multi-dimensional it will identify the principal components that affected the clustering and will plot based on those. For a more geographic view of the clusters you can view the clusters by color on the map page.")
               )
             )
    ),
    tabPanel("SSE", fluid = TRUE,
             fluidRow(
               selectInput("sse_sel", "Clusted By:",
                           c("All Vars" = "av",
                             "Location" = "loc",
                             "Loc and Day of the Year" = "d",
                             "Loc and Day of the Week" = "dw",
                             "Loc and Hour" = "h",
                             "Loc and Offense" = "o")),
               column(10,    ggvisOutput("p"))
         ),
         fluidRow(
           column(12, 
                  p("The plots on this page show a graph of Sum of Squared Errors, plotted against the number of clusters. Sum of Squared Errors is the sum of distance to the nearest cluster, squared for each point. A high SSE shows that the clusters These plots can help to select the right number of clusters to use for various variable combinations. The ideal number of clusters will have a low SSE, and usually be after a sharper drop in SSE from one number to another. The plots have been calculated ahead of time because running the K means clustering algorithm multiple times would take too much time. You can select a combination of variables to see the plot for those variables.")
           )
         )
    ),
    tabPanel("About", fluid = TRUE,
             fluidRow(
               column(12, 
                      strong("What data you collected?")
               )
             ),
             fluidRow(
               column(12, 
                      p("The data I collected was from a data set on Kaggle called Crimes in Boston (link below). The data is of incidents reported to the Boston Police department that they responded to. For each incident the data set includes the time and date, exact location, crime description, District, street, as well as the incident number and whether the crime involved a shooting.")
               )
             ),
             fluidRow(
               column(12, 
                      p("https://www.kaggle.com/AnalyzeBoston/crimes-in-boston")
               )
             ),
             fluidRow(
               column(12, 
                      strong("Why this topic is interesting or important to you?")
               )
             ),
             fluidRow(
               column(12, 
                      p("I had some trouble finding a large enough data set that was interesting to me, but because I live near Boston I found this set to be related to the life of a city where I have friends and family. I also like looking at trends on maps so seeing events like this on a map of a place I know was appealing.")
               )
             ),
             fluidRow(
               column(12, 
                      strong("How did you analyze the data?")
               )
             ),
             fluidRow(
               column(12, 
                      p("I started with some fairly basic ways to view the data. The first tab on this app allows the user to select a date and see all the crimes reported on that date marked on a map of Boston. The next tab allows the user to see a variable of their choice in bar-graph form. The Cluster tab is where the more intense analysis happens. That tab allows the user to select variables as well as the number of clusters to calculate, then runs K-means clustering on those variables. The algorithm is explained in more detail on that page. The user can then refresh the maps page and see the crimes colored by their cluster. The last tab shows the SSE plots to help the user select the number of clusters when running k-means")
               )
             ),
             fluidRow(
               column(12, 
                      strong("What did you find in the data?")
               )),
             fluidRow(
               column(12, 
                      p("The bar-plots showed some interesting trend. Crime was high during the day and some of the night, but as it got later crime dropped sharply from 2 am to 7am. ")
               )
             ),fluidRow(
               column(12, 
                      plotOutput(outputId = "barPlot1")
                  )
             ),
             fluidRow(
               column(12, 
                      p("Crime was also significantly lower on Sundays than other days of the week.")
               )
             ),fluidRow(
               column(12, 
                      plotOutput(outputId = "barPlot2")
               )
             ),
             fluidRow(
               column(12, 
                      p("The Crime map also showed some interesting trends. There Southern Boston tended to have low-crime areas, whereas the area to the north around Cambridge Street tended to have a lot of crime most days. There was also a spot, separated from the rest of the crime map to the North west that had a cluster of crimes.")
               )
             ),fluidRow(
               column(12, 
                      img(src='crime_map_2016.png', align = "left"),
               )
             ),
             fluidRow(
               column(12, 
                      p("When Clustering was run on location only it showed a pretty similar pattern to the map with clusters in all parts of the city. Based on the SSE plots 5 is a reasonable choice for the cluster")
               )
             ),fluidRow(
               column(12, 
                      img(src='crime_location_clus.png', align = "left"),
               )
             ),
             fluidRow(
               column(12, 
                      p("When viewed on the map it shows the crime has been clustered it to 5 neat groups.")
               )
             ),fluidRow(
               column(12, 
                      img(src='crime_location_clus_map.png', align = "left"),
               )
             ),
             
             
             fluidRow(
               column(12, 
                      p("Clustering on all variables does not show very clear clusters with all of the data very close together.")
               )
             ),fluidRow(
               column(12, 
                      img(src='crime_all_clus.png', align = "left"),
               )
             ),
             fluidRow(
               column(12, 
                      p("Clustering on all variables does not show very clear clusters with all of the data very close together.")
               )
             ),fluidRow(
               column(12, 
                      img(src='crime_oh_clus.png', align = "left"),
               )
             ),
             fluidRow(
               column(12, 
                      p("Since the map only shows one day at a time this combination of variables makes the most sense to view on the map:")
               )
             ),fluidRow(
               column(12, 
                      img(src='cluster_map.png', align = "left"),
               )
             ),
             fluidRow(
               column(12, 
                      p("Overall Clustering cannot be used for prediction, but for understanding the crime data better. One way analysis like this could be useful would be police allocation. If there's a better understanding of types of crimes police could be allocation based on clusters of certain types of crimes in certain locations and times. Possibly as new crimes are reported the cluster they would belong to could be used to decide which response team to send, with certain police officers assigned to a specific cluster each day based on their location and training.")
               )
             )
    )
  )
)
