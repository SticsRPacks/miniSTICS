reference <- miniSTICS(
  soil = soil_example,
  weather_station = weather_station_example,
  practices = practices_example,
  plant = plant_parameters(),
  weather = weather_example
)

dir.create("tests/testthat/fixtures", showWarnings = FALSE)

saveRDS(
  reference,
  "tests/testthat/fixtures/miniSTICS_example_reference.rds"
)

