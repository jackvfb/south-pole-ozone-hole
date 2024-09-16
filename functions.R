library(tidyverse)

process_o3sonde_100m_file <- function(file_path) {
  
  col_names = c("level", "press", "alt", "pottp", "temp", "ftempv", "hum", "ozone", "ozone_ppmv", "ozone_atmcm", "ptemp", "o3_density", "o3_du", "o3_uncert")
  na_vals <- c("999.9", "999", "99.90", "99.999", "99.9990", "999.999", "9999", "99999.000", "99999")
  
  # Read the numerical data
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
}

