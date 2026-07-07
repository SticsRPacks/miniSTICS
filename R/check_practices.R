#' Check miniSTICS crop management parameters
#'
#' Validate the consistency of crop management parameters supplied to the
#' miniSTICS model.
#'
#' The function checks that all required parameters are present, that no
#' unknown parameters are provided, and that values are within the admissible
#' ranges defined for the miniSTICS interface.
#'
#' These ranges are intended to detect invalid inputs and do not represent
#' calibration ranges.
#'
#' @param practices A named list containing crop management parameters:
#' \code{sowing_year}, \code{doy_sowing}, \code{doy_stop_sim},
#' \code{zrac0}, and \code{density}.
#'
#' @return Invisibly returns \code{TRUE} if all checks are successful.
#' The function stops with an informative error message if:
#' \itemize{
#'   \item a required parameter is missing;
#'   \item an unknown parameter is supplied;
#'   \item a parameter has an invalid type;
#'   \item a parameter value is outside its admissible range.
#' }
#'
#' @details
#' The following ranges are checked:
#'
#' \itemize{
#'   \item \code{sowing_year}: 2004--2015
#'   \item \code{doy_sowing}: 1--365
#'   \item \code{doy_stop_sim}: 1--730
#'   \item \code{zrac0}: 0.5--5 cm
#'   \item \code{density}: 100--400 plants m-2
#' }
#'
#' @examples
#' \dontrun{
#' data(practices_example)
#'
#' check_practices(practices_example)
#'
#' practices_example$density <- 1000
#' check_practices(practices_example)
#' }
#'
#' @export
check_practices <- function(practices) {

  required <- c(
    "sowing_year",
    "doy_sowing",
    "doy_stop_sim",
    "zrac0",
    "density"
  )

  # Check object type
  if (!is.list(practices)) {
    stop("'practices' must be a named list.")
  }

  # Check names
  missing <- setdiff(required, names(practices))
  if (length(missing) > 0) {
    stop(
      "Missing practices parameters: ",
      paste(missing, collapse = ", ")
    )
  }

  unknown <- setdiff(names(practices), required)
  if (length(unknown) > 0) {
    stop(
      "Unknown practices parameters: ",
      paste(unknown, collapse = ", ")
    )
  }

  # Check types
  if (!is.numeric(practices$sowing_year) ||
      length(practices$sowing_year) != 1) {
    stop("'sowing_year' must be a single numeric value.")
  }

  if (!is.numeric(practices$doy_sowing) ||
      length(practices$doy_sowing) != 1) {
    stop("'doy_sowing' must be a single numeric value.")
  }

  if (!is.numeric(practices$doy_stop_sim) ||
      length(practices$doy_stop_sim) != 1) {
    stop("'doy_stop_sim' must be a single numeric value.")
  }

  if (!is.numeric(practices$zrac0) ||
      length(practices$zrac0) != 1) {
    stop("'zrac0' must be a single numeric value.")
  }

  if (!is.numeric(practices$density) ||
      length(practices$density) != 1) {
    stop("'density' must be a single numeric value.")
  }

  # Check ranges
  bounds <- list(
    sowing_year = c(2004, 2015),
    doy_sowing = c(1, 365),
    doy_stop_sim = c(1, 730),
    zrac0 = c(0.5, 5),
    density = c(100, 400)
  )

  for (param in names(bounds)) {

    value <- practices[[param]]

    if (value < bounds[[param]][1] ||
        value > bounds[[param]][2]) {

      stop(
        sprintf(
          "'%s' must be between %s and %s (current value: %s).",
          param,
          bounds[[param]][1],
          bounds[[param]][2],
          value
        )
      )
    }
  }

  invisible(TRUE)
}
