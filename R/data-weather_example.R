#' Example weather dataset for miniSTICS
#'
#' A daily weather dataset used to demonstrate and test the
#' miniSTICS crop model. This dataset can be used in examples,
#' vignettes, and unit tests to illustrate model usage.
#'
#' The dataset was derived from a CSV file (`MiniSTICS_weather.csv`)
#' and formatted for inclusion in the package using `usethis::use_data()`.
#'
#' @format A data frame with 11 variables and one row per day:
#' \describe{
#'   \item{Date}{Date of observation (Date class or character convertible to Date)}
#'   \item{ANNEE}{Year of observation}
#'   \item{DOY}{Day of year (1–365/366)}
#'
#'   \item{Temp_min}{Minimum air temperature (°C)}
#'   \item{Temp_moy}{Mean air temperature (°C)}
#'   \item{Temp_max}{Maximum air temperature (°C)}
#'
#'   \item{Radiation}{Incoming global solar radiation (MJ m-2 day-1)}
#'   \item{Rain}{Precipitation (mm)}
#'   \item{Wind}{Wind speed (m s-1)}
#'   \item{Rel_Hum}{Relative humidity (%)}
#'   \item{Photoperiod}{Day length (hours)}
#' }
#'
#' @details
#' This dataset is intended for testing and demonstration purposes only.
#' It does not represent measured observational data and may be partially
#' simulated or adapted from external sources.
#'
#' @source Converted from `MiniSTICS_weather.csv` using package data preparation workflow.
#'
#' @examples
#' data(weather_example)
#' head(weather_example)
#'
#' # Example usage with miniSTICS
#' # out <- miniSTICS(soil, weather_station, practices, plant, weather_example)
"weather_example"
