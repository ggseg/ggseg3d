#' Check if atlas is a unified ggseg_atlas
#'
#' Checks whether an atlas object is a ggseg_atlas with the unified format
#' (containing vertices or meshes component for 3D rendering).
#'
#' Unified atlases (ggseg_atlas class from ggseg.formats) contain:
#' - core: region info (hemi, region, label)
#' - data: type-specific data object
#'   (ggseg_data_cortical, ggseg_data_subcortical, ggseg_data_tract)
#' - palette: colours keyed by label
#'
#' @param atlas An atlas object to check
#'
#' @return Logical indicating if this is a unified ggseg_atlas
#' @noRd
#' @keywords internal
#' \dontrun{
#' is_unified_atlas(dk())
#' is_unified_atlas(ggseg.formats::dk())
#' }
is_unified_atlas <- function(atlas) {
  if (!inherits(atlas, "ggseg_atlas") && !inherits(atlas, "brain_atlas")) {
    return(FALSE)
  }

  has_core <- !is.null(atlas$core)

  has_atlas_data <- inherits(atlas$data, "ggseg_atlas_data") ||
    inherits(atlas$data, "brain_atlas_data")

  if (has_atlas_data) {
    has_3d <- !is.null(atlas$data$vertices) ||
      !is.null(atlas$data$meshes) ||
      !is.null(atlas$data$centerlines)
    return(has_core && has_3d)
  }

  has_3d_data <- !is.null(atlas$vertices) || !is.null(atlas$meshes)
  has_core && has_3d_data
}


#' Prepare atlas data
#'
#' Extracts and prepares data from a ggseg_atlas object for rendering.
#' Joins vertices with core region info and palette colours.
#'
#' @param atlas A ggseg_atlas object
#' @param .data Optional user data to merge
#'
#' @return Prepared data frame with hemi, region, label, colour, and vertices
#' @keywords internal
prepare_atlas_data <- function(atlas, .data) {
  vertices <- if (!is.null(atlas$data$vertices)) {
    atlas$data$vertices
  } else {
    atlas$vertices
  }
  atlas_data <- dplyr::left_join(
    vertices,
    atlas$core,
    by = "label",
    relationship = "many-to-many"
  )

  if (!is.null(atlas$palette)) {
    atlas_data$colour <- atlas$palette[atlas_data$label]
  } else {
    atlas_data$colour <- NA_character_
  }

  if (!is.null(.data)) {
    atlas_data <- merge_atlas_data(.data, atlas_data)
  }

  atlas_data
}


#' Prepare mesh-based atlas data
#'
#' Extracts and prepares data from a mesh-based ggseg_atlas object
#' (subcortical/tract) for rendering. Joins meshes with core region info
#' and palette colours.
#'
#' @param atlas A mesh-based ggseg_atlas object
#' @param .data Optional user data to merge
#'
#' @return Prepared data frame with hemi, region, label, colour, and mesh
#' @keywords internal
prepare_mesh_atlas_data <- function(atlas, .data) {
  if (!is.null(atlas$data$centerlines)) {
    base_data <- atlas$data$centerlines[, "label", drop = FALSE]
  } else {
    base_data <- if (!is.null(atlas$data$meshes)) {
      atlas$data$meshes
    } else {
      atlas$meshes
    }
  }

  atlas_data <- dplyr::left_join(
    base_data,
    atlas$core,
    by = "label",
    relationship = "many-to-many"
  )

  if (!is.null(atlas$palette)) {
    atlas_data$colour <- atlas$palette[atlas_data$label]
  } else {
    atlas_data$colour <- NA_character_
  }

  if (!is.null(.data)) {
    atlas_data <- data_merge_mesh(.data, atlas_data)
  }

  atlas_data
}


#' Merge user data with mesh atlas data
#'
#' @param .data User-provided data frame
#' @param atlas_data Atlas data frame
#' @return Merged data frame
#' @keywords internal
data_merge_mesh <- function(.data, atlas_data) {
  join_cols <- intersect(c("region", "label", "hemi"), names(.data))

  if (length(join_cols) == 0) {
    cli::cli_warn("No common columns found for merging data with atlas")
    return(atlas_data)
  }

  dplyr::left_join(
    atlas_data,
    .data,
    by = join_cols,
    relationship = "many-to-many"
  )
}


#' Merge legend data from surface and deep cerebellar components
#' @noRd
merge_legend_data <- function(surface_legend, deep_legend) {
  if (is.null(surface_legend) && is.null(deep_legend)) {
    return(NULL)
  }
  if (is.null(surface_legend)) {
    return(deep_legend)
  }
  if (is.null(deep_legend)) {
    return(surface_legend)
  }

  combined <- rbind(surface_legend, deep_legend)
  combined[!duplicated(combined$label), , drop = FALSE]
}
