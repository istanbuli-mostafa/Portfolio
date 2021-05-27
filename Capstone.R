install.packages('tidyverse')
library('tidyverse')
library('readxl')

trip_data_04 <- X202004_divvy_tripdata

trip_data_04_adjusted <- mutate(trip_data_04, ride_length = as.POSIXct(ride_length, format="%H:%M:%S"))

View(trip_data_04_adjusted)

trip_data_04$ride_length <- difftime(trip_data_04$ended_at,trip_data_04$started_at)

View(trip_data_04)

April_2020 <- X202004_divvy_tripdata


## This analysis is for case study 1 from the Google Data Analytics Certificate (Cyclistic).
###The purpose of this script is to consolidate downloaded Cyclistic data into a single dataframe and then conduct simple analysis to help answer the key question: 
#* "In what ways do members and casual riders use Divvy bikes differently?"

install.packages('tidyverse')
install.packages('lubridate')
install.packages('ggplot')
library('tidyverse')
library('lubridate')  
library('ggplot2')


## Collect data

#All data sets were imported using the R import wizard, now we assign different names(
Apr_2020 <- X202004_divvy_tripdata
May_2020 <- X202005_divvy_tripdata
June_2020 <- X202006_divvy_tripdata
July_2020 <- X202007_divvy_tripdata
Aug_2020 <- X202008_divvy_tripdata
Sep_2020 <- X202009_divvy_tripdata
Oct_2020 <- X202010_divvy_tripdata
Nov_2020 <- X202011_divvy_tripdata
Dec_2020 <- X202012_divvy_tripdata
Jan_2021 <- X202101_divvy_tripdata
Feb_2021 <- X202102_divvy_tripdata
Mar_2021 <- X202103_divvy_tripdata
Apr_2021 <- X202104_divvy_tripdata
  
## Wrangle data and combine into a single file
# Check if all columns are named the same
colnames(Apr_2020)
colnames(May_2020)
colnames(June_2020)
colnames(July_2020)
colnames(Aug_2020)
colnames(Sep_2020)
colnames(Oct_2020)
colnames(Nov_2020)
colnames(Dec_2020)
colnames(Jan_2021)
colnames(Feb_2021)
colnames(Mar_2021)
colnames(Apr_2021)

str(Apr_2020)
str(Dec_2020)

# Check for data type (in this case everything was converted on excel before importing except for start_station_id and end_station_id)
# Convert start_station_id and end_station_id to data type 'character' so that tables can be combined all together.
Apr_2020 <- mutate(Apr_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
May_2020 <- mutate(May_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
June_2020 <- mutate(June_2020, start_station_id = as.character(start_station_id),
                    end_station_id = as.character(end_station_id))
July_2020 <- mutate(July_2020, start_station_id = as.character(start_station_id),
                    end_station_id = as.character(end_station_id))
Aug_2020 <- mutate(Aug_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Sep_2020 <- mutate(Sep_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Oct_2020 <- mutate(Oct_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Nov_2020 <- mutate(Nov_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Dec_2020 <- mutate(Dec_2020, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Jan_2021 <- mutate(Jan_2021, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Feb_2021 <- mutate(Feb_2021, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Mar_2021 <- mutate(Mar_2021, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))
Apr_2021 <- mutate(Apr_2021, start_station_id = as.character(start_station_id),
                   end_station_id = as.character(end_station_id))

# Combine all data into one data frame


all_trips <- bind_rows(Apr_2020, May_2020, June_2020, July_2020, Aug_2020, Sep_2020, 
                       Oct_2020, Nov_2020, Dec_2020, Jan_2021, Feb_2021, Mar_2021, Apr_2021)

# Remove unrequired columns
all_trips <- all_trips %>% 
  select(-c(start_lat, start_lng, end_lat, end_lng))

# CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
# Inspect the new table created

colnames(all_trips)
nrow(all_trips)
dim(all_trips)
head(all_trips)
str(all_trips)
summary(all_trips)

##The data can only be aggregated at the ride-level, which is too granular. We will want to add some additional columns of data -- such as day, month, year that provide additional opportunities to aggregate the data.
## This will allow us to aggregate ride data for each month, day, or year ... before completing these operations we could only aggregate at the ride level

all_trips$date <- as.Date(all_trips$started_at) #The default format is yyyy-mm-dd
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")

## Add a "ride_length" calculation to all_trips (in seconds)

all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

# Convert "ride_length" from Factor to numeric so we can run calculations on the data

is.factor(all_trips$ride_length)

all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))

is.numeric(all_trips$ride_length)





# Remove "bad" data
# The dataframe includes a few hundred entries when bikes were taken out of docks and checked for quality by Divvy or ride_length was negative
negative_ride_length <- all_trips %>% filter(ride_length < 0)

View(negative_ride_length)


# We will create a new version of the dataframe (v2) since data with negative values are being removed
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]

# Recheck for any negative values, none exist
negative_ride_length_v2 <- all_trips_v2 %>% filter(ride_length < 0)

View(negative_ride_length_v2)


#Conduct Descriptive analysis:
# Descriptive analysis on ride_length (all figures in seconds) 
summary(all_trips_v2$ride_length)

# Compare members and casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# See the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Notice that the days of the week are out of order. Let's fix that.
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Now, let's run the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# analyze ridership data by type and weekday
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)	

# Let's visualize the number of rides by rider type
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>%
  filter(member_casual != 'NA') %>%
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")

# Let's create a visualization for average duration
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>%
  filter(member_casual != 'NA') %>%
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")


#STEP 5: EXPORT SUMMARY FILE FOR FURTHER ANALYSIS

write.csv(all_trips_v2, 'C:\\Users\\Mostafa Istanbuli\\Desktop\\Data Analytics\\Google\\Course#8\\Case study #1\\Datasets\\Final set\\final set.csv', row.names=FALSE)

#Creating tables for average duration and number of rides per rider type
average_durationv1 <- all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>% 
  filter(member_casual != 'NA')

number_of_rides <- all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>%
  filter(member_casual != 'NA')

summary <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

#Exporting to CSV
write.csv(average_durationv1, 'C:\\Users\\Mostafa Istanbuli\\Desktop\\Data Analytics\\Google\\Course#8\\Case study #1\\Datasets\\Final set\\avg duration.csv', row.names=FALSE)
write.csv(number_of_rides, 'C:\\Users\\Mostafa Istanbuli\\Desktop\\Data Analytics\\Google\\Course#8\\Case study #1\\Datasets\\Final set\\rider type.csv', row.names=FALSE)
write.csv(summary, 'C:\\Users\\Mostafa Istanbuli\\Desktop\\Data Analytics\\Google\\Course#8\\Case study #1\\Datasets\\Final set\\summary.csv', row.names=FALSE)



)