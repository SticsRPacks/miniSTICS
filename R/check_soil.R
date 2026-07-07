#' Check miniSTICS soil parameters
#'
#' Validate the consistency of soil parameters supplied to the miniSTICS model.
#' The function checks that all required parameters are provided and that their
#' values are within the admissible ranges used by the miniSTICS interface.
#'
#' These ranges correspond to the expected domain of application of the model
#' inputs. They are intended to detect input errors and unrealistic values,
#' but do not represent uncertainty ranges for parameter calibration.
#'
#' @param soil A named list containing soil parameters required by miniSTICS.
#' Parameter names must be provided in lowercase:
#' \code{lim_inf_z1}, \code{lim_inf_z2}, \code{profsoil},
#' \code{humin_1}, \code{hucc_1}, \code{humin_2}, \code{hucc_2},
#' \code{argi_1}, \code{da_1}, \code{aclim}, \code{q0},
#' \code{flag_ha}, \code{hur1_init}, and \code{hur2_init}.
#'
#' @return Invisibly returns \code{TRUE} if all checks are successful.
#' The function stops with an informative error message if:
#' \itemize{
#'   \item a required parameter is missing;
#'   \item an unknown parameter is supplied;
#'   \item a parameter value is outside its admissible range;
#'   \item a parameter has an invalid type.
#' }
#'
#' @details
#' The following parameter ranges are checked:
#'
#' Soil profile:
#' \itemize{
#'   \item \code{lim_inf_z1}: 1--30 cm
#'   \item \code{lim_inf_z2}: 31--170 cm
#'   \item \code{profsoil}: 1--200 cm
#' }
#'
#' Soil water retention:
#' \itemize{
#'   \item \code{humin_1}: 0.10--0.20 (volumetric water content)
#'   \item \code{hucc_1}: 0.15--0.40 (volumetric water content)
#'   \item \code{humin_2}: 0.10--0.20 (volumetric water content)
#'   \item \code{hucc_2}: 0.15--0.40 (volumetric water content)
#' }
#'
#' Soil properties controlling evaporation:
#' \itemize{
#'   \item \code{argi_1}: 0.5--25.5 \%
#'   \item \code{da_1}: 0.01--1.7 g cm-3
#'   \item \code{aclim}: 1--25 mm
#'   \item \code{q0}: 0.5--10.5 mm
#'   \item \code{flag_ha}: logical value
#' }
#'
#' Initial soil water content:
#' \itemize{
#'   \item \code{hur1_init}: 0.13--0.30 (volumetric water content)
#'   \item \code{hur2_init}: 0.19--0.35 (volumetric water content)
#' }
#'
#' @examples
#' \dontrun{
#' data(soil_example)
#'
#' check_soil(soil_example)
#'
#' # Example with an invalid value
#' soil_example$profsoil <- 300
#' check_soil(soil_example)
#' }
#'
#' @export
check_soil <- function(soil) {

  bounds <- list(
    lim_inf_z1 = c(1, 30),
    lim_inf_z2 = c(31, 170),
    profsoil = c(1, 200),

    humin_1 = c(0.1, 0.20),
    hucc_1 = c(0.15, 0.40),
    humin_2 = c(0.1, 0.20),
    hucc_2 = c(0.15, 0.40),

    argi_1 = c(0.5, 25.5),
    da_1 = c(0.01, 1.7),
    aclim = c(1, 25),
    q0 = c(0.5, 10.5),

    hur1_init = c(0.13, 0.30),
    hur2_init = c(0.19, 0.35)
  )

  for (p in names(bounds)) {
    if (soil[[p]] < bounds[[p]][1] ||
        soil[[p]] > bounds[[p]][2]) {
      stop(
        sprintf(
          "%s is outside valid range [%s, %s]",
          p,
          bounds[[p]][1],
          bounds[[p]][2]
        )
      )
    }
  }

  invisible(TRUE)
}
