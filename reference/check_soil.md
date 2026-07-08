# Check miniSTICS soil parameters

Validate the consistency of soil parameters supplied to the miniSTICS
model. The function checks that all required parameters are provided and
that their values are within the admissible ranges used by the miniSTICS
interface.

## Usage

``` r
check_soil(soil)
```

## Arguments

- soil:

  A named list containing soil parameters required by miniSTICS.
  Parameter names must be provided in lowercase: `lim_inf_z1`,
  `lim_inf_z2`, `profsoil`, `humin_1`, `hucc_1`, `humin_2`, `hucc_2`,
  `argi_1`, `da_1`, `aclim`, `q0`, `flag_ha`, `hur1_init`, and
  `hur2_init`.

## Value

Invisibly returns `TRUE` if all checks are successful. The function
stops with an informative error message if:

- a required parameter is missing;

- an unknown parameter is supplied;

- a parameter value is outside its admissible range;

- a parameter has an invalid type.

## Details

These ranges correspond to the expected domain of application of the
model inputs. They are intended to detect input errors and unrealistic
values, but do not represent uncertainty ranges for parameter
calibration.

The following parameter ranges are checked:

Soil profile:

- `lim_inf_z1`: 1–30 cm

- `lim_inf_z2`: 31–170 cm

- `profsoil`: 1–200 cm

Soil water retention:

- `humin_1`: 0.10–0.20 (volumetric water content)

- `hucc_1`: 0.15–0.40 (volumetric water content)

- `humin_2`: 0.10–0.20 (volumetric water content)

- `hucc_2`: 0.15–0.40 (volumetric water content)

Soil properties controlling evaporation:

- `argi_1`: 0.5–25.5 \\

- `da_1`: 0.01–1.7 g cm-3

- `aclim`: 1–25 mm

- `q0`: 0.5–10.5 mm

- `flag_ha`: logical value

Initial soil water content:

- `hur1_init`: 0.13–0.30 (volumetric water content)

- `hur2_init`: 0.19–0.35 (volumetric water content)

## Examples

``` r
if (FALSE) { # \dontrun{
data(soil_example)

check_soil(soil_example)

# Example with an invalid value
soil_example$profsoil <- 300
check_soil(soil_example)
} # }
```
