ref_file <- testthat::test_path(
  "fixtures",
  "miniSTICS_example_reference.rds"
)

testthat::skip_if_not(
  file.exists(ref_file),
  "Reference file not available."
)

reference <- readRDS(ref_file)

test_that("miniSTICS simulated variables are unchanged on example dataset", {

  data(soil_example)
  data(weather_station_example)
  data(practices_example)
  data(weather_example)

  plant <- plant_parameters()

  result <- miniSTICS(
    soil = soil_example,
    weather_station = weather_station_example,
    practices = practices_example,
    plant = plant,
    weather = weather_example
  )

  reference <- readRDS(
    testthat::test_path(
      "fixtures",
      "miniSTICS_example_reference.rds"
    )
  )

  # Check that reference variables still exist
  expect_true(
    all(names(reference) %in% names(result))
  )

  # Compare only variables stored in the reference
  expect_equal(
    result[names(reference)],
    reference,
    tolerance = 5e-5
  )
})
