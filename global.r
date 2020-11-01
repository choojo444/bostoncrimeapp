library(shiny)
library(leaflet)
library(plotly)
library(lubridate)
library(plyr)
library(dplyr)
library(cluster)
library(ggvis)
#file for the full dataset
crime_file = 'crime.csv'
#because there were a lot of crime catagories I split them into Violent, Non-violent, Auto, 
#Emergency Response, and theft and saved a key for those codes below
crime_code_file = 'crimes_codes.csv'

crime_codes <- read.csv(crime_code_file)

crData <- read.csv(crime_file,header=TRUE)

sse_a <- read.csv('all_vars.csv')
#added a column for day of the month
crData$DAY <- as.numeric(format(as.Date(crData$OCCURRED_ON_DATE,format="%Y-%m-%d"), format = "%d"))

#remove any points without a valid location
crData <- crData %>%subset( grepl('^\\d', Lat))

#extracting day of the year and day of the week from date field
s_1 <- as.Date(crData$OCCURRED_ON_DATE ,format='%Y-%m-%d')
crData$DAY_OF_YEAR <- lubridate::yday(s_1)
crData$DAY_OF_WEEK_NUM <- wday(s_1)

#Added a column for text that will go on map popups
crData$LAB = paste(crData$OFFENSE_DESCRIPTION," hour: ",crData$HOUR)

#Added a column with my new crime code and another with my description
crData$OFF_NUM <- as.numeric(mapvalues(crData$OFFENSE_CODE_GROUP, from = crime_codes$OFFENSE_CODE_GROUP, to = crime_codes$NUM))

crData$OFF_GR <- mapvalues(crData$OFFENSE_CODE_GROUP, from = crime_codes$OFFENSE_CODE_GROUP, to = crime_codes$Gen_Type)

