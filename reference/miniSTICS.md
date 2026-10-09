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
#>  [1] "D_Cal"              "doy"                "Radiation"         
#>  [4] "Rain"               "ETP"                "Temp"              
#>  [7] "UDEVCULT"           "JVI"                "RFVI"              
#> [10] "Photoperiod"        "RFPI"               "Sum_UPVT"          
#> [13] "DOY_2GER"           "DOY_2EMERG"         "DOY_2Z30"          
#> [16] "DOY_2Z39"           "DOY_2Z65"           "DOY_2Z89"          
#> [19] "PFZ1"               "PFZ2"               "DeltaZEff"         
#> [22] "DeltaZ"             "ZRac"               "ULAI"              
#> [25] "DELTAI_dev"         "DELTAI"             "DELTAI_stress"     
#> [28] "DELTAI_sen"         "LAI"                "LAI_unstressed"    
#> [31] "EOS"                "FlagRain"           "SEOS"              
#> [34] "FlagPhase2"         "SES"                "ES"                
#> [37] "ES_a"               "ESol_sum"           "HUR1"              
#> [40] "EO"                 "EOP"                "ZDemi"             
#> [43] "CUMULRACZ"          "TETA1"              "TETA2"             
#> [46] "TETA"               "TETA_moy"           "EP"                
#> [49] "EP_sum"             "EP_1_th"            "EP_2_th"           
#> [52] "EP_1_a"             "EP_2_a"             "HUR2"              
#> [55] "SWFAC"              "DELTAMS"            "DELTAMS_unstressed"
#> [58] "MASEC"              "MASEC_unstressed"   "DRAIN1"            
#> [61] "DRAIN2"             "NBGRAIN"            "IRCARB"            
#> [64] "PGRAIN"             "FTEMPREMP"          "DELTAGS"           
#> [67] "YIELD"              "DELTAIunstr_sen"   
head(result)
#>        D_Cal doy Radiation Rain       ETP Temp UDEVCULT JVI       RFVI
#> 1 2008-10-22 295      6.11  0.0 1.2321267  6.9      6.9   1 0.00000000
#> 2 2008-10-23 296      8.82  0.0 1.6036476  6.9      6.9   1 0.00000000
#> 3 2008-10-24 297      2.65  0.6 0.8501455  8.2      8.2   1 0.00000000
#> 4 2008-10-25 298      4.33  0.2 0.8764107  9.3      9.3   1 0.00000000
#> 5 2008-10-26 299      2.58  2.9 0.5931017 10.4     10.4   1 0.00000000
#> 6 2008-10-27 300      4.59  9.2 0.9288467  8.5      8.5   1 0.02222222
#>   Photoperiod      RFPI Sum_UPVT DOY_2GER DOY_2EMERG DOY_2Z30 DOY_2Z39 DOY_2Z65
#> 1       9.910 0.2635036   -103.1        0          0        0        0        0
#> 2       9.849 0.2590511    -96.2        0          0        0        0        0
#> 3       9.790 0.2547445    -88.0        0          0        0        0        0
#> 4       9.730 0.2503650    -78.7        0          0        0        0        0
#> 5       9.672 0.2461314    -68.3        0          0        0        0        0
#> 6       9.613 0.2418248    -59.8        1          0        0        0        0
#>   DOY_2Z89 PFZ1 PFZ2 DeltaZEff DeltaZ  ZRac ULAI DELTAI_dev DELTAI
#> 1        0    1    1     0.000  0.000 3.000    0          0      0
#> 2        0    1    1     0.000  0.000 3.000    0          0      0
#> 3        0    1    1     0.000  0.000 3.000    0          0      0
#> 4        0    1    1     0.000  0.000 3.000    0          0      0
#> 5        0    1    1     0.000  0.000 3.000    0          0      0
#> 6        0    1    1     1.248  1.248 4.248    0          0      0
#>   DELTAI_stress DELTAI_sen LAI LAI_unstressed       EOS FlagRain      SEOS
#> 1             1          0   0              0 1.2321267        0 1.2321267
#> 2             1          0   0              0 1.6036476        0 2.8357743
#> 3             1          0   0              0 0.8501455        1 0.8501455
#> 4             1          0   0              0 0.8764107        1 0.8764107
#> 5             1          0   0              0 0.5931017        1 0.5931017
#> 6             1          0   0              0 0.9288467        1 0.9288467
#>   FlagPhase2       SES        ES        ES_a  ESol_sum      HUR1 EO EOP
#> 1          1 1.2321267 1.2321267 -24.0000000 -24.00000 0.1300000  0   0
#> 2          1 2.8357743 1.6036476   0.0000000 -24.00000 0.1300000  0   0
#> 3          1 0.8501455 0.8501455   0.0000000 -24.00000 0.1320000  0   0
#> 4          1 0.8764107 0.8764107   0.6000000 -23.40000 0.1306667  0   0
#> 5          1 0.5931017 0.5931017   0.2000000 -23.20000 0.1396667  0   0
#> 6          1 0.9288467 0.9288467   0.9288467 -22.27115 0.1672372  0   0
#>       ZDemi CUMULRACZ TETA1 TETA2 TETA TETA_moy EP EP_sum EP_1_th EP_2_th
#> 1 -25.86957 0.0000000     0     0    0        0  0      0       0       0
#> 2 -25.86957 0.0000000     0     0    0        0  0      0       0       0
#> 3 -25.86957 0.0000000     0     0    0        0  0      0       0       0
#> 4 -25.86957 0.0000000     0     0    0        0  0      0       0       0
#> 5 -25.86957 0.0000000     0     0    0        0  0      0       0       0
#> 6 -25.86957 0.5207498     0     0    0        0  0      0       0       0
#>   EP_1_a EP_2_a HUR2 SWFAC DELTAMS DELTAMS_unstressed MASEC MASEC_unstressed
#> 1      0      0  0.3     1       0                  0     0                0
#> 2      0      0  0.3     1       0                  0     0                0
#> 3      0      0  0.3     1       0                  0     0                0
#> 4      0      0  0.3     1       0                  0     0                0
#> 5      0      0  0.3     1       0                  0     0                0
#> 6      0      0  0.3     1       0                  0     0                0
#>   DRAIN1 DRAIN2 NBGRAIN IRCARB PGRAIN FTEMPREMP DELTAGS YIELD DELTAIunstr_sen
#> 1      0      0       0      0      0         1       0     0               0
#> 2      0      0       0      0      0         1       0     0               0
#> 3      0      0       0      0      0         1       0     0               0
#> 4      0      0       0      0      0         1       0     0               0
#> 5      0      0       0      0      0         1       0     0               0
#> 6      0      0       0      0      0         1       0     0               0

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
