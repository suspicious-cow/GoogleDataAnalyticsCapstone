# set a seed in case we use any random items
set.seed(1337)


# Set the names of the packages and libraries you want to install
required_libraries <- c("tidyverse", "purrr")

# Install missing packages and load all required libraries
for (lib in required_libraries) {
  if (!requireNamespace(lib, quietly = TRUE)) {
    install.packages(lib)
  }
  library(lib, character.only = TRUE)
}

# get file list
file_list <- list.files(path = "SourceData/", pattern = "*.csv", full.names = TRUE)

# read and combine files
combined_data <- map_df(file_list, read_csv)

# save the combined file
write_csv(combined_data, "2022-04_to_2023-04-divvy-tripdata.csv")

# save the combined_data object so we don't have to reload this data again
# unless it changes
write_rds(combined_data, "combined_data_df.rds")

str(combined_data)
colnames(combined_data)
