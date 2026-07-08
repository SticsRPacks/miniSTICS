# Example weather dataset for miniSTICS

A daily weather dataset used to demonstrate and test the miniSTICS crop
model. This dataset can be used in examples, vignettes, and unit tests
to illustrate model usage.

## Usage

``` r
weather_example
```

## Format

A data frame with 11 variables and one row per day:

- Date:

  Date of observation (Date class or character convertible to Date)

- ANNEE:

  Year of observation

- DOY:

  Day of year (1–365/366)

- Temp_min:

  Minimum air temperature (°C)

- Temp_moy:

  Mean air temperature (°C)

- Temp_max:

  Maximum air temperature (°C)

- Radiation:

  Incoming global solar radiation (MJ m-2 day-1)

- Rain:

  Precipitation (mm)

- Wind:

  Wind speed (m s-1)

- Rel_Hum:

  Relative humidity (%)

- Photoperiod:

  Day length (hours)

## Source

Converted from `MiniSTICS_weather.csv` using package data preparation
workflow.

## Details

The dataset was derived from a CSV file (`MiniSTICS_weather.csv`) and
formatted for inclusion in the package using `usethis::use_data()`.

This dataset is intended for testing and demonstration purposes only. It
does not represent measured observational data and may be partially
simulated or adapted from external sources.

## Examples

``` r
data(weather_example)
head(weather_example)
#>        Date ANNEE DOY Temp_min Temp_moy Temp_max Radiation Rain Wind Rel_Hum
#> 1 1/01/2004  2004   1     -1.5     -0.6      0.4      0.21  0.0  2.5    96.3
#> 2 2/01/2004  2004   2     -6.4     -1.8     -0.2      1.79  0.0  3.5    99.2
#> 3 3/01/2004  2004   3    -10.8     -7.7     -3.5      1.33  0.0  1.1    99.5
#> 4 4/01/2004  2004   4     -6.6     -1.1      2.0      0.21  2.1  2.9   100.0
#> 5 5/01/2004  2004   5      1.8      2.2      2.7      0.04  5.8  2.4    98.4
#> 6 6/01/2004  2004   6      2.9      5.1      7.5      0.10  3.4  3.4    97.9
#>   Photoperiod
#> 1       7.859
#> 2       7.878
#> 3       7.898
#> 4       7.919
#> 5       7.942
#> 6       7.966

# Example usage with miniSTICS
# out <- miniSTICS(soil, weather_station, practices, plant, weather_example)
```
