# miniSTICS wrapper for CroptimizR

This function runs miniSTICS on a set of situations (i.e. environments)
using the values of the parameters defined in the param_values argument.
It returns the values of the simulated outputs.

## Usage

``` r
miniSTICS_wrapper(
  model_options,
  param_values = NULL,
  situation = NULL,
  var = NULL,
  dates = NULL
)
```

## Arguments

- model_options:

  List containing soil, weather_station, practices, weather, plant
  information for each situation to simulate.

- param_values:

  (optional) a named vector that contains the value(s) and name(s) of
  the parameters to force for each situation to simulate. If not
  provided (or if is NULL), the simulations will be performed using
  default values of the parameters (e.g. as given in model_options).

- situation:

  Vector of situations names for which results must be returned.

- var:

  (optional) vector of variables names for which results must be
  returned. If not provided, it returns the results for all simulated
  variables that were already listed in the var.mod (i.e. from the last
  simulation).

- dates:

  (optional) vector of dates (POSIXct) for which results must be
  returned. Results for all dates simulated are returned if not
  provided. If required dates varies between situations, use
  sit_var_dates_mask argument

## Value

A list containing: o `sim_list`: a `named list` (names = situations
names) of data.frames (or tibbles) of simulated output values (one
element of the list per o `error`: a boolean indicating if at least one
simulation ended with an error.
