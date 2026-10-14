test_that("run_doe returns the same values as miniSTICS for selected dates and variables", {
  # Load the example data used by miniSTICS.
  data("soil_example", package = "miniSTICS", envir = environment())
  data("weather_station_example", package = "miniSTICS", envir = environment())
  data("practices_example", package = "miniSTICS", envir = environment())
  data("weather_example", package = "miniSTICS", envir = environment())

  plant <- plant_parameters()

  # Use a parameter documented in the run_doe examples.
  expect_true("jvc" %in% names(plant))

  doe <- data.frame(
    jvc = c(35, 45, 55)
  )

  # Use dates actually present in the baseline simulation, so the test
  # does not depend on a hard-coded simulation calendar.
  baseline <- miniSTICS(
    soil = soil_example,
    weather_station = weather_station_example,
    practices = practices_example,
    plant = plant,
    weather = weather_example
  )

  variables <- c("LAI", "MASEC")
  expect_true(all(variables %in% names(baseline)))
  expect_true("Date" %in% names(baseline))
  expect_gt(nrow(baseline), 0L)

  available_dates <- unique(baseline$Date)
  selected_dates <- available_dates[
    unique(round(seq(1, length(available_dates), length.out = min(3, length(available_dates)))))
  ]

  # Avoid modifying the caller's future plan; sequential execution also
  # keeps this test fast and predictable.
  old_plan <- future::plan()
  on.exit(future::plan(old_plan), add = TRUE)
  future::plan(future::sequential)

  observed <- run_doe(
    doe = doe,
    soil = soil_example,
    weather_station = weather_station_example,
    practices = practices_example,
    plant = plant,
    weather = weather_example,
    var = variables,
    dates = selected_dates
  )

  # Build the expected output by running miniSTICS directly for each DoE row.
  expected <- lapply(seq_len(nrow(doe)), function(i) {
    plant_i <- plant
    plant_i$jvc <- doe$jvc[i]

    sim <- miniSTICS(
      soil = soil_example,
      weather_station = weather_station_example,
      practices = practices_example,
      plant = plant_i,
      weather = weather_example
    )

    sim <- sim[sim$Date %in% selected_dates, c("Date", variables), drop = FALSE]
    sim$sim_id <- i
    sim[, c("sim_id", "Date", variables), drop = FALSE]
  })

  expected <- do.call(rbind, expected)
  rownames(expected) <- NULL

  # Compare values and ordering without depending on tibble/data.frame class.
  observed <- as.data.frame(observed)
  observed <- observed[, c("sim_id", "Date", variables), drop = FALSE]
  rownames(observed) <- NULL

  expect_equal(observed, as.data.frame(expected), tolerance = 1e-10)
})
