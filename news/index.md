# Changelog

## ggseg3d (development version)

- Test fixtures now resolve region names dynamically via
  [`ggseg.formats::atlas_regions()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_regions.html)
  instead of hard-coding schema-specific strings, so `ggseg3d` checks
  cleanly against both the released and development `ggseg.formats`
  atlas schema. Geometry snapshots skip on CRAN.

- [`print()`](https://rdrr.io/r/base/print.html) on a `ggsegray` object
  now returns the object invisibly, as print methods are expected to. It
  still renders the scene; only the return value changed, and piping was
  never supported off [`print()`](https://rdrr.io/r/base/print.html).

## ggseg3d 2.1.2

CRAN release: 2026-07-02

- decouples tests from ggseg.formats internal workings.
- No user changes.

## ggseg3d 2.1.1

CRAN release: 2026-04-22

### Bug fixes

- Cortical hemispheres are now rendered anatomically side-by-side (LH at
  negative x, RH at positive x, medial edges at the midline) regardless
  of the mesh source. Previously, both hemispheres overlapped at the
  origin because `ggseg.formats` inflated meshes and `ggseg.meshes`
  pial/white/etc. surfaces arrived in different axis conventions.
  [`resolve_brain_mesh()`](https://ggsegverse.github.io/ggseg3d/reference/resolve_brain_mesh.md)
  now normalises to the shared `x = LR`, `y = AP`, `z = SI` frame and
  separates hemispheres at `x = 0`.
- [`set_positioning()`](https://ggsegverse.github.io/ggseg3d/reference/set_positioning.md)
  no longer wrongly shifts subcortical meshes whose region names happen
  to contain “Left”/“Right” (e.g. `Left-Thalamus`); it only repositions
  cortical meshes named `"<hemi> <surface>"`.
- [`add_glassbrain()`](https://ggsegverse.github.io/ggseg3d/reference/add_glassbrain.md)
  warns and skips when the widget already contains a flat (2D) mesh such
  as a cerebellar flatmap, since flatmaps share no coordinate frame with
  anatomical 3D meshes.
- [`add_glassbrain()`](https://ggsegverse.github.io/ggseg3d/reference/add_glassbrain.md)
  now defaults to `surface = "inflated"` so it works without
  `ggseg.meshes` installed (inflated ships with `ggseg.formats`).

### Documentation

- Replaced `\dontrun{}` wrappers in widget-construction examples with
  executable code so examples run under `R CMD check` and render inline
  in pkgdown. Examples that require `rgl` (Suggests) are now gated with
  `@examplesIf rlang::is_installed("rgl")`.
- Added `LICENSE.note` documenting the bundled Three.js and
  OrbitControls libraries and credited their authors in `Authors@R`.

### Internal

- Removed the `native_offset()` / `to_native_coords()` /
  `position_hemisphere()` helpers. They were workarounds for the
  previous axis-convention mismatch and are no longer needed now that
  all meshes share a single frame.

## ggseg3d 2.1.0

CRAN release: 2026-04-09

### Cerebellar atlas support

- New `cerebellar_atlas` class with
  [`prepare_brain_meshes.cerebellar_atlas()`](https://ggsegverse.github.io/ggseg3d/reference/prepare_brain_meshes.md)
  method for rendering SUIT cerebellar surfaces with vertex-based
  colouring.
- Mixed vertex+mesh rendering for deep cerebellar nuclei: the SUIT
  surface renders at 30% opacity with opaque per-region meshes for deep
  structures.
- `surface_opacity` parameter controls cerebellar surface transparency
  when deep nuclei are present.
- Cortical mesh data moved to the ‘ggseg.meshes’ package, removing
  bundled `sysdata.rda`.

## ggseg3d 2.0.0

CRAN release: 2026-02-20

### Major changes

- Complete rewrite using htmlwidgets with Three.js instead of plotly
- New pipe-friendly API with chainable addition functions
- Support for unified brain_atlas format from ggseg.formats package

### New features

- [`set_background()`](https://ggsegverse.github.io/ggseg3d/reference/set_background.md) -
  set background colour
- [`set_legend()`](https://ggsegverse.github.io/ggseg3d/reference/set_legend.md) -
  control legend visibility
- [`set_dimensions()`](https://ggsegverse.github.io/ggseg3d/reference/set_dimensions.md) -
  set widget width and height
- [`set_edges()`](https://ggsegverse.github.io/ggseg3d/reference/set_edges.md) -
  add region boundary edges
- [`set_flat_shading()`](https://ggsegverse.github.io/ggseg3d/reference/set_flat_shading.md) -
  disable lighting for exact colours
- [`set_orthographic()`](https://ggsegverse.github.io/ggseg3d/reference/set_orthographic.md) -
  use orthographic projection
- [`pan_camera()`](https://ggsegverse.github.io/ggseg3d/reference/pan_camera.md) -
  position camera at standard anatomical views
- [`add_glassbrain()`](https://ggsegverse.github.io/ggseg3d/reference/add_glassbrain.md) -
  add translucent brain surface overlay
- [`snapshot_brain()`](https://ggsegverse.github.io/ggseg3d/reference/snapshot_brain.md) -
  save widget as PNG image
- `edge.by` parameter for edge grouping by data columns

### Breaking changes

- Removed plotly dependency
- ggseg3d_atlas objects are deprecated (still supported with warning)

## ggseg3d 1.6.3

CRAN release: 2021-06-01

- Prepare for CRAN
- Remove white surface from `dk_3d` to reduce size and pass CRAN checks
- Update github urls to new org

## ggseg3d 1.6.02

- Fix bug where installing with vignettes fails

## ggseg3d 1.6.01

- Added ellipsis `...` to plotly::add_trace for people to add more
  arguments

## ggseg3d 1.5.2

- Adapted to work with dplyr 0.8.1

## ggseg3d 1.5.1

- Changed ggseg_atlas-class to have nested columns for easier viewing
  and wrangling

## ggseg3d 1.5

- Changed atlas.info to function `atlas_info()`
- Changed brain.pal to function `brain_pal()`
- Reduced code necessary for `brain_pals_info`
- Simplified `display_brain_pal()`
- Moved palettes of ggseg.extra atlases to ggseg.extra package
- Added a `NEWS.md` file to track changes to the package
- Changes all `data` options to `.data` to decrease possibility of
  column naming overlap
- Added compatibility with `grouped` data.frames
- Reduced internal atlases, to improve CRAN compatibility
- Added function to install extra atlases from github easily
- Changes vignettes to comply with new functionality
