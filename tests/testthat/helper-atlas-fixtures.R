# Build atlas fixtures through ggseg.formats' exported constructors so tests
# exercise ggseg3d behaviour without depending on ggseg.formats' internal S3
# layout. Tests supply the meaningful data (core, vertices, meshes, ...) and
# these helpers assemble a valid ggseg_atlas.

cerebellar_atlas_fixture <- function(
  core,
  vertices = NULL,
  meshes = NULL,
  palette,
  atlas = "test_cerebellar"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "cerebellar",
    core = core,
    data = ggseg.formats::ggseg_data_cerebellar(
      vertices = vertices,
      meshes = meshes
    ),
    palette = palette
  )
}

# Minimal cerebellar atlas used by the visual/snapshot tests so they do not
# depend on external atlas packages.
make_test_cerebellar_atlas <- function() {
  vertices_data <- data.frame(
    label = c("left_I-IV", "right_I-IV"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:99L, 100L:199L)

  cerebellar_atlas_fixture(
    core = data.frame(
      label = c("left_I-IV", "right_I-IV"),
      region = c("I-IV", "I-IV"),
      hemi = c("left", "right"),
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    palette = c("left_I-IV" = "#FF0000", "right_I-IV" = "#00FF00")
  )
}

subcortical_atlas_fixture <- function(
  core,
  meshes,
  palette,
  atlas = "test_subcortical"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "subcortical",
    core = core,
    data = ggseg.formats::ggseg_data_subcortical(meshes = meshes),
    palette = palette
  )
}

tract_atlas_fixture <- function(
  core,
  centerlines = NULL,
  meshes = NULL,
  palette,
  atlas = "test_tract"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "tract",
    core = core,
    data = ggseg.formats::ggseg_data_tract(
      centerlines = centerlines,
      meshes = meshes
    ),
    palette = palette
  )
}
