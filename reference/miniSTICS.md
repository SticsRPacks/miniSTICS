# Run the miniSTICS crop model

miniSTICS is a simplified crop model derived from the STICS soil-crop
model. It is designed to simulate crop growth and water balance with
reduced complexity, while preserving the main processes controlling crop
development and water stress.

## Usage

``` r
miniSTICS(soil, weather_station, practices, plant, weather)
```

## Arguments

- soil:

  a named list of soil parameters for the miniSTICS model.

  Soil parameters are grouped below for clarity.

  Initial conditions:

  - hur1_init: Initial water content horizon 1 (% vol)

  - hur2_init: Initial water content horizon 2 (% vol)

  Soil profile:

  - lim_inf_z1: Bottom depth of horizon 1 (cm)

  - lim_inf_z2: Bottom depth of horizon 2 (cm)

  - profsoil: Maximum soil depth (cm)

  Soil water retention:

  - humin_1: Wilting point horizon 1 (% vol)

  - hucc_1: Field capacity horizon 1 (% vol)

  - humin_2: Wilting point horizon 2 (% vol)

  - hucc_2: Field capacity horizon 2 (% vol)

  Soil evaporation:

  - argi_1: Clay content horizon 1 (%)

  - da_1: Bulk density horizon 1 (g cm-3)

  - aclim: Evaporation climate parameter (mm)

  - flag_ha: Logical, use residual water content for evaporation
    stopping

  - q0: Threshold between evaporation phases (mm)

- weather_station:

  a named list of weather station parameters.

  - lat: Latitude of the weather station (decimal degrees)

  - z: Elevation of the weather station above sea level (m)

- practices:

  a named list of crop management and initialization parameters.

  - sowing_year: Beginning year of simulation (YYYY)

  - doy_sowing: Day of year of sowing

  - doy_stop_sim: End of simulation (DOY, up to 730 days after sowing)

  - zrac0: Planting depth (cm)

  - density: Plant density (plant m-2)

- plant:

  a named list of plant parameters.

  Phenology:

  - tcmin: Base temperature (°C)

  - tcopt: Optimal temperature (°C)

  - tcxstop : Temperature at which phenological development stops (°c)

  - flag_vern: Vernalization sensitivity (logical)

  - jvc: Vernalization requirement (days)

  - tfroid: Optimal vernalization temperature (°C)

  - ampfroid: Vernalization temperature range (°C)

  - flag_photo: Photoperiod sensitivity (logical)

  - phobase: Minimum photoperiod (h)

  - phosat: Saturation photoperiod (h)

  Development:

  - st2germinate: Sowing–germination thermal time (°Cd)

  - st2emerge: Germination–emergence (°Cd cm-1)

  - stlevamf: Emergence–1st node (°Cd)

  - stamflax: 1st node–flag leaf (°Cd)

  - stlevdrp: Emergence–flowering (°Cd)

  - stdrpmat: Flowering–maturity (°Cd)

  Root growth:

  - croirac: Root front growth rate (cm °Cd-1)

  Root density:

  - kmax: Maximum crop coefficient (-)

  - zlabour: Tillage depth (cm)

  - zpente: Root density decay depth (cm)

  - zprlim: Maximum rooting depth (cm)

  - lvopt: Optimal root density (cm root cm-3 soil)

  Leaf area index:

  - adens: Competition parameter

  - bdens: Density threshold (plants m-2)

  - dlaimax: Max LAI growth rate

  - pentlaimax: LAI shape parameter

  - vlaimax: LAI inflection parameter

  Biomass:

  - parsurg: PAR fraction

  - extin: Light extinction coefficient

  - rue: Radiation use efficiency (g MJ-1)

  - temin: minimal temperature for plant growth (°C)

  - teopt: minimum range of optimal temperature for plant growth (°C)

  - teoptbis: maximum range of optimal temperature for plant growth (°C)

  - temax: Maximal temperature above which plant growth stops (°C)

  Water stress:

  - tetstomate: Soil water threshold for stomatal closure (% vol)

  Grain Yield :

  - nbjgrain : Number of days prior flowering preceding the onset of
    filling and impacting grain number set up (days)

  - cgrain : species-dependent parameters accounting for the slope of
    the relationship vitmoy - nbgrains (m^2.g^-1)

  - nbgrainmax : genetic-dependent parameter setting up the maximal
    number of grains (grains.m^-2)

  - nbgrainmin : genetic-dependent parameter setting up the minimal
    number of grains (grains.m^-2)

  - vitircarbt : slope of the linearly increase in the dynamic harvest
    index against thermal time (g_grain. g_biomass^-1.dc-day^-1)

  - irmax : maximal harvest index (-)

  - pgrainmaxi : maximal weight of grains at 0% water content (g)

  - tminremp : minimal temperature for grain filling (°C)

  - tmaxremp : maximal temperature for grain filling (°C)

- weather:

  a data.frame containing daily weather data used as forcing for the
  miniSTICS model.

  The data.frame must contain the following columns:

  - Date: Date of observation (dd/mm/yyyy)

  - ANNEE: Year of observation

  - DOY: Day of year (1–365/366)

  - Temp_min: Minimum air temperature (°C)

  - Temp_moy: Mean air temperature (°C)

  - Temp_max: Maximum air temperature (°C)

  - Radiation: Incoming global radiation (MJ m-2 day-1)

  - Rain: Precipitation (mm)

  - Wind: Wind speed (m s-1)

  - Rel_Hum: Relative humidity (%)

  - Photoperiod: Day length (hours)

  All columns are required and must not contain missing values

