#' @title miniSTICS wrapper for CroptimizR
#'
#' @description This function runs miniSTICS on a set of situations
#' (i.e. environments) using the values of the parameters defined in the
#' param_values argument. It returns the values of the simulated outputs.
#'
#' @param param_values (optional) a named vector that contains the value(s) and
#' name(s) of the parameters to force for each situation to simulate.
#' If not provided (or if is NULL), the simulations will be performed using
#' default values of the parameters (e.g. as given in model_options).
#'
#' @param situation Vector of situations names for which results must be
#' returned.
#'
#' @param model_options List containing soil, weather_station, practices,
#' weather, plant information for each situation to simulate.
#'
#' @param var (optional) vector of variables names for which results
#' must be returned. If not provided, it returns the results for all simulated
#' variables that were already listed in the var.mod
#' (i.e. from the last simulation).
#'
#' @param dates (optional) vector of dates (POSIXct) for which results must
#' be returned. Results for all dates simulated are returned if not provided.
#' If required dates varies between situations, use sit_var_dates_mask argument
#'
#' @return A list containing:
#'     o `sim_list`: a `named list` (names = situations names) of data.frames
#'     (or tibbles) of simulated output values (one element of the list per
# `      simulated situation)
#'     o `error`: a boolean indicating if at least one simulation ended
#'     with an error.
#'
#' @export
#'
#' @importFrom future.apply future_lapply
#'
miniSTICS_wrapper <- function(model_options,
                              param_values = NULL,
                              situation = NULL,
                              var = NULL,
                              dates = NULL) {

  # Check parameters to force
  if (!is.null(param_values)) {

    if (is.null(names(param_values)) ||
        any(names(param_values) == "")) {
      stop("param_values must be a named vector.")
    }

    parameter_lists <- c("soil", "weather_station", "practices", "plant")

    known_parameters <- unique(unlist(
      lapply(parameter_lists, function(x) {
        lapply(model_options[[x]], names)
      }),
      use.names = FALSE
    ))

    unknown_parameters <- setdiff(names(param_values), known_parameters)

    if (length(unknown_parameters) > 0) {
      warning(
        "The following parameters defined in param_values were not found ",
        "in soil, weather_station, practices or plant: ",
        paste(unknown_parameters, collapse = ", ")
      )
    }
  }

  situation <- setNames(situation, situation)
  sim_list <- future_lapply(situation, function(sit) {

    soil <- model_options$soil[[sit]]
    weather_station <- model_options$weather_station[[sit]]
    practices <- model_options$practices[[sit]]
    plant <- model_options$plant[[sit]]

    # Replace parameter values
    if (!is.null(param_values)) {

      for (param in names(param_values)) {

        if (param %in% names(soil)) {
          soil[[param]] <- param_values[[param]]
        }

        if (param %in% names(weather_station)) {
          weather_station[[param]] <- param_values[[param]]
        }

        if (param %in% names(practices)) {
          practices[[param]] <- param_values[[param]]
        }

        if (param %in% names(plant)) {
          plant[[param]] <- param_values[[param]]
        }
      }
    }

    miniSTICS(
      soil = soil,
      weather_station = weather_station,
      practices = practices,
      plant = plant,
      weather = model_options$weather[[sit]]
    )
  })

  # Filtering variables
  if (!is.null(var)) {
    sim_list <- lapply(sim_list, function(df) {
      df[, c("Date", var), drop = FALSE]
    })
  }

  # Filtering dates
  if (!is.null(dates)) {
    sim_list <- lapply(sim_list, function(df) {
      df[df$Date %in% dates, , drop = FALSE]
    })
  }

  attr(sim_list, "class") <- "cropr_simulation"

  return(list(
    sim_list = sim_list,
    error = FALSE
  ))
}
