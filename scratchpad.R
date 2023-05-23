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

# examine the structure of the data
str(combined_data_df)

# Now you can inspect problems
readr::problems(combined_data_df)

# Print summary statistics of the dataframe
summary(combined_data_df)

# Print detailed summary statistics of the dataframe
skim(combined_data_df)

# Check for missing values
colSums(is.na(combined_data_df))






