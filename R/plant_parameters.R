#' Create miniSTICS plant parameters
#'
#' Create a list of plant parameters required by the miniSTICS crop model.
#' The default values correspond to a reference winter wheat parameterization.
#'
#' Plant parameters can be modified by providing named arguments.
#'
#' @param ... Named plant parameters to override default values.
#' Parameter names must correspond to miniSTICS plant parameters.
#'
#' @return A named list containing plant parameters.
#'
#' @details
#' Parameters are grouped according to their role in the model.
#'
#' Phenology:
#' \itemize{
#'   \item tcmin: Base temperature (°C)
#'   \item tcopt: Optimal temperature (°C)
#'   \item tcxstop : Temperature at which phenological development stops (°c)
#'   \item flag_vern: Vernalization sensitivity (logical)
#'   \item jvc: Vernalization requirement (days)
#'   \item tfroid: Optimal vernalization temperature (°C)
#'   \item ampfroid: Vernalization temperature range (°C)
#'   \item flag_photo: Photoperiod sensitivity (logical)
#'   \item phobase: Minimum photoperiod (h)
#'   \item phosat: Saturation photoperiod (h)
#' }
#'
#' Development:
#' \itemize{
#'   \item st2germinate: Sowing–germination thermal time (°Cd)
#'   \item st2emerge: Germination–emergence thermal time (°Cd cm-1)
#'   \item stlevamf: Emergence–1st node thermal time (°Cd)
#'   \item stamflax: 1st node–flag leaf thermal time (°Cd)
#'   \item stlevdrp: Emergence–flowering thermal time (°Cd)
#'   \item stdrpmat: Flowering–maturity thermal time (°Cd)
#' }
#'
#' Root growth:
#' \itemize{
#'   \item croirac: Root front growth rate (cm °Cd-1)
#' }
#'
#' Root density:
#' \itemize{
#'   \item kmax: Maximum crop coefficient (-)
#'   \item zlabour: Tillage depth (cm)
#'   \item zpente: Root density decay depth (cm)
#'   \item zprlim: Maximum rooting depth (cm)
#'   \item lvopt: Optimal root density (cm root cm-3 soil)
#' }
#'
#' Leaf area index:
#' \itemize{
#'   \item adens: Competition parameter
#'   \item bdens: Density threshold (plants m-2)
#'   \item dlaimax: Maximum LAI growth rate
#'   \item pentlaimax: LAI shape parameter
#'   \item vlaimax: LAI inflection parameter
#' }
#'
#' Biomass:
#' \itemize{
#'   \item parsurg: PAR fraction
#'   \item extin: Light extinction coefficient
#'   \item rue: Radiation use efficiency (g MJ-1)
#' }
#'
#' Water stress:
#' \itemize{
#'   \item tetstomate: Soil water threshold for stomatal closure
#' }
#'
#' @examples
#' # Default parameter set
#' plant <- plant_parameters()
#'
#' # Modify selected parameters
#' plant <- plant_parameters(
#'   rue = 3.5,
#'   flag_vern = FALSE
#' )
#'
#' @export
plant_parameters <- function(...) {

  params <- list(
    tcmin = 0,
    tcopt = 35,
    tcxstop = 45,
    flag_vern = TRUE,
    jvc = 45,
    tfroid = 6.5,
    ampfroid = 10,
    flag_photo = TRUE,
    phobase = 6.3,
    phosat = 20,

    st2germinate = 50,
    st2emerge = 20,
    stlevamf = 225,
    stamflax = 275,
    stlevdrp = 725,
    stdrpmat = 725,

    croirac = 0.12,

    kmax = 1,
    zlabour = 15,
    zpente = 100,
    zprlim = 150,
    lvopt = 0.6,

    adens = -0.65,
    bdens = 7,
    dlaimax = 0.00035,
    pentlaimax = 5.5,
    vlaimax = 1.8,

    parsurg = 0.48,
    extin = 0.5,
    rue = 4.2,

    tetstomate = 0.05
  )

  overrides <- list(...)

  if (length(overrides) > 0) {

    unknown <- setdiff(names(overrides), names(params))

    if (length(unknown) > 0) {
      stop(
        "Unknown plant parameters: ",
        paste(unknown, collapse = ", ")
      )
    }

    params[names(overrides)] <- overrides
  }

  params
}
