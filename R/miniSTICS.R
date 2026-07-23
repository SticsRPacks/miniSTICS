# Copyright 2019 Gembloux Agro-Bio Tech - University of Liège
# Copyright 2019 Forschungszentrum Jülich
# Copyright 2019 INRAE Avignon
#
# This file includes code derived from external sources originally licensed
# under the Apache License, Version 2.0.

#' Run the miniSTICS crop model
#'
#' miniSTICS is a simplified crop model derived from the STICS soil-crop model.
#' It is designed to simulate crop growth and water balance with reduced complexity,
#' while preserving the main processes controlling crop development and water stress.
#'
#' The model is particularly suited for crops sensitive to vernalization and photoperiod,
#' such as winter wheat, and is organized as a sequence of modules describing phenology,
#' water balance, and biomass accumulation.
#'
#' The scientific basis of STICS and its simplified formulations can be found in:
#' - Brisson et al. (1998), Agronomie, 18(5–6), 311–346.
#' - Tremblay & Wallach (2004), Agronomie, 24(6–7), 351–365.
#' - Beaudoin et al. (2023), STICS soil-crop model: Conceptual framework, equations and uses.
#'
#' @param soil a named list of soil parameters for the miniSTICS model.
#'
#' Soil parameters are grouped below for clarity.
#'
#' Initial conditions:
#' \itemize{
#'   \item hur1_init: Initial water content horizon 1 (% vol)
#'   \item hur2_init: Initial water content horizon 2 (% vol)
#' }
#'
#' Soil profile:
#' \itemize{
#'   \item lim_inf_z1: Bottom depth of horizon 1 (cm)
#'   \item lim_inf_z2: Bottom depth of horizon 2 (cm)
#'   \item profsoil: Maximum soil depth (cm)
#' }
#'
#' Soil water retention:
#' \itemize{
#'   \item humin_1: Wilting point horizon 1 (% vol)
#'   \item hucc_1: Field capacity horizon 1 (% vol)
#'   \item humin_2: Wilting point horizon 2 (% vol)
#'   \item hucc_2: Field capacity horizon 2 (% vol)
#' }
#'
#' Soil evaporation:
#' \itemize{
#'   \item argi_1: Clay content horizon 1 (%)
#'   \item da_1: Bulk density horizon 1 (g cm-3)
#'   \item aclim: Evaporation climate parameter (mm)
#'   \item flag_ha: Logical, use residual water content for evaporation stopping
#'   \item q0: Threshold between evaporation phases (mm)
#' }
#'
#' @param weather_station a named list of weather station parameters.
#' \itemize{
#'   \item lat: Latitude of the weather station (decimal degrees)
#'   \item z: Elevation of the weather station above sea level (m)
#' }
#'
#' @param practices a named list of crop management and initialization parameters.
#' \itemize{
#'   \item sowing_year: Beginning year of simulation (YYYY)
#'   \item doy_sowing: Day of year of sowing
#'   \item doy_stop_sim: End of simulation (DOY, up to 730 days after sowing)
#'   \item zrac0: Planting depth (cm)
#'   \item density: Plant density (plant m-2)
#' }
#'
#' @param plant a named list of plant parameters.
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
#'   \item st2emerge: Germination–emergence (°Cd cm-1)
#'   \item stlevamf: Emergence–1st node (°Cd)
#'   \item stamflax: 1st node–flag leaf (°Cd)
#'   \item stlevdrp: Emergence–flowering (°Cd)
#'   \item stdrpmat: Flowering–maturity (°Cd)
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
#'   \item dlaimax: Max LAI growth rate
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
#'   \item tetstomate: Soil water threshold for stomatal closure (% vol)
#' }
#'
#' @param weather a data.frame containing daily weather data used as
#' forcing for the miniSTICS model.
#'
#' The data.frame must contain the following columns:
#'
#' \itemize{
#'   \item Date: Date of observation (dd/mm/yyyy)
#'   \item ANNEE: Year of observation
#'   \item DOY: Day of year (1–365/366)
#'
#'   \item Temp_min: Minimum air temperature (°C)
#'   \item Temp_moy: Mean air temperature (°C)
#'   \item Temp_max: Maximum air temperature (°C)
#'
#'   \item Radiation: Incoming global radiation (MJ m-2 day-1)
#'   \item Rain: Precipitation (mm)
#'   \item Wind: Wind speed (m s-1)
#'   \item Rel_Hum: Relative humidity (%)
#'   \item Photoperiod: Day length (hours)
#' }
#'
#' All columns are required and must not contain missing values
#'
#' @details
#' The model sequentially computes:
#' (1) phenological development,
#' (2) leaf area expansion,
#' (3) root growth and water uptake,
#' (4) soil water balance,
#' (5) biomass accumulation and partitioning.
#'
#' @examples
#' # Run miniSTICS with the example dataset provided with the package
#' data(soil_example)
#' data(weather_station_example)
#' data(practices_example)
#' data(weather_example)
#'
#' # Create a default winter wheat parameter set
#' plant <- plant_parameters()
#'
#' # Run the model
#' result <- miniSTICS(
#'   soil = soil_example,
#'   weather_station = weather_station_example,
#'   practices = practices_example,
#'   plant = plant,
#'   weather = weather_example
#' )
#'
#' # Inspect simulation outputs
#' names(result)
#' head(result)
#'
#' # Modify plant parameters before running a new simulation
#' plant$rue <- 3.5
#'
#' result_modified <- miniSTICS(
#'   soil = soil_example,
#'   weather_station = weather_station_example,
#'   practices = practices_example,
#'   plant = plant,
#'   weather = weather_example
#' )
#'
#' @importFrom dplyr mutate
#' @importFrom tibble tibble
#'
#' @export
miniSTICS <- function(soil, weather_station, practices, plant, weather) {

  # =========================
  # ==  DEFINE PARAMETERS  ==
  # =========================

  parameters <- list(
    soil = soil,
    weather_station = weather_station,
    practices = practices,
    plant = plant
  )
  parameters <- lapply(parameters, function(parameter_group) {
    names(parameter_group) <- tolower(names(parameter_group))
    parameter_group
  })
  expected_parameters <- list(
    soil = c(
      "hur1_init", "hur2_init",
      "lim_inf_z1", "lim_inf_z2", "profsoil",
      "humin_1", "hucc_1", "humin_2", "hucc_2",
      "argi_1", "da_1", "aclim", "flag_ha", "q0"
    ),
    weather_station = c("lat", "z"),
    practices = c("sowing_year", "doy_sowing", "doy_stop_sim", "zrac0", "density"),
    plant = c(
      "tcmin", "tcopt", "tcxstop",
      "flag_vern", "jvc", "tfroid", "ampfroid",
      "flag_photo", "phobase", "phosat",
      "st2germinate", "st2emerge", "stlevamf", "stamflax", "stlevdrp", "stdrpmat",
      "croirac",
      "kmax", "zlabour", "zpente", "zprlim", "lvopt",
      "adens", "bdens", "dlaimax", "pentlaimax", "vlaimax",
      "parsurg", "extin", "rue",
      "tetstomate"
    )
  )
  missing_parameters <- lapply(
    names(expected_parameters),
    function(parameter_group) {
      setdiff(expected_parameters[[parameter_group]], names(parameters[[parameter_group]]))
    }
  )
  names(missing_parameters) <- names(expected_parameters)
  missing_parameters <- missing_parameters[lengths(missing_parameters) > 0]
  if (length(missing_parameters) > 0) {
    missing_parameters <- paste(
      paste0(names(missing_parameters), ": ", vapply(missing_parameters, paste, character(1), collapse = ", ")),
      collapse = "; "
    )
    stop("Missing required parameters: ", missing_parameters, call. = FALSE)
  }
  extra_parameters <- lapply(
    names(expected_parameters),
    function(parameter_group) {
      setdiff(names(parameters[[parameter_group]]), expected_parameters[[parameter_group]])
    }
  )
  names(extra_parameters) <- names(expected_parameters)
  extra_parameters <- extra_parameters[lengths(extra_parameters) > 0]
  if (length(extra_parameters) > 0) {
    extra_parameters <- paste(
      paste0(names(extra_parameters), ": ", vapply(extra_parameters, paste, character(1), collapse = ", ")),
      collapse = "; "
    )
    warning("Unused parameters: ", extra_parameters, call. = FALSE)
  }
  parameter_names <- unlist(lapply(parameters, names), use.names = FALSE)
  duplicated_parameters <- unique(parameter_names[duplicated(parameter_names)])
  if (length(duplicated_parameters) > 0) {
    stop(
      "Parameter names must be unique across soil, weather_station, practices, and plant: ",
      paste(duplicated_parameters, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(lapply(parameters, list2env, envir = environment()))

  # Internal parameters computed from user-provided parameters
  p <- 101.3 * ((293 - 0.0065 * z) / 293)^(5.26)
  gamma <- 0.665 * 10^(-3) * p
  ha <- argi_1 / 100 / 15 * da_1 # ha is expressed in %vol - usually ranges from [0.001-0.1]
  a <- 0.5 * aclim * ((0.63 - ha)^(5 / 3)) * (hucc_1 - ha)
  s <- 4.6 / (zlabour - zpente)

  # ==========================
  # ==  GET THE weather DATA  ==
  # ==========================

  year_2import <- as.Date(sprintf("%04d-01-01", sowing_year))

  weather_var <- weather |>
    mutate(Date = as.Date(Date, format = "%d/%m/%Y"))

  if (!"Temp_moy" %in% names(weather_var)) {
    weather_var <- weather_var |>
      mutate(Temp = (Temp_min + Temp_max) / 2)
  } else {
    weather_var <- weather_var |>
      mutate(Temp = Temp_moy)
  }

  if (!"ETP" %in% names(weather_var)) {
    weather_var <- weather_var |>
      mutate(
        esat = 0.6108 * exp(17.27 * Temp / (Temp + 237.3)),
        ea = Rel_Hum / 100 * esat,
        Delta = 4098 * esat / (Temp + 237.3)^2,
        ETP = (
          0.408 * Delta * Radiation +
            gamma * 900 / (Temp + 273) * Wind * (esat - ea)
        ) / (
          Delta + gamma * (1 + 0.34 * Wind)
        )
      )
  }

  # to do : # compute photoperiod in the routine based on "lat"
  # function has been added, with a check if variable does not exist, as for ETP and Temp_Moy

  if (!"Photoperiod" %in% names(weather_var)) {

    weather_var <- weather_var |>
      mutate(Sol_decl = (23.45*pi/180)*sin((360*pi/180/365.25)*(DOY+283)) )

    weather_var <- weather_var |>
      mutate(Photoperiod = (24/pi)*acos(-tan(lat*pi/180)*tan(Sol_decl)) )

  }

  weather_var <- weather_var |>
    dplyr::select(Date, Rain, Radiation, Temp, Photoperiod, ETP)


  ministics <- tibble(doy = c(doy_sowing:doy_stop_sim)) |>
    mutate(D_Cal = year_2import + doy) |>
    merge(weather_var, by.x = "D_Cal", by.y = "Date")


  # ========================================
  # ==  COMPUTE PHENOLOGICAL DEVELOPMENT  ==
  # ========================================

  #  /!\ We assume not delay on phenological growth associated to water stress !!
  #  This allows to use "mutate" fonction to speed up  computation process
  #  The routine should be rewritten if we wanted to simulate WStress !

  # ministics <- ministics |>
  #   mutate(UDEVCULT = ifelse(Temp < tcmin, 0, ifelse(Temp < tcopt, Temp - tcmin, tcopt - tcmin))) |>
  #   mutate(RFPI = (Photoperiod - phosat) / (phosat - phobase) + 1) |>
  #   mutate(JVI = max((1 - ((tfroid - Temp) / ampfroid)^2), 0))

  # function has been added, to account for triangular function of udevcult
  # need to check if the order of function is coherent
  # 1 - check if smaller than tcmin, then 0
  # 2 - check if greater than tcxstop, then 0
  # 3 - check if smaller or greater than tcopt, then positive slope (tcmin-tcxtop) or negative slope ((tcopt - tcmin)/(tcopt - tcxstop)*(Temp - tcxstop))

  ministics <- ministics |>
    mutate(UDEVCULT = ifelse(Temp < tcmin, 0, ifelse ( Temp > tcxstop, 0,ifelse(Temp < tcopt, Temp - tcmin, (tcopt - tcmin)/(tcopt - tcxstop)*(Temp - tcxstop) ))) ) |>
    mutate(RFPI = (Photoperiod - phosat) / (phosat - phobase) + 1) |>
    mutate(JVI = max((1 - ((tfroid - Temp) / ampfroid)^2), 0))

  ministics <- ministics |>
    mutate(Sum_DcDays = -(st2germinate + st2emerge * zrac0) + cumsum(UDEVCULT))

  ministics <- ministics |>
    mutate(DOY_2GER = ifelse(Sum_DcDays >= -(st2emerge * zrac0), 1, 0)) |>
    mutate(DOY_2EMERG = ifelse(Sum_DcDays >= 0, 1, 0))

  ind_ger <- which(ministics$Sum_DcDays >= -(st2emerge * zrac0))
  ind_ger <- ind_ger[1]

  ind_emerg <- which(ministics$Sum_DcDays >= 0)
  ind_emerg <- ind_emerg[1]

  ministics$RFVI <- NA
  JVI_cum <- 0
  for (i in c(1:nrow(ministics))) {
    if (ministics$DOY_2GER[i] == 1) {
      JVI_cum <- (ministics$JVI[i] + JVI_cum)
      ministics$RFVI[i] <- ifelse(JVI_cum / jvc < 1, JVI_cum / jvc, 1)
    } else {
      ministics$RFVI[i] <- 0
    }
  }
  rm(JVI_cum)

  if (flag_vern == FALSE) {
    ministics$RFVI <- 1
  }

  if (flag_photo == FALSE) {
    ministics$RFPI <- 1
  }

  ministics <- ministics |>
    mutate(UPVT_GER_FLO = DOY_2EMERG * UDEVCULT * RFPI * RFVI) |>
    mutate(Sum_UPVT_GER_FLO = cumsum(UPVT_GER_FLO)) |>
    mutate(DOY_2Z30 = ifelse(Sum_UPVT_GER_FLO >= stlevamf, 1, 0)) |>
    mutate(DOY_2Z39 = ifelse(Sum_UPVT_GER_FLO >= stlevamf + stamflax, 1, 0)) |>
    mutate(DOY_2Z65 = ifelse(Sum_UPVT_GER_FLO >= stlevdrp, 1, 0)) |>
    mutate(UPVT_FLO_MAT = DOY_2Z65 * UDEVCULT * RFVI) |>
    mutate(Sum_UPVT_FLO_MAT = cumsum(UPVT_FLO_MAT))

  ind_Z30 <- which(ministics$DOY_2Z30 > 0)
  ind_Z30 <- ind_Z30[1]

  ind_Z39 <- which(ministics$DOY_2Z39 > 0)
  ind_Z39 <- ind_Z39[1]

  ind_Z65 <- which(ministics$DOY_2Z65 > 0)
  ind_Z65 <- ind_Z65[1]

  ministics <- ministics |>
    mutate(Sum_UPVT = (1 - DOY_2EMERG) * Sum_DcDays + (1 - DOY_2Z65) * Sum_UPVT_GER_FLO + DOY_2Z65 * (Sum_UPVT_GER_FLO[ind_Z65 - 1] + Sum_UPVT_FLO_MAT)) |>
    mutate(DOY_2Z89 = ifelse(Sum_UPVT >= stlevdrp + stdrpmat, 1, 0))

  ind_Z89 <- which(ministics$DOY_2Z89 > 0)
  ind_Z89 <- ind_Z89[1]

  # DELETE UNECESSARY COLUMNS
  ministics <- subset(ministics, select = -c(Sum_DcDays, UPVT_GER_FLO, Sum_UPVT_GER_FLO, UPVT_FLO_MAT, Sum_UPVT_FLO_MAT))

  # REARRANGE COLUMNS
  ministics <- ministics |> dplyr::select(c(D_Cal, doy, Radiation, Rain, ETP, Temp, UDEVCULT, JVI, RFVI, Photoperiod, RFPI, Sum_UPVT, DOY_2GER, DOY_2EMERG, DOY_2Z30, DOY_2Z39, DOY_2Z65, DOY_2Z89))


  # ====================================
  # ==  Store Phenology in dataframe  ==
  # ====================================
  Pheno <- data.frame(NA)

  Pheno$ind_ger <- ind_ger
  Pheno$ind_emerg <- ind_emerg
  Pheno$ind_Z30 <- ind_Z30
  Pheno$ind_Z39 <- ind_Z39
  Pheno$ind_Z65 <- ind_Z65
  Pheno$ind_Z89 <- ind_Z89





  # =====================================================
  # ==  Plant growth in interaction with water stress  ==
  # =====================================================

  # Now it is required to solve dynamically the growth processes and stress interaction
  # Using "mutate" fonction will not be possible

  # Initialize model variables
  # --------------------------
  sz <- nrow(ministics)
  ministics$PFZ1 <- vector("numeric", sz)
  ministics$PFZ2 <- vector("numeric", sz)
  ministics$DeltaZEff <- vector("numeric", sz)
  ministics$DeltaZ <- vector("numeric", sz)
  ministics$ZRac <- vector("numeric", sz)

  ministics$ULAI <- vector("numeric", sz)
  ministics$DELTAI_dev <- vector("numeric", sz)
  ministics$DELTAI <- vector("numeric", sz)
  ministics$DELTAI_stress <- vector("numeric", sz)
  ministics$DELTAI_sen <- vector("numeric", sz)
  ministics$DELTAIunstr_sen
  ministics$LAI <- vector("numeric", sz)
  ministics$LAI_unstressed <- vector("numeric", sz)

  ministics$EOS <- vector("numeric", sz)
  ministics$FlagRain <- vector("numeric", sz)
  ministics$SEOS <- vector("numeric", sz)
  ministics$FlagPhase2 <- vector("numeric", sz)
  ministics$SES <- vector("numeric", sz)
  ministics$ES <- vector("numeric", sz)
  ministics$ES_a <- vector("numeric", sz)
  ministics$ESol_sum <- vector("numeric", sz)
  ministics$HUR1 <- vector("numeric", sz)

  ministics$EO <- vector("numeric", sz)
  ministics$EOP <- vector("numeric", sz)
  ministics$ZDemi <- vector("numeric", sz)
  ministics$CUMULRACZ <- vector("numeric", sz)
  ministics$TETA1 <- vector("numeric", sz)
  ministics$TETA2 <- vector("numeric", sz)
  ministics$TETA <- vector("numeric", sz)
  ministics$TETA_moy <- vector("numeric", sz)
  ministics$EP <- vector("numeric", sz)
  ministics$EP_sum <- vector("numeric", sz)
  ministics$EP_1_th <- vector("numeric", sz)
  ministics$EP_2_th <- vector("numeric", sz)
  ministics$EP_1_a <- vector("numeric", sz)
  ministics$EP_2_a <- vector("numeric", sz)
  ministics$HUR1 <- vector("numeric", sz)
  ministics$HUR2 <- vector("numeric", sz)
  ministics$SWFAC <- vector("numeric", sz)

  ministics$DELTAMS <- vector("numeric", sz)
  ministics$DELTAMS_unstressed <- vector("numeric", sz)
  ministics$MASEC <- vector("numeric", sz)
  ministics$MASEC_unstressed <- vector("numeric", sz)

  ministics$DRAIN1 <- vector("numeric", sz)
  ministics$HUR1 <- vector("numeric", sz)
  ministics$DRAIN2 <- vector("numeric", sz)
  ministics$HUR2 <- vector("numeric", sz)

  LRAC_MATRIX <- matrix(NA, nrow = nrow(ministics), ncol = profsoil)

  MAXLAI_sofar <- 0
  MAXLAIunstr_sofar <- 0
  Slope_LAI_Sen <- ministics$Sum_UPVT[ind_Z89] - ministics$Sum_UPVT[ind_Z65]


  # Enter the Loop to solve crop growth
  # ------------------------------------

  for (i in c(1:sz)) {
    # ROOT FRONT GROWTH
    # -----------------

    # /!\ There are no effects of water stress on root front growth
    # Only the water content of the soil can hinder the growth of root front

    if (i == 1) {
      ministics$PFZ1[i] <- 1
      ministics$PFZ2[i] <- 1
      ministics$DeltaZEff[i] <- 0
      ministics$DeltaZ[i] <- 0
      ministics$ZRac[i] <- zrac0
    } else {
      ministics$PFZ1[i] <- ifelse(ministics$HUR1[i - 1] >= humin_1, 1, 0)
      ministics$PFZ2[i] <- ifelse(ministics$HUR2[i - 1] >= humin_2, 1, 0)
      if (ministics$DOY_2GER[i] == 0 & ministics$DOY_2Z89[i] == 0) {
        ministics$DeltaZEff[i] <- 0
        ministics$DeltaZ[i] <- 0
        ministics$ZRac[i] <- zrac0
      } else if (ministics$DOY_2GER[i] == 1 & ministics$DOY_2Z65[i] == 0) {
        ministics$DeltaZEff[i] <- ifelse(ministics$ZRac[i - 1] < lim_inf_z1,
          croirac * (min(ministics$UDEVCULT[i - 1], tcopt) - tcmin) * ministics$PFZ1[i],
          croirac * (min(ministics$UDEVCULT[i - 1], tcopt) - tcmin) * ministics$PFZ2[i]
        )
        ministics$DeltaZ[i] <- min(ministics$DeltaZEff[i], profsoil - ministics$ZRac[i - 1])
        ministics$ZRac[i] <- ministics$DeltaZ[i] + ministics$ZRac[i - 1]
      } else if (ministics$DOY_2GER[i] == 1 & ministics$DOY_2Z65[i] == 1) {
        ministics$DeltaZEff[i] <- 0
        ministics$DeltaZ[i] <- 0
        ministics$ZRac[i] <- ministics$ZRac[i - 1]
      }
    }
    # Ajouté SB, 2025/02/20
    if (ministics$ZRac[i] > lim_inf_z2) {
      ministics$ZRac[i] <- lim_inf_z2
    }

    # ROOT DENSITY
    # ------------

    # /!\ I took a simple assumption above zrac0:
    # I assume they are roots above zrac0, even just after emergence
    # Roots are able to grow upwards and secondary roots can also occupy this location of

    ministics$ZDemi[i] <- max(ministics$ZRac[i] - zprlim + zpente, (1.4 / s))

    ZRac_Ceil <- ceiling(ministics$ZRac[i])

    # tryCatch(
    #   {
    if (ministics$DOY_2GER[i] == 1) {
      for (c in c(1:ZRac_Ceil)) {
        LRAC_MATRIX[i, c] <- lvopt / (1 + exp(-s * (c - ministics$ZDemi[i])))
      }
    }
    #   },
    #   error = function(e) {
    #     message("Erreur détectée à i = ", i, ", c = ", c, ", nrow(LRAC_MATRIX) = ", nrow(LRAC_MATRIX), ", ncol(LRAC_MATRIX) = ", ncol(LRAC_MATRIX))
    #     message("Message d'erreur : ", e$message)
    #   }
    # )


    # LAI
    # ---

    # /!\ LAI increase from lev to lax
    # /!\ Then we have a plateau in between lax and flo
    # /!\ Finally we assume linear decrease as function of UPVT between flo and mat

    if (ministics$DOY_2EMERG[i] == 1 & ministics$DOY_2Z39[i] == 0) {
      ministics$ULAI[i] <- ifelse(ministics$Sum_UPVT[i] < stlevamf,
        1 + (2 - 1) * (ministics$Sum_UPVT[i] / stlevamf),
        ifelse(ministics$Sum_UPVT[i] < stlevamf + stamflax, 2 + (3 - 2) * (ministics$Sum_UPVT[i] - stlevamf) / stamflax, 0)
      )
    } else {
      ministics$ULAI[i] <- 0
    }

    ministics$DELTAI_dev[i] <- ifelse(ministics$ULAI[i] > 0, dlaimax / (1 + exp(pentlaimax * (vlaimax - ministics$ULAI[i]))), 0)
    ministics$DELTAI[i] <- ministics$DELTAI_dev[i] * density * (density / bdens)^(adens) * ministics$UDEVCULT[i] - tcmin

    ministics$DELTAI_stress[i] <- ifelse(i == 1, 1, ministics$SWFAC[i - 1])

    MAXLAI_sofar <- ifelse(sum(ministics$DELTAI[1:i] * ministics$DELTAI_stress[1:i]) > MAXLAI_sofar, sum(ministics$DELTAI[1:i] * ministics$DELTAI_stress[1:i]), MAXLAI_sofar)
    MAXLAIunstr_sofar <- ifelse(sum(ministics$DELTAI[1:i]) > MAXLAIunstr_sofar, sum(ministics$DELTAI[1:i]), MAXLAIunstr_sofar)

    ministics$DELTAI_sen[i] <- ifelse(ministics$DOY_2Z65[i] == 1 & ministics$DOY_2Z89[i] == 0, MAXLAI_sofar / stdrpmat * (ministics$Sum_UPVT[i] - ministics$Sum_UPVT[ind_Z65]), 0)
    ministics$DELTAIunstr_sen[i] <- ifelse(ministics$DOY_2Z65[i] == 1 & ministics$DOY_2Z89[i] == 0, MAXLAIunstr_sofar / stdrpmat * (ministics$Sum_UPVT[i] - ministics$Sum_UPVT[ind_Z65]), 0)

    ministics$LAI[i] <- ifelse(ministics$DOY_2Z89[i] == 0, sum(ministics$DELTAI[1:i] * ministics$DELTAI_stress[1:i]) - ministics$DELTAI_sen[i], 0)
    ministics$LAI_unstressed[i] <- ifelse(ministics$DOY_2Z89[i] == 0, sum(ministics$DELTAI[1:i]) - ministics$DELTAIunstr_sen[i], 0)

    # SOIL EVAPORATION
    # ----------------

    # /!\ Soil evaporation always happen, even when there is no plant (so no LAI)
    # The function that computes EOS take care of the case where LAI = 0

    ministics$EOS[i] <- ministics$ETP[i] * exp(-(extin - 0.2) * ministics$LAI[i])
    ministics$FlagRain[i] <- ifelse(ministics$Rain[i] > 0, 1, 0)
    ministics$SEOS[i] <- ifelse(i == 1, ministics$EOS[i], ifelse(ministics$FlagRain[i] == 1, ministics$EOS[i], ministics$EOS[i] + ministics$SEOS[i - 1]))
    ministics$FlagPhase2[i] <- ifelse(ministics$SEOS[i] <= q0, 1, 2)
    ministics$SES[i] <- ifelse(ministics$FlagPhase2[i] == 1, ministics$SEOS[i],
      q0 - a + (2 * a * (ministics$SEOS[i] - q0) + (a^2))^(0.5)
    )

    if (i == 1) {
      ministics$ES[i] <- ministics$SES[i]
    } else {
      if ((ministics$FlagRain[i] == 1) & (ministics$FlagPhase2[i] == 1)) {
        ministics$ES[i] <- ministics$SES[i]
      } else if ((ministics$FlagRain[i] == 0) & (ministics$FlagPhase2[i] == 1)) {
        ministics$ES[i] <- ministics$SES[i] - ministics$SES[i - 1]
      } else if ((ministics$FlagPhase2[i - 1] == 1) & (ministics$FlagPhase2[i] == 2)) {
        ministics$ES[i] <- ministics$SES[i] - q0
      } else {
        ministics$ES[i] <- ministics$SES[i] - ministics$SES[i - 1]
      }
    }

    # Recomputed the ES_a from ES based on Soil Limit
    # to do -> Define if we want ot use ha or humin_1 for lower limit to stop soil evaporation



    if (i == 1) {
      ministics$ES_a[i] <- ifelse((flag_ha == TRUE), min((hur1_init - ha) * lim_inf_z1 * 10, ministics$ES[i]), min((hur1_init - humin_1) * lim_inf_z1 * 10, ministics$ES[i]))
    } else {
      if (flag_ha == TRUE) {
        if ((ministics$HUR1[i - 1] - ha) > 0) {
          ministics$ES_a[i] <- min((ministics$HUR1[i - 1] - ha) * lim_inf_z1 * 10, ministics$ES[i])
        } else {
          ministics$ES_a[i] <- 0
        }
      } else {
        if ((ministics$HUR1[i - 1] - humin_1) > 0) {
          ministics$ES_a[i] <- min((ministics$HUR1[i - 1] - humin_1) * lim_inf_z1 * 10, ministics$ES[i])
        } else {
          ministics$ES_a[i] <- 0
        }
      }
    }

    ministics$ESol_sum[i] <- sum(ministics$ES_a[1:i])
    ministics$HUR1[i] <- ifelse(i == 1, hur1_init - ((ministics$ES_a[i] * 0.001) / (lim_inf_z1 / 100)), ministics$HUR1[i - 1] - ((ministics$ES_a[i] * 0.001) / (lim_inf_z1 / 100)))


    # PLANT TRANSPIRATION
    # -------------------

    ministics$CUMULRACZ[i] <- sum(LRAC_MATRIX[i, 1:lim_inf_z1], na.rm = TRUE) +
      sum(LRAC_MATRIX[i, (lim_inf_z1 + 1):(lim_inf_z1 + lim_inf_z2)], na.rm = TRUE)

    if ((ministics$DOY_2EMERG[i] == 1) & (ministics$DOY_2Z89[i] == 0)) {
      ministics$EO[i] <- ministics$ETP[i] * (1 + (kmax - 1) / (1 + exp(-1.5 * (ministics$LAI[i] - 3))))
      ministics$EOP[i] <- (ministics$EO[i] - ministics$EOS[i]) * (1.4 - 0.4 * (ministics$ES[i] / ministics$EOS[i]))

      # Look at the available water content in the soil layer actually occupied by roots
      ministics$TETA1[i] <- max((ministics$HUR1[i] - humin_1) * sum(is.na(LRAC_MATRIX[i, 1:lim_inf_z1]) == 0), 0)
      ministics$TETA2[i] <- ifelse(i == 1,
        max((hur2_init - humin_2) * sum(is.na(LRAC_MATRIX[i, (lim_inf_z1 + 1):(lim_inf_z1 + lim_inf_z2)]) == 0), 0),
        max((ministics$HUR2[i - 1] - humin_2) * sum(is.na(LRAC_MATRIX[i, (lim_inf_z1 + 1):(lim_inf_z1 + lim_inf_z2)]) == 0), 0)
      )

      # /!\ At this point the concept is clearly different form miniSTICS/STICS concepts.

      # Average water content over the soil layer actually occupied by roots
      # ministics$TETA[i] <- (ministics$TETA1[i]+ministics$TETA2[i])/ sum(is.na(LRAC_MATRIX[i,1:(lim_inf_z1+lim_inf_z2)])==0)
      ministics$TETA[i] <- (ministics$TETA1[i] + ministics$TETA2[i])

      ministics$TETA_moy[i] <- (ministics$TETA1[i] + ministics$TETA2[i]) / sum(is.na(LRAC_MATRIX[i, 1:(lim_inf_z1 + lim_inf_z2)]) == 0)

      ministics$SWFAC[i] <- ifelse((ministics$TETA_moy[i] > tetstomate), 1, ministics$TETA_moy[i] / tetstomate)

      # Compute the water stress index
      ministics$EP[i] <- ministics$SWFAC[i] * ministics$EOP[i]

      # Compute theoretical transpiration by layers, proportionnaly to amount of roots
      ministics$EP_1_th[i] <- ministics$EP[i] / ministics$CUMULRACZ[i] * sum(LRAC_MATRIX[i, 1:lim_inf_z1], na.rm = TRUE)
      ministics$EP_2_th[i] <- ministics$EP[i] / ministics$CUMULRACZ[i] * sum(LRAC_MATRIX[i, (lim_inf_z1 + 1):(lim_inf_z1 + lim_inf_z2)], na.rm = TRUE)


      # Compute actual transpiration by layers as the minimum between theoretical EP by layer and available water for plant in this layer (HUR-HMIN)
      ministics$EP_1_a[i] <- ifelse((ministics$HUR1[i] < humin_1), 0,
        min((ministics$HUR1[i] - humin_1) * 1000 * lim_inf_z1 / 100, ministics$EP_1_th[i])
      )

      ministics$EP_2_a[i] <- ifelse((ministics$HUR2[i - 1] < humin_2), 0,
        (ifelse(i == 1,
          min((hur2_init - humin_2) * 1000 * lim_inf_z2 / 100, ministics$EP[i] - ministics$EP_1_a[i]),
          min((ministics$HUR2[i - 1] - humin_2) * 1000 * lim_inf_z2 / 100, ministics$EP[i] - ministics$EP_1_a[i])
        ))
      )

      #  Update plant transpiration depending on what was actually upatke
      ministics$EP[i] <- ifelse((ministics$EP_1_a[i] + ministics$EP_2_a[i]) < ministics$EP[i], (ministics$EP_1_a[i] + ministics$EP_2_a[i]), ministics$EP[i])
    } else {
      ministics$EO[i] <- 0
      ministics$EOP[i] <- 0
      ministics$EP[i] <- 0
      ministics$TETA[i] <- 0
      ministics$TETA_moy[i] <- 0
      ministics$EP_1_th[i] <- 0
      ministics$EP_2_th[i] <- 0
      ministics$EP_1_a[i] <- 0
      ministics$EP_2_a[i] <- 0
      ministics$SWFAC[i] <- 1
    }

    ministics$EP_sum[i] <- sum(ministics$EP[1:i])

    # Update HUR1 based on the value already calculated during Soil Evaporation
    ministics$HUR1[i] <- ministics$HUR1[i] - ((ministics$EP_1_a[i] * 0.001) / (lim_inf_z1 / 100))

    # Update HUR2 based on the value from previous day, and consider exception when i == 1
    ministics$HUR2[i] <- ifelse(i == 1, hur2_init - ((ministics$EP_2_a[i] * 0.001) / (lim_inf_z2 / 100)), ministics$HUR2[i - 1] - ((ministics$EP_2_a[i] * 0.001) / (lim_inf_z2 / 100)))


    # TOTAL BIOMASS GROWTH
    # --------------------

    if (ministics$DOY_2EMERG[i] == 1 & ministics$DOY_2Z89[i] == 0) {
      ministics$DELTAMS[i] <- 0.95 * parsurg * ministics$Radiation[i] * rue * (1 - exp(-extin * ministics$LAI[i]))
      ministics$DELTAMS_unstressed[i] <- 0.95 * parsurg * ministics$Radiation[i] * rue * (1 - exp(-extin * ministics$LAI_unstressed[i]))
    } else {
      ministics$DELTAMS[i] <- 0
      ministics$DELTAMS_unstressed[i] <- 0
    }

    ministics$DELTAMS[i] <- ifelse(i == 1, ministics$DELTAMS[i], ministics$DELTAMS[i] * ministics$SWFAC[i - 1])

    ministics$MASEC[i] <- sum(ministics$DELTAMS[1:i]) / 100
    ministics$MASEC_unstressed[i] <- sum(ministics$DELTAMS_unstressed[1:i]) / 100


    # WATER BUDGET
    # ------------
    ministics$DRAIN1[i] <- ifelse((ministics$HUR1[i] * lim_inf_z1 * 10 + ministics$Rain[i]) > (hucc_1 * lim_inf_z1 * 10), (ministics$HUR1[i] * lim_inf_z1 * 10 + ministics$Rain[i] - hucc_1 * lim_inf_z1 * 10), 0)
    ministics$HUR1[i] <- (ministics$HUR1[i] * lim_inf_z1 * 10 + ministics$Rain[i] - ministics$DRAIN1[i]) / lim_inf_z1 / 10

    ministics$DRAIN2[i] <- ifelse((ministics$HUR2[i] * lim_inf_z2 * 10 + ministics$DRAIN1[i]) > (hucc_2 * lim_inf_z2 * 10), (ministics$HUR2[i] * lim_inf_z2 * 10 + ministics$DRAIN1[i] - hucc_2 * lim_inf_z2 * 10), 0)
    ministics$HUR2[i] <- (ministics$HUR2[i] * lim_inf_z2 * 10 + ministics$DRAIN1[i] - ministics$DRAIN2[i]) / lim_inf_z2 / 10
  }

  return(ministics)
}
