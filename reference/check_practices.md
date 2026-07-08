# Check miniSTICS crop management parameters

Validate the consistency of crop management parameters supplied to the
miniSTICS model.

## Usage

``` r
check_practices(practices)
```

## Arguments

- practices:

  A named list containing crop management parameters: `sowing_year`,
  `doy_sowing`, `doy_stop_sim`, `zrac0`, and `density`.

## Value

Invisibly returns `TRUE` if all checks are successful. The function
stops with an informative error message if:

- a required parameter is missing;

- an unknown parameter is supplied;

- a parameter has an invalid type;

- a parameter value is outside its admissible range.

## Details

The function checks that all required parameters are present, that no
unknown parameters are provided, and that values are within the
admissible ranges defined for the miniSTICS interface.

These ranges are intended to detect invalid inputs and do not represent
calibration ranges.

The following ranges are checked:

- `sowing_year`: 2004–2015

- `doy_sowing`: 1–365

- `doy_stop_sim`: 1–730

- `zrac0`: 0.5–5 cm

- `density`: 100–400 plants m-2

## Examples

``` r
if (FALSE) { # \dontrun{
data(practices_example)

check_practices(practices_example)

practices_example$density <- 1000
check_practices(practices_example)
} # }
```
