# Packages required
packages <- c("tidyverse", "purrr","httr", "jsonlite", "openair", "forecast", "timetk", "modeltime")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

## EPA Air Quality Dataset
#    To register using the email address "myemail@example.com" create and request this link (Replace "myemail@example.com" in the example with your email address.):
#    https://aqs.epa.gov/data/api/signup?email=myemail@example.com

# get EPA credentials from config.R
source("config.R")

# EPA allow a maximum period of one year for the queries
# Let's define a couple of functions to gather data for 5 cities with air pollution issues
fetch_epa_data <- function(email, key, param, begin_date, end_date, state, county) {
  # browser()
  base_url <- "https://aqs.epa.gov/data/api/"
  data_url <- paste0(base_url, "dailyData/byCounty")
  # data_url <- paste0(base_url, "sampleData/byCounty")

  query_params <- list(
    email = email,
    key = key,
    param = param,
    bdate = begin_date,
    edate = end_date,
    state = state,
    county = county
  )

  response <- GET(data_url, query = query_params)
  data <- content(response, "text", encoding = "UTF-8")
  header <- fromJSON(data, flatten = TRUE)$Header
  print(header)
  df <- fromJSON(data, flatten = TRUE)$Data

  return(df)
}


param <- "88101" # PM2.5 (you can choose other parameters, see documentation)
# param <- "42101" # Sulfur dioxide
# param <- "42602" # Nitrogen dioxide
begin_date <- "20200101"
end_date <- "20201231"
state <- "36" # New York (you can choose other states, see documentation)
county <- "061" # New York (you can choose other counties, see documentation)

# state <- "06" # California
# county <- "075" # San Francisco

# Fetch the air quality data
epa_data <- fetch_epa_data(email, api_key, param, begin_date, end_date, state, county)


### DATA HAS A DELAY OF APROX 6 MONTHS FOR UPDATES IN THIS DATASET
### PAUSING THE PROJECT
