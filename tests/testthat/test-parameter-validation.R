if (!exists("miniSTICS", mode = "function")) {
  source(test_path("../../R/miniSTICS.R"))
}

valid_soil <- function() {
  list(
    hur1_init = 1,
    hur2_init = 1,
    lim_inf_z1 = 1,
    lim_inf_z2 = 1,
    profsoil = 1,
    humin_1 = 1,
    hucc_1 = 1,
    humin_2 = 1,
    hucc_2 = 1,
    argi_1 = 1,
    da_1 = 1,
    aclim = 1,
    flag_ha = TRUE,
    q0 = 1
  )
}

valid_weather_station <- function() {
  list(
    lat = 1,
    z = 1
  )
}

valid_practices <- function() {
  list(
    sowing_year = 2004,
    doy_sowing = 1,
    doy_stop_sim = 1,
    zrac0 = 1,
    density = 1
  )
}

valid_plant <- function() {
  list(
    tcmin = 1,
    tcopt = 1,
    flag_vern = FALSE,
    jvc = 1,
    tfroid = 1,
    ampfroid = 1,
    flag_photo = FALSE,
    phobase = 1,
    phosat = 1,
    st2germinate = 1,
    st2emerge = 1,
    stlevamf = 1,
    stamflax = 1,
    stlevdrp = 1,
    stdrpmat = 1,
    croirac = 1,
    kmax = 1,
    zlabour = 1,
    zpente = 2,
    zprlim = 1,
    lvopt = 1,
    adens = 1,
    bdens = 1,
    dlaimax = 1,
    pentlaimax = 1,
    vlaimax = 1,
    parsurg = 1,
    extin = 1,
    rue = 1,
    tetstomate = 1,
    temin = 1,
    teopt = 1,
    teoptbis = 1,
    temax = 1
  )
}

empty_weather <- function() {
  data.frame()
}

test_that("miniSTICS warns when parameter lists include unused parameters", {
  soil <- valid_soil()
  soil$unused_parameter <- 1

  expect_warning(
    try(miniSTICS(soil, valid_weather_station(), valid_practices(), valid_plant(), empty_weather()), silent = TRUE),
    "Unused parameters: soil: unused_parameter"
  )
})

test_that("miniSTICS errors when required parameters are missing", {
  soil <- valid_soil()
  soil$hur1_init <- NULL

  expect_error(
    miniSTICS(soil, valid_weather_station(), valid_practices(), valid_plant(), empty_weather()),
    "Missing required parameters: soil: hur1_init"
  )
})

test_that("miniSTICS parameter name validation is case-insensitive", {
  names_soil <- toupper(names(valid_soil()))
  soil <- stats::setNames(valid_soil(), names_soil)

  result <- try(
    miniSTICS(soil, valid_weather_station(), valid_practices(), valid_plant(), empty_weather()),
    silent = TRUE
  )

  expect_false(grepl("Missing required parameters", paste(result, collapse = "\n")))
})
