#' Create ggseg3d htmlwidget
#'
#' Creates the final htmlwidget object with default options and sizing policy.
#'
#' @param meshes List of mesh data structures
#' @param legend_data Legend specification (or NULL)
#'
#' @return An htmlwidget object of class "ggseg3d"
#' @keywords internal
#' @noRd
create_ggseg3d_widget <- function(meshes, legend_data) {
  options <- list(
    camera = "right lateral",
    showLegend = TRUE,
    backgroundColor = "#ffffff"
  )

  x <- list(
    meshes = meshes,
    options = options,
    colorbar = legend_data
  )

  htmlwidgets::createWidget(
    name = "ggseg3d",
    x = x,
    package = "ggseg3d",
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = 600,
      defaultHeight = 500,
      viewer.defaultHeight = 500,
      viewer.defaultWidth = 600,
      browser.defaultHeight = 500,
      browser.defaultWidth = 600,
      knitr.defaultWidth = 600,
      knitr.defaultHeight = 500,
      padding = 0,
      browser.fill = TRUE
    )
  )
}
