# Ray-traced brain renders with rayshader

Screenshots from a WebGL viewer get the job done for presentations, but
journals and posters deserve better.
[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md)
renders brain atlases into an rgl scene — the same mesh data, the same
colour pipeline, just a different backend. Once the scene is in rgl,
rayshader’s path tracer handles realistic lighting, soft shadows, and
depth of field.

This vignette walks through the full workflow: from a basic rgl scene to
a polished ray-traced figure.

## Setup

rgl provides the 3D scene, rayshader provides the ray tracer. Both are
optional dependencies — ggseg3d checks for them at runtime.

``` r

library(ggseg3d)
library(dplyr)

# install.packages(c("rgl", "rayshader")) # nolint: commented_code_linter
```

## A first render

[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md)
mirrors the
[`ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.md)
API for atlas, hemisphere, and colour mapping. The difference: instead
of an htmlwidget, you get an rgl window. Camera, background, glass brain
overlays — all of that comes through the same pipe functions you already
know from the widget side.

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")

rgl::snapshot3d("img/ray-first.png")
rgl::close3d()
```

![Left hemisphere of the DK atlas rendered in rgl, each region in its
atlas colour, viewed from the lateral
side.](img/ray-first.png "Basic rgl render of the DK atlas")

Left hemisphere of the DK atlas rendered in rgl, each region in its
atlas colour, viewed from the lateral side.

The rgl window is interactive too — rotate with the mouse, zoom with the
scroll wheel. The camera presets match the ones from
[`pan_camera()`](https://ggsegverse.github.io/ggseg3d/reference/pan_camera.md):
“left lateral”, “right medial”, “left superior”, and so on.

## Mapping data

Data mapping works identically to
[`ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.md).
Provide a data frame with a `region` column, point `colour_by` at a
numeric or categorical variable, and optionally set a custom palette:

``` r

ggsegray(
  .data = some_data,
  atlas = dk(),
  colour_by = "p",
  hemisphere = "left",
  palette = c("forestgreen" = 0, "white" = 0.05, "firebrick" = 1)
) |>
  pan_camera("left lateral")

rgl::snapshot3d("img/ray-data.png")
rgl::close3d()
```

![Left hemisphere with four cortical regions mapped to a green-white-red
palette, rendered in rgl with lighting and
shading.](img/ray-data.png "Data-mapped rgl render with custom palette")

Left hemisphere with four cortical regions mapped to a green-white-red
palette, rendered in rgl with lighting and shading.

## Quick snapshots with rgl

Before reaching for the ray tracer, grab a fast screenshot with
[`rgl::snapshot3d()`](https://dmurdoch.github.io/rgl/dev/reference/snapshot.html):

``` r

p <- ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")

rgl::snapshot3d("my_brain.png")
rgl::close3d()
```

No ray tracing, no wait. When the angle and lighting look right, switch
to `render_highquality()` for the final version.

## Ray-traced output

Build the scene with
[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md)
and pipe functions, then call `render_highquality()`:

``` r

ggsegray(
  .data = some_data,
  atlas = dk(),
  colour_by = "p",
  hemisphere = "left"
) |>
  pan_camera("left lateral") |>
  set_background("white")

rayshader::render_highquality(
  filename = "raytrace.png",
  samples = 64,
  width = 600,
  height = 450
)
rgl::close3d()
```

Higher `samples` means less noise and longer render times. For drafts,
64-128 is fine. For final figures, 256-512 produces clean results.

## Controlling the camera

Camera presets map to the same positions as the Three.js viewer. Pipe
[`pan_camera()`](https://ggsegverse.github.io/ggseg3d/reference/pan_camera.md)
after
[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md):

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")

rgl::snapshot3d("lateral.png")
rgl::close3d()
```

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left medial")

rgl::snapshot3d("medial.png")
rgl::close3d()
```

``` r

ggsegray(atlas = dk(), hemisphere = "right") |>
  pan_camera("right superior")

rgl::snapshot3d("superior.png")
rgl::close3d()
```

For a custom viewpoint, pass a numeric vector `c(x, y, z)`:

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera(c(-300, 100, 150))

rgl::snapshot3d("custom_angle.png")
rgl::close3d()
```

Once the rgl window is open,
[`rgl::view3d()`](https://dmurdoch.github.io/rgl/dev/reference/viewpoint.html)
and
[`rgl::observer3d()`](https://dmurdoch.github.io/rgl/dev/reference/observer3d.html)
let you fine-tune interactively before rendering.

## Lighting

Rayshader controls lighting through `render_highquality()`. The
`light_direction` and `light_altitude` parameters set the angle and
elevation of the light source:

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")

rayshader::render_highquality(
  filename = "lighting.png",
  samples = 64,
  light_direction = 90,
  light_altitude = 30
)
rgl::close3d()
```

For richer lighting setups — multiple light sources, coloured lights,
area lights — pass custom scene elements:

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")

rayshader::render_highquality(
  filename = "custom_light.png",
  samples = 64,
  width = 600,
  height = 450,
  light = FALSE,
  scene_elements = rayrender::sphere(
    x = -300, y = 300, z = 200,
    radius = 50,
    material = rayrender::light(intensity = 80, color = "white")
  ),
  interactive = FALSE
)
rgl::close3d()
```

## Background colour

White backgrounds work for most journals. For posters or slides, dark
backgrounds make the brain pop:

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral") |>
  set_background("black")

rgl::snapshot3d("img/ray-dark.png")
rgl::close3d()
```

![Left hemisphere rendered in rgl against a black background, region
colours vivid against the dark
canvas.](img/ray-dark.png "Dark background rgl render")

Left hemisphere rendered in rgl against a black background, region
colours vivid against the dark canvas.

## Glass brain overlay

Subcortical structures float in space without context. A translucent
glass brain fixes that:

``` r

ggsegray(atlas = aseg()) |>
  add_glassbrain(colour = "#CCCCCC", opacity = 0.15) |>
  pan_camera("right lateral")

rgl::snapshot3d("img/ray-glassbrain.png")
rgl::close3d()
```

![Subcortical structures visible through a faint grey cortical shell,
rendered in rgl from the right lateral
view.](img/ray-glassbrain.png "Subcortical atlas with glass brain in rgl")

Subcortical structures visible through a faint grey cortical shell,
rendered in rgl from the right lateral view.

Lower opacity values make the glass brain more see-through. For
subcortical atlases, 0.1-0.2 gives enough context without obscuring the
structures underneath.

## White matter tracts

The `tracula` atlas works with
[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md)
too. Tracts render as tube meshes:

``` r

ggsegray(atlas = tracula()) |>
  add_glassbrain(opacity = 0.1) |>
  pan_camera("right lateral")

rgl::snapshot3d("img/ray-tracula.png")
rgl::close3d()
```

![White matter tracts as coloured tubes inside a faint cortical outline,
viewed from the right
side.](img/ray-tracula.png "TRACULA tracts in rgl with glass brain")

White matter tracts as coloured tubes inside a faint cortical outline,
viewed from the right side.

Direction-based RGB colouring with `tract_color = "orientation"`:

``` r

ggsegray(atlas = tracula(), tract_color = "orientation") |>
  add_glassbrain(opacity = 0.1) |>
  pan_camera("left lateral") |>
  set_background("black")

rgl::snapshot3d("img/ray-tracula-orient.png")
rgl::close3d()
```

![Tracts coloured by fibre orientation — red, green, and blue channels
encoding direction — against a black background in
rgl.](img/ray-tracula-orient.png "Orientation-coloured tracts in rgl")

Tracts coloured by fibre orientation — red, green, and blue channels
encoding direction — against a black background in rgl.

## Material properties

[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md)
accepts a `material` argument — a named list of rgl material properties
(see
[`?rgl::material3d`](https://dmurdoch.github.io/rgl/dev/reference/material.html)
for the full list). This gives you control over lighting, reflection,
and shading without ggseg3d needing to wrap every option.

**Glossy highlights** — set `specular = "white"` (default is `"black"`
for matte):

``` r

ggsegray(
  atlas = dk(),
  hemisphere = "left",
  material = list(specular = "white", shininess = 100)
) |>
  pan_camera("left lateral")

rgl::snapshot3d("img/ray-glossy.png")
rgl::close3d()
```

![Left hemisphere with a glossy surface finish — white specular
highlights visible on the cortical
surface.](img/ray-glossy.png "Specular highlights on the cortical mesh")

Left hemisphere with a glossy surface finish — white specular highlights
visible on the cortical surface.

**Flat colours (no lighting)** — set `lit = FALSE` to disable all
shading. Every vertex renders at its exact assigned colour. Essential
for mask extraction where shadows would contaminate the output:

``` r

highlight <- tibble(
  region = "precentral",
  highlight = "#FF0000"
)

ggsegray(
  .data = highlight,
  atlas = dk(),
  hemisphere = "left",
  colour_by = "highlight",
  na_colour = "#FFFFFF",
  material = list(lit = FALSE)
) |>
  pan_camera("left lateral") |>
  set_background("white")

rgl::snapshot3d("img/ray-flat.png")
rgl::close3d()
```

![Left hemisphere with precentral gyrus in solid red and all other
regions in white — no shading, no shadows, exact colour
reproduction.](img/ray-flat.png "Flat unlit render for mask extraction")

Left hemisphere with precentral gyrus in solid red and all other regions
in white — no shading, no shadows, exact colour reproduction.

**Wireframe** — set `front = "lines"` for a wireframe view of the mesh
geometry:

``` r

ggsegray(
  atlas = dk(),
  hemisphere = "left",
  material = list(front = "lines")
) |>
  pan_camera("left lateral")

rgl::snapshot3d("img/ray-wireframe.png")
rgl::close3d()
```

![Left hemisphere rendered as a wireframe — the triangular mesh
structure visible with each region in a different line
colour.](img/ray-wireframe.png "Wireframe view of the cortical mesh")

Left hemisphere rendered as a wireframe — the triangular mesh structure
visible with each region in a different line colour.

Any property accepted by
[`rgl::material3d()`](https://dmurdoch.github.io/rgl/dev/reference/material.html)
can go in the `material` list — `ambient`, `emission`, `smooth`,
`alpha`, `lwd`, and more.

## Going further

Everything below works on any rgl scene produced by
[`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md).
Some use rayshader for rendering, others are plain rgl.

### Depth of field

Depth of field blurs regions away from a focal point, pulling attention
to a specific structure. `render_depth()` applies this as a
post-processing step on a snapshot:

``` r

ggsegray(
  .data = some_data,
  atlas = dk(),
  colour_by = "p",
  hemisphere = "left"
) |>
  pan_camera("left lateral")

rayshader::render_depth(
  filename = "depth_of_field.png",
  focus = 0.5,
  focallength = 200,
  fstop = 4,
  width = 600,
  height = 450
)
rgl::close3d()
```

`focus` (0-1) controls where the focal plane sits in the depth buffer.
`focallength` and `fstop` control the strength of the blur — lower
f-stop means shallower depth of field, just like a real camera lens.

### Adding labels

Place text labels directly in the 3D scene with
[`rgl::text3d()`](https://dmurdoch.github.io/rgl/dev/reference/texts.html):

``` r

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")

rgl::text3d(x = -45, y = 10, z = 55, text = "precentral", cex = 0.8)

rgl::snapshot3d("labelled.png")
rgl::close3d()
```

### Camera animation

[`rgl::movie3d()`](https://dmurdoch.github.io/rgl/dev/reference/play3d.html)
spins the camera around the scene and writes frames to a GIF — handy for
conference talks or supplementary materials:

``` r

ggsegray(
  .data = some_data,
  atlas = dk(),
  colour_by = "p",
  hemisphere = "left"
) |>
  pan_camera("left lateral")

rgl::movie3d(
  rgl::spin3d(axis = c(0, 1, 0), rpm = 10),
  duration = 3,
  dir = tempdir(),
  movie = "brain_spin",
  type = "gif",
  clean = TRUE
)
rgl::close3d()
```

Adjust `duration` and `rpm` to control length and speed. For higher
quality, use
[`rayshader::render_movie()`](https://www.rayshader.com/reference/render_movie.html)
which ray-traces each frame:

``` r

rayshader::render_movie(
  filename = "brain_rotate.mp4",
  frames = 360,
  fps = 30,
  zoom = 0.8,
  phi = 30
)
```

### Combining views

For multi-panel figures, render each view separately and stitch them
together with magick:

``` r

library(magick)

views <- c("left lateral", "left medial", "right lateral", "right medial")
files <- paste0("panel_", gsub(" ", "_", views, fixed = TRUE), ".png")

for (i in seq_along(views)) {
  hemi <- if (grepl("left", views[i], fixed = TRUE)) "left" else "right"

  ggsegray(
    .data = some_data,
    atlas = dk(),
    colour_by = "p",
    hemisphere = hemi
  ) |>
    pan_camera(views[i]) |>
    set_background("white")

  rayshader::render_highquality(
    filename = files[i],
    samples = 256,
    width = 800,
    height = 600
  )

  rgl::close3d()
}

panels <- image_read(files)
combined <- image_montage(panels, geometry = "800x600", tile = "2x2")
image_write(combined, "figure_all_views.png")

file.remove(files)
```

## Workflow summary

A typical publication workflow:

1.  **Explore** interactively with
    [`ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.md)
    in the htmlwidget viewer
2.  **Switch** to
    [`ggsegray()`](https://ggsegverse.github.io/ggseg3d/reference/ggsegray.md)
    once you have settled on atlas, data, and colour scheme
3.  **Draft** with
    [`rgl::snapshot3d()`](https://dmurdoch.github.io/rgl/dev/reference/snapshot.html)
    to iterate on camera angle and lighting
4.  **Render** with `render_highquality()` for the final figure
5.  **Combine** panels with magick if needed
