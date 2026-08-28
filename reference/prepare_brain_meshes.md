# Prepare brain meshes and legend data

S3 generic that dispatches to atlas-type-specific preparation methods.
Builds mesh data structures and legend data from a \`ggseg_atlas\`.

## Usage

``` r
# S3 method for class 'cortical_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  surface = "LCBC",
  hemisphere = c("right", "left"),
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  brain_meshes = NULL,
  ...
)

# S3 method for class 'subcortical_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  ...
)

# S3 method for class 'cerebellar_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  surface_opacity = NULL,
  ...
)

# S3 method for class 'tract_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  tract_color = c("palette", "orientation"),
  tube_radius = 2,
  tube_segments = 10,
  ...
)

prepare_brain_meshes(atlas, ...)
```

## Arguments

- atlas:

  A \`ggseg_atlas\` object

- .data:

  A data.frame to use for plot aesthetics. Must include a column called
  "region" corresponding to regions.

- surface:

  Surface type: \`"inflated"\` (default), \`"semi-inflated"\`,
  \`"white"\`, \`"pial"\`. Use \`"LCBC"\` as alias for \`"inflated"\`.

- hemisphere:

  Character vector of hemispheres: \`"right"\`, \`"left"\`.

- label_by:

  String. Column name used as hover label for each region.

- text_by:

  String. Column name for extra hover text shown below the region label.

- colour_by:

  String. Column name mapped to mesh colours.

- palette:

  String. Vector of colour names or HEX colours. Can also be a named
  numeric vector, with colours as names, and breakpoint for that colour
  as the value

- na_colour:

  String. Either name, hex of RGB for colour of NA in colour.

- na_alpha:

  Numeric. A number between 0 and 1 to control transparency of
  NA-regions.

- edge_by:

  Column name for region boundary edge grouping

- brain_meshes:

  Optional user-supplied mesh data. Passed through to
  \[ggseg.formats::get_brain_mesh()\] for format details.

- ...:

  Type-specific arguments passed to methods

- surface_opacity:

  Numeric opacity for the cerebellar surface mesh. Defaults to \`0.3\`
  when deep nuclei are present and \`1\` otherwise.

- tract_color:

  \`"palette"\` (default) or \`"orientation"\` (direction-based RGB
  colouring)

- tube_radius:

  Numeric tube radius (default 5 when \`NULL\`).

- tube_segments:

  Integer tube segment count (default 8 when \`NULL\`).

## Value

List with \`meshes\` (list of mesh entries) and \`legend_data\`
