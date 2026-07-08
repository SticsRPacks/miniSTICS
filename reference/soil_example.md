# Example soil parameters for miniSTICS

Example soil description and initial soil water conditions used for
demonstrating the miniSTICS crop model.

## Format

A named list containing:

- `lim_inf_z1`: Bottom depth of first soil horizon (cm)

- `lim_inf_z2`: Bottom depth of second soil horizon (cm)

- `profsoil`: Maximum soil depth (cm)

- `humin_1`: Wilting point water content of horizon 1 (\\

- `hucc_1`: Field capacity water content of horizon 1 (\\

- `humin_2`: Wilting point water content of horizon 2 (\\

- `hucc_2`: Field capacity water content of horizon 2 (\\

- `argi_1`: Clay content of horizon 1 (\\

- `da_1`: Bulk density of horizon 1 (g cm-3)

- `aclim`: Evaporation climate parameter (mm)

- `q0`: Threshold between evaporation phases (mm)

- `flag_ha`: Logical controlling evaporation stopping criterion

- `hur1_init`: Initial water content of horizon 1 (\\

- `hur2_init`: Initial water content of horizon 2 (\\

\#'

## Source

Example dataset distributed with the miniSTICS package.