## Details

The model is particularly suited for crops sensitive to vernalization
and photoperiod, such as winter wheat, and is organized as a sequence of
modules describing phenology, water balance, and biomass accumulation.

The scientific basis of STICS and its simplified formulations can be
found in:

- Brisson et al. (1998), Agronomie, 18(5–6), 311–346.

- Tremblay & Wallach (2004), Agronomie, 24(6–7), 351–365.

- Beaudoin et al. (2023), STICS soil-crop model: Conceptual framework,
  equations and uses.

The model sequentially computes: (1) phenological development, (2) leaf
area expansion, (3) root growth and water uptake, (4) soil water
balance, (5) biomass accumulation and partitioning (6) grain number and
grain yield (7) water budget

## Examples

``` r
# Run miniSTICS with the example dataset provided with the package
data(soil_example)
data(weather_station_example)
data(practices_example)
data(weather_example)

# Create a default winter wheat parameter set
plant <- plant_parameters()

# Run the model
result <- miniSTICS(
  soil = soil_example,
  weather_station = weather_station_example,
  practices = practices_example,
  plant = plant,
  weather = weather_example
)

# Inspect simulation outputs
names(result)
#>  [1] "Date"               "doy"                "Radiation"         
#>  [4] "Rain"               "ETP"                "Temp"              
#>  [7] "UDEVCULT"           "JVI"                "RFVI"              
#> [10] "Photoperiod"        "RFPI"               "Sum_UPVT"          
#> [13] "DOY_2GER"           "DOY_2EMERG"         "DOY_2Z30"          
#> [16] "DOY_2Z39"           "DOY_2Z65"           "DOY_2Z89"          
#> [19] "PFZ1"               "PFZ2"               "DeltaZEff"         
#> [22] "DeltaZ"             "ZRac"               "ULAI"              
#> [25] "DELTAI_dev"         "DELTAI"             "DELTAI_stress"     
#> [28] "DELTAI_sen"         "DELTAIunstr_sen"    "LAI"               
#> [31] "LAI_unstressed"     "EOS"                "FlagRain"          
#> [34] "SEOS"               "FlagPhase2"         "SES"               
#> [37] "ES"                 "ES_a"               "ESol_sum"          
#> [40] "HUR1"               "EO"                 "EOP"               
#> [43] "ZDemi"              "CUMULRACZ"          "TETA1"             
#> [46] "TETA2"              "TETA"               "TETA_moy"          
#> [49] "EP"                 "EP_sum"             "EP_1_th"           
#> [52] "EP_2_th"            "EP_1_a"             "EP_2_a"            
#> [55] "HUR2"               "SWFAC"              "FTEMP"             
#> [58] "DELTAMS"            "DELTAMS_unstressed" "MASEC"             
#> [61] "MASEC_unstressed"   "DRAIN1"             "DRAIN2"            
#> [64] "NBGRAIN"            "IRCARB"             "PGRAIN"            
#> [67] "FTEMPREMP"          "DELTAGS"            "YIELD"             
head(result)
#> # A tibble: 6 × 69
#>   Date         doy Radiation  Rain   ETP  Temp UDEVCULT   JVI   RFVI Photoperiod
#>   <date>     <int>     <dbl> <dbl> <dbl> <dbl>    <dbl> <dbl>  <dbl>       <dbl>
#> 1 2008-10-21   295      2.65   7.2 0.686  10.5     10.5     1 0             9.97
#> 2 2008-10-22   296      6.11   0   1.23    6.9      6.9     1 0             9.91
#> 3 2008-10-23   297      8.82   0   1.60    6.9      6.9     1 0             9.85
#> 4 2008-10-24   298      2.65   0.6 0.850   8.2      8.2     1 0             9.79
#> 5 2008-10-25   299      4.33   0.2 0.876   9.3      9.3     1 0             9.73
#> 6 2008-10-26   300      2.58   2.9 0.593  10.4     10.4     1 0.0222        9.67
#> # ℹ 59 more variables: RFPI <dbl>, Sum_UPVT <dbl>, DOY_2GER <dbl>,
#> #   DOY_2EMERG <dbl>, DOY_2Z30 <dbl>, DOY_2Z39 <dbl>, DOY_2Z65 <dbl>,
#> #   DOY_2Z89 <dbl>, PFZ1 <dbl>, PFZ2 <dbl>, DeltaZEff <dbl>, DeltaZ <dbl>,
#> #   ZRac <dbl>, ULAI <dbl>, DELTAI_dev <dbl>, DELTAI <dbl>,
#> #   DELTAI_stress <dbl>, DELTAI_sen <dbl>, DELTAIunstr_sen <dbl>, LAI <dbl>,
#> #   LAI_unstressed <dbl>, EOS <dbl>, FlagRain <dbl>, SEOS <dbl>,
#> #   FlagPhase2 <dbl>, SES <dbl>, ES <dbl>, ES_a <dbl>, ESol_sum <dbl>, …

# Modify plant parameters before running a new simulation
plant$rue <- 3.5

result_modified <- miniSTICS(
  soil = soil_example,
  weather_station = weather_station_example,
  practices = practices_example,
  plant = plant,
  weather = weather_example
)
```
