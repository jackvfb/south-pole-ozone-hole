library(tidyverse)
library(tidymodels)

process_files <- function(file_path, min_alt, max_alt) {
  
  col_names = c("level", "press", "alt", "pottp", "temp", "ftempv", "hum", "ozone", "ozone_ppmv", "ozone_atmcm", "ptemp", "o3_density", "o3_du", "o3_uncert")
  na_vals <- c("999.9", "999", "99.90", "99.999", "99.9990", "999.999", "9999", "99999.000", "99999")
  
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
  date <- as_date(str_extract(file_path, "(?<=_)\\d{4}_\\d{2}_\\d{2}"))
  data <- tibble(data, date = date)
  
  # Mask altitudes
  data %>% 
    filter(alt <= max_alt,
           alt >= min_alt)
  
  
}

generate_grid <- function(x_res, y_res, min_alt, max_alt, years) {
  expand.grid(alt = seq(min_alt, max_alt, by = y_res),
              jdate = seq(1, 366, by = x_res),
              year = min(years):max(years)
  )
}
  
fit_model <- function(sonde_data){
  # Prepare training data
  sonde <- sonde_data %>%
    # Drop observations with no response recorded
    drop_na(ozone_ppmv) %>% 
    # Drop repeat observations
    distinct(date, alt, .keep_all = TRUE) %>% 
    # Arrange chronologically for split_initial_time() in next step
    arrange(date) %>% 
    # Add features
    mutate(year = year(date),
           jdate = yday(date))
  
  sonde_split <- initial_time_split(sonde)
  
  # Define KNN model
  knn_spec <- nearest_neighbor(
    weight_func = "optimal",
    neighbors = tune()) %>%
    set_mode("regression") %>%
    set_engine("kknn")

  sonde_recipe <- recipe(ozone_ppmv ~ year + jdate + alt, data = sonde) %>% 
    step_normalize(all_predictors())
  
  knn_wf <- workflow() %>%
    add_model(knn_spec) %>%
    add_recipe(sonde_recipe)
  
  knn_grid <- grid_regular(
    neighbors(range = c(1, 5)),
    levels = 5
  )
  
  sonde_folds <- vfold_cv(training(sonde_split), v = 5)
  
  knn_tuning <- tune_grid(
    knn_wf,
    resamples = sonde_folds,
    grid = knn_grid
  )
  
  best_knn <- select_best(knn_tuning, metric = "rmse")
  
  knn_wf <- finalize_workflow(knn_wf, best_knn)
  
  knn_fit <- knn_wf %>%
    fit(sonde)
  
  return(knn_fit)
}

do_predictions <- function(fitted_model, grid) {
  
  
  # Perform predictions
  predictions <- predict(fitted_model, grid)
  
  # Attach predictions to grid
  grid$ozone_ppmv <- predictions$.pred
  
  return(grid)
}

create_year_plot <- function(results, ozone_scale, year) {
  year_data <- results %>%
    filter(year == {{year}})
  
  plot <- ggplot(year_data,
                 aes(x = jdate, y = alt, fill = ozone_ppmv + 0.01)) +
    geom_tile() +
    ozone_scale +
    labs(title = paste("Ozone Concentration in", year),
         x = "Day of Year",
         y = "Altitude (km)") +
    theme_minimal()
  
  return(plot)
}

define_ozone_scale <- function(){
  scale_fill_gradientn(
    colors = c("purple", "blue", "cyan", "green", "yellow", "orange", "red"),
    breaks = c(0.01, 0.1, 1.0, 5.0),
    labels = c(0.01, 0.1, 1.0, 5.0),
    limits = c(0.01, 8),
    trans = "log",
    name = "ozone (ppm)"
  )
}
