
data(soil_example)
data(weather_station_example)
data(practices_example)
data(weather_example)
plant <- plant_parameters()

model_options <- list(
  soil = list(sit1 = soil_example),
  weather_station = list(sit1 = weather_station_example),
  practices = list(sit1 = practices_example),
  weather = list(sit1 = weather_example),
  plant = list(sit1 = plant)
)

res <- CroptimizR::test_wrapper(
  miniSTICS_wrapper,
  model_options,
  param_values = c(stlevamf = 275, rue = 3.5),
  situation = "sit1"
)

test_that("miniSTICS Wrapper succeed test_wrapper tests", {
  print(res$test_results)
  expect_true(all(res$test_results))
})
