#' Example crop management practices for miniSTICS
#'
#' Example crop management parameters used for running the miniSTICS
#' crop model.
#'
#' @format A named list with 5 elements:
#' \describe{
#'   \item{sowing_year}{Year of simulation (YYYY)}
#'   \item{doy_sowing}{Sowing date as day of year}
#'   \item{doy_stop_sim}{End date of simulation as day of year.
#'   Values up to 730 allow simulations over two years.}
#'   \item{zrac0}{Initial planting depth (cm)}
#'   \item{density}{Plant density (plants m-2)}
#' }
#'
#' @source Example dataset distributed with the miniSTICS package.
"practices_example"
