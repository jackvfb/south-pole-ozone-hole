# Load required libraries
library(targets)
library(tarchetypes)
library(dplyr)

source("functions.R")

# Define the directory where your files are located
data_dir <- "test_data/"

# Define vertical extent of interest
min_alt <- 10
max_alt <- 22

# Values for tar_map
values <- expand.grid(
  neighbors = c(2, 5, 10),
  x_res = 1,
  y_res = c(0.1, 1)
)

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
  range(str_match(input_files, "(?<=_)\\d{4}"))
)

tm <- tar_map(
  values = values,
  names = "neighbors",
  tar_target(grid, generate_grid(x_res, y_res, min_alt, max_alt, years)),
  tar_target(trained_model, train_model(processed_data, neighbors)),
  tar_target(predictions, do_predictions(trained_model, grid))
)

results <- 
  tar_combine(
    images,
    tm[["predictions"]],
    command = bind_rows(!!!.x, .id = "id")
  )

list(t1, t2, t3, tm, results)