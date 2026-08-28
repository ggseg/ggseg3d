#' ggseg3d: Plot brain segmentations in 3D
#'
#' Plotting results from analyses done on data derived from brain
#' segmentations is a common need, but may be quite laborious.
#' Results from such analyses are usually easier to interpret if
#' the plot can mimmick the shape and position in the brain it
#' represents.
#'
#' This package contains data from various brain parcellations,
#' with convenient functions to inspect the results directly on
#' a brain-plot using interactive 3D mesh visualizations powered
#' by Three.js via htmlwidgets.
#'
#' The package uses `ggseg_atlas` objects from ggseg.formats
#' that contain 3D vertex mappings.
#'
#' @name ggseg3d-package
#' @docType package
#' @keywords internal
#' @importFrom ggseg.formats dk aseg tracula
"_PACKAGE"

#' @export
ggseg.formats::dk

#' @export
ggseg.formats::aseg

#' @export
ggseg.formats::tracula
