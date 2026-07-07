soil_example <- list(
  # Soil profile
  lim_inf_z1 = 30,
  lim_inf_z2 = 150,
  profsoil = 200,

  # Soil water retention
  humin_1 = 0.13,
  hucc_1 = 0.30,
  humin_2 = 0.19,
  hucc_2 = 0.35,

  # Soil properties driving evaporation
  argi_1 = 8,
  da_1 = 1.3,
  aclim = 14,
  q0 = 7.5,
  flag_ha = FALSE,

  # Initial soil water content
  hur1_init = 0.05,
  hur2_init = 0.30
)

usethis::use_data(
  soil_example,
  overwrite = TRUE
)

