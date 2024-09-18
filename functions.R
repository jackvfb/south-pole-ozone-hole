library(tidyverse)
library(tidymodels)

process_files <- function(file_path, min_alt, max_alt) {
  
  col_names = c("level", "press", "alt", "pottp", "temp", "ftempv", "hum", "ozone", "ozone_ppmv", "ozone_atmcm", "ptemp", "o3_density", "o3_du", "o3_uncert")
  na_vals <- c("999.9", "999", "99.90", "99.999", "99.9990", "999.999", "9999", "99999.000", "99999")
  
  # Read the numerical data
  data <- read_table(
    file_path, 
    skip = 29,
    na = na_vals,
    col_names = col_names,
    col_types = cols(
      level = col_double(),
      press = col_double(),
      alt = col_double(),
      pottp = col_double(),
      temp = col_double(),
      ftempv = col_double(),
      hum = col_double(),
      ozone = col_double(),
      ozone_ppmv = col_double(),
      ozone_atmcm = col_double(),
      ptemp = col_double(),
      o3_density = col_double(),
      o3_du = col_double(),
      o3_uncert = col_double()
    )
  )
  
  # Add metadata
  date <- str_extract(file_path, "(?<=_)\\d{4}_\\d{2}_\\d{2}")
  data <- tibble(data, date = as_date(date))
  
  data %>% 
    filter(alt <= max_alt,
           alt >= min_alt)
}

generate_grid <- function(x_res, y_res, min_alt, max_alt, years) {
  expand.grid(alt = seq(min_alt, max_alt, by = y_res),
              jdate = seq(1, 366, by = x_res),
              year = seq(years[[1]], years[[2]], by = 1)
  )
}

train_model <- function(sonde_data, k=5){
  # Prepare training data
  tr <- sonde_data %>%
    mutate(year = year(date),
           jdate = yday(date)) %>%
    drop_na(ozone_ppmv) %>%
    distinct(date, alt, .keep_all = TRUE) %>%
    select(year, jdate, alt, ozone_ppmv)
  
  # Define and fit KNN model
  knn_reg_spec <- nearest_neighbor(neighbors = k) %>%
    set_mode("regression") %>%
    set_engine("kknn")
  
  knn_reg_fit <- knn_reg_spec %>% fit(ozone_ppmv ~ ., data = tr)
  
  return(knn_reg_fit)
}

do_predictions <- function(ozone_model, grid) {
  # Perform predictions
  predictions <- predict(ozone_model, grid)
  
  # Attach predictions to grid
  grid$ozone_ppmv <- predictions$.pred
  
  return(grid)
}