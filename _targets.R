library(targets)
library(tarchetypes)
library(tidyverse)

source("functions.R")

# Set the number of cores for parallelization
future::plan(future::multisession, workers = 11)  # Adjust the number of workers as needed

# Get the file paths for the years specified
files <- list.files("data/", full.names = TRUE)
years_wanted <- c(2014:2024)
years_regex <- paste(paste0("(?<=_)", years_wanted), collapse = "|")

files_wanted <- files[str_detect( files, years_regex)]

list(
  tar_files(
    files,
    files_wanted
  ),
  
  tar_target(
    spo_sondes,
    process_o3sonde_100m_file(files),
    pattern = map(files)
  )
)