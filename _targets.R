# Load required libraries
library(targets)
library(tarchetypes)
library(dplyr)

source("functions.R")

# Define the directory where your files are located
data_dir <- "data/"

# Define vertical extent of interest
min_alt <- 4
max_alt <- 26

#Define x and y resolution in image
x_res <- 1 # in units of days
y_res <- 0.1 # in units of km

# --- BEGIN PIPELINE
t1 <-   tar_files(
    name = input_files,
    command = list.files(data_dir, full.names = TRUE)
  )

t2 <-   tar_target(
    name = processed_data,
    command = process_files(input_files,
                            min_alt = min_alt,
                            max_alt = max_alt),
    pattern = map(input_files)
  )

t3 <- tar_target(
  years,
  unique(str_extract(input_files, "(?<=_)\\d{4}"))
)

t4 <- tar_target(
  grid,
  generate_grid(x_res, y_res, min_alt, max_alt, years)
  )

t5 <- tar_target(
  fitted_model,
  fit_model(processed_data)
  )

t6 <- tar_target(
  results,
  do_predictions(fitted_model, grid)
)

t7 <- tar_target(
  ozone_scale,
  define_ozone_scale()
)

t8 <- tar_target(
  year_plot,
  create_year_plot(results, ozone_scale, year = years),
  pattern = map(years),
  iteration = "list"
)

list(t1, t2, t3, t4, t5, t6, t7, t8)