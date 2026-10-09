# Create miniSTICS plant parameters

Create a list of plant parameters required by the miniSTICS crop model.
The default values correspond to a reference winter wheat
parameterization.

## Usage

``` r
plant_parameters(...)
```

## Arguments

- ...:

  Named plant parameters to override default values. Parameter names
  must correspond to miniSTICS plant parameters.

## Value

A named list containing plant parameters.

## Details

Plant parameters can be modified by providing named arguments.

Parameters are grouped according to their role in the model.

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

- st2emerge: Germination–emergence thermal time (°Cd cm-1)

- stlevamf: Emergence–1st node thermal time (°Cd)

- stamflax: 1st node–flag leaf thermal time (°Cd)

- stlevdrp: Emergence–flowering thermal time (°Cd)

- stdrpmat: Flowering–maturity thermal time (°Cd)

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

- dlaimax: Maximum LAI growth rate

- pentlaimax: LAI shape parameter

- vlaimax: LAI inflection parameter

Biomass:

- parsurg: PAR fraction

- extin: Light extinction coefficient

- rue: Radiation use efficiency (g MJ-1)

Water stress:

- tetstomate: Soil water threshold for stomatal closure

Grain Yield :

- nbjgrain : Number of days prior flowering preceding the onset of
  filling and impacting grain number set up (days)

- cgrain : species-dependent parameters accounting for the slope of the
  relationship vitmoy - nbgrains (m^2.g^-1)

- nbgrainmax : genetic-dependent parameter setting up the maximal number
  of grains (grains.m^-2)

- nbgrainmin : genetic-dependent parameter setting up the minimal number
  of grains (grains.m^-2)

- vitircarbt : slope of the linearly increase in the dynamic harvest
  index against thermal time (g_grain. g_biomass^-1.dc-day^-1)

- irmax : maximal harvest index (-)

- pgrainmaxi : maximal weight of grains at 0% water content (g)

- tminremp : minimal temperature for grain filling (°C)

- tmaxremp : maximal temperature for grain filling (°C)

## Examples

``` r
# Default parameter set
plant <- plant_parameters()

# Modify selected parameters
plant <- plant_parameters(
  rue = 3.5,
  flag_vern = FALSE
)
```
