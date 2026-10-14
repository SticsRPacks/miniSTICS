#' @title Run miniSTICS simulations from a Design of Experiments
#'
#' @description
#' Run multiple miniSTICS simulations for a single crop situation,
#' using parameter values defined by a Design of Experiments (DoE).
#' Each row of the DoE corresponds to one simulation.
#'
#' @param doe A data frame defining the experimental design. Each row
#'   represents one simulation, and each column contains the values of
#'   a model parameter to vary. Column names must match parameter names
#'   in `soil`, `weather_station`, `practices` or `plant`.
#' @param soil A list of soil parameters for the crop situation.
#' @param weather_station A list of weather station parameters.
#' @param practices A list of crop management parameters.
#' @param plant A list of plant parameters.
#' @param weather A data frame containing the weather data for the
#'   crop situation.
#' @param var Optional character vector of simulated variable names
#'   to retain. The `Date` column is always retained. If `NULL`,
#'   all simulated variables are returned.
#' @param dates Optional vector of dates to retain. Values must be
#'   comparable to the `Date` column returned by `miniSTICS()`.
#'   If `NULL`, all simulated dates are returned.
#' @param future.scheduling Number of futures per worker to use when
#'   scheduling simulations. Defaults to `1`. See
#'   [future.apply::future_lapply()] for details.
#'
#' @return A data frame containing the simulation results in long
#'   temporal format. Each row corresponds to one simulation and one
#'   date. The `sim_id` column identifies the row of `doe` associated
#'   with each simulation. The remaining columns contain `Date` and
#'   the simulated variables. The parameter values from `doe` are not
#'   included in the output.
#'
#' @details
#' Parallel execution is controlled by the future framework. Configure
#' the execution strategy before calling this function, for example with
#' `future::plan(future::multisession, workers = 4)`.
#'
#' Parameters not present in the DoE remain unchanged across simulations.
#' If a parameter name occurs in more than one input list, its value is
#' updated in every matching list.
#'
#' Variables and dates are filtered within each simulation before
#' results are returned to the main R process.
#'
#' @examples
#' \dontrun{
#' future::plan(future::multisession, workers = 4)
#'
#' data(soil_example)
#' data(weather_station_example)
#' data(practices_example)
#' data(weather_example)
#'
#' doe <- data.frame(
#'   jvc = c(35, 50, 65),
#'   temin = c(-1, 0, 1)
#' )
#'
#' results <- run_doe(
#'   doe = doe,
#'   soil = soil_example,
#'   weather_station = weather_station_example,
#'   practices = practices_example,
#'   plant = plant_parameters(),
#'   weather = weather_example,
#'   var = c("LAI", "MASEC"),
#'   dates = as.Date(c("2009-06-30", "2009-08-22"))
#' )
#'
#' # Results for the first simulation
#' subset(results, sim_id == 1)
#' }
#'
#' @importFrom future.apply future_lapply
#' @export
run_doe <- function(doe,
                    soil,
                    weather_station,
                    practices,
                    plant,
                    weather,
                    var = NULL,
                    dates = NULL,
                    future.scheduling = 1) {

  # Validate the experimental design
  if (!is.data.frame(doe)) {
    stop("`doe` must be a data.frame.", call. = FALSE)
  }

  if (nrow(doe) == 0L) {
    stop("`doe` must contain at least one row.", call. = FALSE)
  }

  if (ncol(doe) == 0L) {
    stop(
      "`doe` must contain at least one parameter column.",
      call. = FALSE
    )
  }

  doe_names <- names(doe)

  if (is.null(doe_names) ||
      anyNA(doe_names) ||
      any(doe_names == "") ||
      anyDuplicated(doe_names)) {
    stop(
      "Columns of `doe` must have unique, non-empty names.",
      call. = FALSE
    )
  }

  # Validate the output variable filter
  if (!is.null(var)) {
    if (!is.character(var) ||
        anyNA(var) ||
        any(var == "")) {
      stop(
        "`var` must be NULL or a character vector of variable names.",
        call. = FALSE
      )
    }

    # Date is always retained and must not be specified in var
    var <- setdiff(var, "Date")
  }

  if ("sim_id" %in% names(doe)) {
    stop(
      "`sim_id` is a reserved column name in the DoE.",
      call. = FALSE
    )
  }

  # Identify where each parameter is defined
  input_names <- list(
    soil = names(soil),
    weather_station = names(weather_station),
    practices = names(practices),
    plant = names(plant)
  )

  parameter_targets <- lapply(doe_names, function(param) {
    names(input_names)[
      vapply(
        input_names,
        function(x) param %in% x,
        logical(1)
      )
    ]
  })

  names(parameter_targets) <- doe_names

  unknown_parameters <- doe_names[
    lengths(parameter_targets) == 0L
  ]

  if (length(unknown_parameters) > 0L) {
    stop(
      "Unknown parameter(s) in `doe`: ",
      paste(unknown_parameters, collapse = ", "),
      ". Parameter names must exist in soil, weather_station, ",
      "practices or plant.",
      call. = FALSE
    )
  }

  # Validate requested dates against the simulation period
  if (!is.null(dates)) {

    if (!inherits(dates, "Date")) {
      dates <- as.Date(dates)
    }

    if (anyNA(dates)) {
      stop(
        "`dates` must contain valid dates.",
        call. = FALSE
      )
    }

    sowing_year <- as.integer(practices$sowing_year)

    sowing_date <- as.Date(
      paste0(sowing_year, "-01-01")
    ) + practices$doy_sowing - 1

    stop_year <- sowing_year
    if (practices$doy_stop_sim < practices$doy_sowing) {
      stop_year <- stop_year + 1L
    }

    stop_date <- as.Date(
      paste0(stop_year, "-01-01")
    ) + practices$doy_stop_sim - 1

    # Handle simulations ending in the following calendar year
    if (practices$doy_stop_sim < practices$doy_sowing) {
      stop_date <- as.Date(
        practices$sowing_year + 1,
        format = "%Y"
      ) + practices$doy_stop_sim - 1
    }

    outside_dates <- dates[
      dates < sowing_date | dates > stop_date
    ]

    if (length(outside_dates) > 0L) {
      stop(
        "Some requested dates are outside the simulation period [",
        sowing_date, ", ", stop_date, "]: ",
        paste(outside_dates, collapse = ", "),
        call. = FALSE
      )
    }
  }

  # Run one simulation for each row of the experimental design
  simulations <- future.apply::future_lapply(
    seq_len(nrow(doe)),
    function(i) {

      # Copy the inputs for this simulation
      soil_i <- soil
      weather_station_i <- weather_station
      practices_i <- practices
      plant_i <- plant

      # Apply the parameter values defined by row i
      for (param in doe_names) {

        # Support both ordinary columns and list-columns
        column <- doe[[param]]

        value <- if (is.list(column)) {
          column[[i]]
        } else {
          column[i]
        }

        targets <- parameter_targets[[param]]

        if ("soil" %in% targets) {
          soil_i[[param]] <- value
        }

        if ("weather_station" %in% targets) {
          weather_station_i[[param]] <- value
        }

        if ("practices" %in% targets) {
          practices_i[[param]] <- value
        }

        if ("plant" %in% targets) {
          plant_i[[param]] <- value
        }
      }

      # Run miniSTICS
      sim <- miniSTICS(
        soil = soil_i,
        weather_station = weather_station_i,
        practices = practices_i,
        plant = plant_i,
        weather = weather
      )

      # Filter variables before returning the results
      if (!is.null(var)) {

        missing_vars <- setdiff(var, names(sim))

        if (length(missing_vars) > 0L) {
          stop(
            "Unknown output variable(s) returned by miniSTICS(): ",
            paste(missing_vars, collapse = ", "),
            call. = FALSE
          )
        }

        sim <- sim[, c("Date", var), drop = FALSE]
      }

      # Filter dates
      if (!is.null(dates)) {
        sim <- sim[sim$Date %in% dates, , drop = FALSE]
      }

      # Identify the simulation associated with each row
      sim$sim_id <- i

      # Put the identifier first
      sim <- sim[, c("sim_id", setdiff(names(sim), "sim_id")),
                 drop = FALSE]

      sim
    },
    future.scheduling = future.scheduling,
    future.seed = FALSE
  )

  # Combine all simulation results in one operation
  result <- do.call(rbind, unname(simulations))

  # Remove row names generated by rbind
  rownames(result) <- NULL

  result
}
