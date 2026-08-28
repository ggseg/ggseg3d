# Introduction to ggseg3d

Brain segmentation results are easier to interpret when they look like a
brain. ggseg3d takes a data frame with region names and renders it as an
interactive 3D mesh — rotate, zoom, hover for labels — right in the
browser.

## Getting started

``` r

library(ggseg3d)

ggseg3d(hemisphere = "left") |>
  pan_camera("left lateral")
```

![Left hemisphere of the Desikan-Killiany atlas, each cortical region in
a distinct colour, viewed from the lateral
side.](img/intro-basic.png "Default DK atlas, left lateral view")

Left hemisphere of the Desikan-Killiany atlas, each cortical region in a
distinct colour, viewed from the lateral side.

With no arguments,
[`ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.md)
plots the Desikan-Killiany atlas. The output is an htmlwidget: click and
drag to rotate, scroll to zoom, hover to see region names.

## Mapping data

Match your data to the atlas by region name, then point `colour_by` at
the variable you care about:

``` r

library(dplyr)

some_data <- tibble(
  region = c("precentral", "postcentral", "insula", "superior parietal"),
  p = c(0.01, 0.04, 0.2, 0.5)
)

ggseg3d(.data = some_data, atlas = dk(), colour_by = "p", text_by = "p") |>
  pan_camera("right lateral")
```

![Right hemisphere with four cortical regions coloured on a blue-to-red
scale by p-value; unmatched regions shown in
grey.](img/intro-plot-data.png "Four regions mapped by p-value")

Right hemisphere with four cortical regions coloured on a blue-to-red
scale by p-value; unmatched regions shown in grey.

`text_by = "p"` adds the p-value to the hover tooltip so you can inspect
individual regions without a separate table.

## Subcortical atlases

Cortical surfaces are only half the story. The `aseg` atlas covers
subcortical structures, and
[`add_glassbrain()`](https://ggsegverse.github.io/ggseg3d/reference/add_glassbrain.md)
wraps them in a translucent cortex for anatomical context:

``` r

subcort_data <- tibble(
  region = c("Thalamus", "Caudate", "Hippocampus"),
  p = c(0.2, 0.5, 0.8)
)

ggseg3d(
  .data = subcort_data,
  atlas = aseg(),
  colour_by = "p",
  na_alpha = 0.5
) |>
  add_glassbrain()
```

![Thalamus, caudate, and hippocampus coloured by p-value, visible
through a semi-transparent cortical
shell.](img/intro-subcortical.png "Subcortical structures inside a glass brain")

Thalamus, caudate, and hippocampus coloured by p-value, visible through
a semi-transparent cortical shell.

## Camera and background

[`pan_camera()`](https://ggsegverse.github.io/ggseg3d/reference/pan_camera.md)
sets the viewing angle.
[`set_background()`](https://ggsegverse.github.io/ggseg3d/reference/set_background.md)
changes the canvas colour — handy for dark-themed slides:

``` r

ggseg3d(hemisphere = "left") |>
  pan_camera("left lateral") |>
  set_background("black")
```

![Left hemisphere on a black background, cortical regions visible in
their default atlas
colours.](img/intro-background.png "Dark background for slides or posters")

Left hemisphere on a black background, cortical regions visible in their
default atlas colours.

Camera presets cover the standard anatomical views: `"left lateral"`,
`"right medial"`, `"left superior"`, and so on. For anything else, pass
a list with `eye` coordinates.
