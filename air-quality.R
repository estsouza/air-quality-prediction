# Packages required
packages <- c("tidyverse", "purrr","httr", "jsonlite", "openair", "forecast", "timetk", "modeltime")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Get list of available locations at OpenAQ

base_url <- "https://api.openaq.org/v2/"
locations_url <- paste0(base_url, "locations")

locations <- list(
  santiago_chile = "-33.447487%2C-70.673676",
  tokio_japan = "35.652832%2C139.839478",
  berlin_germany = "13.404954%2C52.520008",
  bangkok_thailand = "13.668217%2C100.614021",
  newyork_unitedstates = "40.730610%2C-73.935242"
)

get_locations_per_coordinates <- function(coordinates) {
  # Fetch the locations data
  queryString <- list(
    limit = "100",
    page = "1",
    offset = "0",
    sort = "desc",
    coordinates = coordinates,
    radius = "10000",
    order_by = "lastUpdated",
    sensorType = "reference%20grade",
    dumpRaw = "false"
  )

  response <- VERB("GET", locations_url, query = queryString, content_type("application/octet-stream"), accept("application/json"))

  locations_data <- content(response, "text")
  locations_df <- fromJSON(locations_data, flatten = TRUE)$results
  locations_df
}

locations_df <- locations |> map(get_locations_per_coordinates)

# Filter locations with long historical records (e.g., at least 2000 data points)

### DISCONTINUED DUE TO SHORT AMOUNT OF DATA IN OPENAQ DATASET, DATING FROM SEPT 2022.
### COULD CHECK AGAIN IN THE FUTURE.
