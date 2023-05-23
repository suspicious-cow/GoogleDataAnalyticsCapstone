# set a seed in case we use any random items
set.seed(1337)


# Set the names of the packages and libraries you want to install
required_libraries <- c("tidyverse", "purrr", "knitr", "skimr", "readr")

# Install missing packages and load all required libraries
for (lib in required_libraries) {
  if (!requireNamespace(lib, quietly = TRUE)) {
    install.packages(lib)
  }
  library(lib, character.only = TRUE)
}

# load all the cycling data for analysis
# our data runs from 04/2022 to 04/2023
if(file.exists("combined_data_df.rds") && !exists("combined_data_df")) {
    # read in our combined data
    combined_data_df <- readRDS("combined_data_df.rds")
    
} else if(!exists("combined_data_df")){
    
    # get file list
    file_list <- list.files(path = "SourceData/", pattern = "*.csv", full.names = TRUE)
    
    # read and combine files
    combined_data_df <- map_df(file_list, read_csv)
    
    # convert ridable_type and member_casual into factors
    combined_data_df$rideable_type <- as.factor(combined_data_df$rideable_type)
    combined_data_df$member_casual <- as.factor(combined_data_df$member_casual)
    
    # save the combined_data object so we don't have to reload this data again
    # unless it changes
    write_rds(combined_data_df, "combined_data_df.rds")
}

# =====================================================

# examine the structure of the data
str(combined_data_df)

# Check for missing values
colSums(is.na(combined_data_df))

# Print detailed summary statistics of the dataframe
skim(combined_data_df)


# Identify duplicates
duplicates <- duplicated(combined_data_df)

# Count duplicates
num_duplicates <- sum(duplicates)

# Show the number of duplicates
print(num_duplicates)


# ======================================================

# calculate the total ride time in minutes for each group
combined_data_df$ride_length <- 
    round((combined_data_df$ended_at - combined_data_df$started_at) / 60, 2)

# Change the units attribute to "minutes"
attr(combined_data_df$ride_length, "units") <- "minutes"


# Add a new column for the date without the time
combined_data_df$started_date <- as.Date(combined_data_df$started_at)


# Create the 'day_of_week_start' and 'day_of_week_end' columns
combined_data_df$day_of_week_start <- wday(combined_data_df$started_at, label = TRUE)
combined_data_df$day_of_week_end <- wday(combined_data_df$ended_at, label = TRUE)

# Convert the new columns to factors
combined_data_df$day_of_week_start <- as.factor(combined_data_df$day_of_week_start)
combined_data_df$day_of_week_end <- as.factor(combined_data_df$day_of_week_end)


# Get rid of outliers by only accepting ride times that are less than two days 
# and greater than zero
combined_data_df <- combined_data_df %>% filter(ride_length <= 2880 & 
                                                    ride_length > 5) 


# split our data into two groups: member and casual
member_df <- combined_data_df %>% filter(member_casual == "member") 
casual_df <- combined_data_df %>% filter(member_casual == "casual") 

# ride_length metrics for both groups
ride_length_mean_member <- mean(as.numeric(member_df$ride_length))
ride_length_max_member <- max(as.numeric(member_df$ride_length))
ride_length_min_member <- min(as.numeric(member_df$ride_length))

ride_length_mean_casual <- mean(as.numeric(casual_df$ride_length))
ride_length_max_casual <- max(as.numeric(casual_df$ride_length))
ride_length_min_casual <- min(as.numeric(casual_df$ride_length))

# Create a data frame
ride_length_metrics <- data.frame(
    Metric = c("Mean", "Max", "Min"),
    Member = round(c(ride_length_mean_member, ride_length_max_member, ride_length_min_member), 2),
    Casual = round(c(ride_length_mean_casual, ride_length_max_casual, ride_length_min_casual), 2)
)

# Print the data frame
print(ride_length_metrics)









# Group by date and count the number of rides each day per group
daily_counts_member <- member_df %>% group_by(started_date) %>% summarise(count = n())
daily_counts_casual <- casual_df %>% group_by(started_date) %>% summarise(count = n())


# super line graph for members
ggplot(daily_counts_member, aes(x = started_date, y = count)) +
    geom_line(color = "darkblue") +
    geom_smooth(method = "loess", se = FALSE, color = "red", linetype="dashed") +
    labs(x = "Date", 
         y = "Number of Rentals", 
         title = "Daily Bike Rentals for Members", 
         subtitle = "With trend line",
         caption = "Source: https://divvybikes.com/system-data") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 20),
          plot.subtitle = element_text(face = "italic", size = 12),
          axis.title = element_text(face = "bold", size = 14),
          axis.text = element_text(size = 12))

# super line graph for casual
ggplot(daily_counts_casual, aes(x = started_date, y = count)) +
    geom_line(color = "darkblue") +
    geom_smooth(method = "loess", se = FALSE, color = "red", linetype="dashed") +
    labs(x = "Date", 
         y = "Number of Rentals", 
         title = "Daily Bike Rentals for Casual", 
         subtitle = "With trend line",
         caption = "Source: https://divvybikes.com/system-data") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 20),
          plot.subtitle = element_text(face = "italic", size = 12),
          axis.title = element_text(face = "bold", size = 14),
          axis.text = element_text(size = 12))


# =======================================================================

library(ggplot2)

# Calculate the counts
member_counts <- member_df %>% group_by(rideable_type) %>% summarise(count = n())
casual_counts <- casual_df %>% group_by(rideable_type) %>% summarise(count = n())

# Combine the data into one dataframe
bike_pref_df <- rbind(
    mutate(member_counts, user_type = "Member"),
    mutate(casual_counts, user_type = "Casual")
)

# Plot
ggplot(bike_pref_df, aes(x = rideable_type, y = count, fill = user_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_text(aes(label=count), vjust=-0.3, position = position_dodge(0.9)) +
    labs(x = "Bike Type", y = "Count", fill = "User Type", title = "Bike Type Preference by User Type") +
    theme_minimal()


