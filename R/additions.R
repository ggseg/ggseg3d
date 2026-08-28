#' Add glass brain to ggseg3d plot
#'
#' Adds a translucent brain surface to a ggseg3d plot for anatomical reference.
#' Particularly useful for subcortical and tract visualizations where spatial
#' context helps interpretation. Works with both htmlwidget (`ggseg3d`) and
#' rgl (`ggsegray`) objects.
#'
#' @param p A `ggseg3d` widget or `ggsegray` rgl object.
#' @param hemisphere Character vector. Hemispheres to add: "left", "right",
#'   or both.
#' @param surface Character. Surface type. Defaults to `"inflated"`, which
#'   is supplied by `ggseg.formats` and requires no additional dependency.
#'   Other surfaces (`"pial"`, `"white"`, etc.) are drawn from `ggseg.meshes`.
#' @param colour Character. Colour for the glass brain surface (hex or named).
#' @param opacity Numeric. Transparency of the glass brain (0-1).
#' @param brain_meshes Optional user-supplied brain meshes. See
#'   [ggseg.formats::get_brain_mesh()] for format details.
#'
#' @return The input object (modified), for piping.
#' @export
#'
#' @examples
#' \donttest{
#' ggseg3d(atlas = aseg()) |>
#'   add_glassbrain("left", opacity = 0.2)
#' }
#' \dontrun{
#' # rgl requires OpenGL; not run in check environments.
#' ggsegray(atlas = aseg()) |>
#'   add_glassbrain(opacity = 0.15) |>
#'   pan_camera("right lateral")
#' }
add_glassbrain <- function(
  p,
  hemisphere = c("left", "right"),
  surface = "inflated",
  colour = "#CCCCCC",
  opacity = 0.3,
  brain_meshes = NULL
) {
  is_rgl <- inherits(p, "ggsegray")

  if (is_rgl) {
    check_ggsegray(p)
  } else {
    check_ggseg3d(p)
    existing <- p$x$meshes %||% list()
    if (any(vapply(existing, function(m) isTRUE(m$isFlatmap), logical(1)))) {
      cli::cli_warn(c(
        "Skipping glassbrain: widget contains a flat (2D) mesh.",
        "i" = "Flatmap surfaces share no coordinate frame with anatomical
          meshes; combining them produces misaligned geometry."
      ))
      return(p)
    }
  }

  colour <- if (grepl("^#", colour)) colour else col2hex(colour)
  hemi_map <- c("left" = "lh", "right" = "rh")
  cortical_hemis <- intersect(hemisphere, c("left", "right"))

  entries <- lapply(cortical_hemis, function(hemi) {
    hemi_short <- hemi_map[hemi]
    mesh <- resolve_brain_mesh(
      hemisphere = hemi_short,
      surface = surface,
      brain_meshes = brain_meshes
    )

    if (is.null(mesh)) {
      cli::cli_warn(
        "Brain mesh not available for {.val {hemi}} {.val {surface}}. Skipping."
      )
      return(NULL)
    }

    make_mesh_entry(
      name = paste("glass brain", hemi),
      vertices = mesh$vertices,
      faces = mesh$faces,
      colors = rep(colour, nrow(mesh$vertices)),
      color_mode = "vertexcolor",
      opacity = opacity
    )
  })
  entries <- Filter(Negate(is.null), entries)

  if (is_rgl) {
    lapply(entries, function(entry) {
      mesh3d <- mesh_entry_to_mesh3d(entry) # nolint [object_usage_linter]
      rgl::shade3d(mesh3d)
    })
  } else {
    p$x$meshes <- c(entries, p$x$meshes)
  }

  p
}


#' Pan camera position of ggseg3d plot
#'
#' Sets the camera position for a ggseg3d widget or ggsegray rgl scene
#' to standard anatomical views or custom positions.
#'
#' @param p A `ggseg3d` widget or `ggsegray` rgl object.
#' @param camera string, list, or numeric vector. Camera position preset
#'   name, custom eye position list, or `c(x, y, z)` for rgl.
#'
#' \strong{Available camera presets:}
#' \itemize{
#' \item `left lateral` or `left_lateral`
#' \item `left medial` or `left_medial`
#' \item `right lateral` or `right_lateral`
#' \item `right medial` or `right_medial`
#' \item `left superior` or `left_superior`
#' \item `right superior` or `right_superior`
#' \item `left inferior` or `left_inferior`
#' \item `right inferior` or `right_inferior`
#' \item `left anterior` or `left_anterior`
#' \item `right anterior` or `right_anterior`
#' \item `left posterior` or `left_posterior`
#' \item `right posterior` or `right_posterior`
#' }
#'
#' @return The input object (modified), for piping.
#' @export
#'
#' @examples
#' ggseg3d() |> pan_camera("right lateral")
#' \dontrun{
#' # rgl requires OpenGL; not run in check environments.
#' ggsegray(atlas = dk(), hemisphere = "left") |>
#'   pan_camera("left lateral")
#' }
pan_camera <- function(p, camera) {
  if (inherits(p, "ggsegray")) {
    check_ggsegray(p)

    cam_pos <- if (is.numeric(camera)) {
      camera
    } else if (is.character(camera)) {
      camera_preset_to_position(camera) # nolint [object_usage_linter]
    } else {
      cli::cli_abort(c(
        "{.arg camera} must be a character string or numeric vector,",
        "not {.obj_type_friendly {camera}}."
      ))
    }

    um <- look_at_origin(cam_pos) # nolint [object_usage_linter]
    rgl::view3d(userMatrix = um, fov = 0)
    return(p)
  }

  check_ggseg3d(p)
  if (!is.character(camera) && !is.list(camera)) {
    cli::cli_abort(c(
      "{.arg camera} must be a character string or list,",
      "not {.obj_type_friendly {camera}}."
    ))
  }

  p$x$options$camera <- camera
  p
}


#' Set background color of ggseg3d plot
#'
#' Changes the background color of a ggseg3d widget or ggsegray rgl scene.
#'
#' @param p A `ggseg3d` widget or `ggsegray` rgl object.
#' @param colour string. Background color (hex or named color)
#'
#' @return The input object (modified), for piping.
#' @export
#'
#' @examples
#' ggseg3d() |> set_background("black")
#' \dontrun{
#' # rgl requires OpenGL; not run in check environments.
#' ggsegray(atlas = dk()) |> set_background("black")
#' }
set_background <- function(p, colour = "#ffffff") {
  if (inherits(p, "ggsegray")) {
    check_ggsegray(p)
    if (!grepl("^#", colour)) {
      colour <- col2hex(colour)
    }
    rgl::bg3d(color = colour)
    return(p)
  }

  check_ggseg3d(p)

  if (!grepl("^#", colour)) {
    colour <- col2hex(colour)
  }

  p$x$options$backgroundColor <- colour
  p
}


#' Set legend visibility
#'
#' For htmlwidget output, toggles legend visibility. For rgl output,
#' draws or removes the legend overlay.
#'
#' @param p A ggseg3d or ggsegray object
#' @param show logical. Whether to show the legend (default: TRUE)
#'
#' @return The input object, modified
#' @export
#'
#' @examples
#' ggseg3d() |> set_legend(FALSE)
#' \dontrun{
#' # rgl requires OpenGL; not run in check environments.
#' ggsegray(hemisphere = "left") |> set_legend()
#' }
set_legend <- function(p, show = TRUE) {
  if (inherits(p, "ggsegray")) {
    check_ggsegray(p)
    if (show && !is.null(p$legend_data)) {
      render_legend_rgl(p$legend_data)
    }
    return(p)
  }

  check_ggseg3d(p)
  p$x$options$showLegend <- show
  p
}


#' Set widget dimensions
#'
#' Changes the width and height of a ggseg3d widget.
#'
#' @param p ggseg3d widget object
#' @param width numeric. Widget width in pixels (NULL for default)
#' @param height numeric. Widget height in pixels (NULL for default)
#'
#' @return ggseg3d widget object with updated dimensions
#' @export
#'
#' @examples
#' ggseg3d() |>
#'   set_dimensions(width = 800, height = 600)
set_dimensions <- function(p, width = NULL, height = NULL) {
  check_ggseg3d(p)
  if (!is.null(width)) {
    p$width <- width
  }
  if (!is.null(height)) {
    p$height <- height
  }
  p
}


#' Set region boundary edges
#'
#' Adds coloured outlines around brain regions. This is useful for
#' highlighting region boundaries in figures. Works with both
#' htmlwidget (`ggseg3d`) and rgl (`ggsegray`) objects. For rgl,
#' edges must have been computed at creation time via `edge_by`.
#'
#' @param p A `ggseg3d` widget or `ggsegray` rgl object.
#' @param colour string. Edge colour (hex or named color). Set to NULL to
#'   hide edges.
#' @param width numeric. Width of edge lines (default: 1). Note: line width > 1
#'   may not render on all systems due to WebGL limitations.
#'
#' @return The input object (modified), for piping.
#' @export
#'
#' @section Lifecycle:
#' `r lifecycle::badge("experimental")`
#'
#' @examples
#' ggseg3d(hemisphere = "left", edge_by = "region") |>
#'   set_edges("black") |>
#'   pan_camera("left lateral")
#' \dontrun{
#' # rgl requires OpenGL; not run in check environments.
#' ggsegray(hemisphere = "left", edge_by = "region") |>
#'   set_edges("red", width = 2) |>
#'   pan_camera("left lateral")
#' }
set_edges <- function(p, colour = "black", width = 1) {
  lifecycle::signal_stage("experimental", "set_edges()")

  if (inherits(p, "ggsegray")) {
    check_ggsegray(p)

    if (length(p$edge_ids) > 0) {
      lapply(p$edge_ids, function(eid) rgl::pop3d(id = eid))
      p$edge_ids <- integer(0)
    }

    if (!is.null(colour)) {
      edge_col <- if (grepl("^#", colour)) colour else col2hex(colour)
      p$edge_ids <- unlist(lapply(p$meshes, function(mesh_entry) {
        render_edges_rgl(mesh_entry, colour = edge_col, width = width)
      }))
    }

    return(p)
  }

  check_ggseg3d(p)

  if (is.null(colour)) {
    p$x$meshes <- lapply(p$x$meshes, function(mesh) {
      mesh$edgeColor <- NULL
      mesh$edgeWidth <- NULL
      mesh
    })
  } else {
    edge_col <- if (grepl("^#", colour)) colour else col2hex(colour)
    p$x$meshes <- lapply(p$x$meshes, function(mesh) {
      mesh$edgeColor <- edge_col
      mesh$edgeWidth <- width
      mesh
    })
  }
  p
}


#' Enable flat shading for ggseg3d plot
#'
#' Disables lighting effects to show colors exactly as specified.
#' Useful for screenshots where accurate color reproduction is needed,
#' such as atlas creation pipelines that extract contours from images.
#'
#' @param p ggseg3d widget object
#' @param flat logical. Enable flat shading (default: TRUE)
#'
#' @return ggseg3d widget object with updated shading
#' @export
#'
#' @examples
#' ggseg3d() |>
#'   set_flat_shading()
set_flat_shading <- function(p, flat = TRUE) {
  check_ggseg3d(p)
  p$x$options$flatShading <- flat
  p
}


#' Enable orthographic camera for ggseg3d plot
#'
#' Uses orthographic projection instead of perspective. This eliminates
#' perspective distortion and ensures consistent sizing across all views.
#'
#' @param p ggseg3d widget object
#' @param ortho logical. Enable orthographic mode (default: TRUE)
#' @param frustum_size numeric. Size of the orthographic frustum. Controls
#'   how much of the scene is visible. Default 220 works well for brain meshes.
#'   Use the same value across all views for consistent sizing.
#'
#' @return ggseg3d widget object with updated camera mode
#' @export
#'
#' @examples
#' ggseg3d() |>
#'   set_orthographic()
set_orthographic <- function(p, ortho = TRUE, frustum_size = 220) {
  check_ggseg3d(p)
  p$x$options$orthographic <- ortho
  p$x$options$frustumSize <- frustum_size
  p
}


#' Set hemisphere positioning mode
#'
#' Repositions cortical hemisphere meshes in a ggseg3d widget. Meshes are
#' produced with anatomical positioning by default (medial edges at x = 0).
#' Use this to centre each hemisphere at the origin for atlas-creation
#' snapshots, or to reapply anatomical positioning after manual edits.
#'
#' @param p ggseg3d widget object
#' @param positioning How to position hemispheres:
#'   - "anatomical": Medial surfaces adjacent at midline. Left at negative
#'     x, right at positive x. Default for displaying both hemispheres
#'     together.
#'   - "centered": Centre each hemisphere at the origin. Best for
#'     single-hemisphere snapshots where consistent sizing is needed.
#'
#' @details Only cortical hemisphere meshes are repositioned (those named
#'   `"<hemi> <surface>"`, e.g. `"left inflated"`). Subcortical, cerebellar
#'   and glassbrain meshes are left untouched.
#'
#' @return ggseg3d widget object with repositioned meshes
#' @export
#'
#' @examples
#' # View both hemispheres anatomically positioned (default)
#' ggseg3d(hemisphere = c("left", "right")) |>
#'   pan_camera("left lateral")
#'
#' # Atlas creation: centered for consistent sizing
#' ggseg3d(hemisphere = "left") |>
#'   set_positioning("centered") |>
#'   set_orthographic() |>
#'   pan_camera("left lateral")
set_positioning <- function(p, positioning = c("anatomical", "centered")) {
  check_ggseg3d(p)
  positioning <- match.arg(positioning)

  surface_pattern <- paste0(
    "^(left|right) ",
    "(inflated|semi-inflated|white|pial|midthickness|",
    "sphere|smoothwm|orig)$"
  )

  p$x$meshes <- lapply(p$x$meshes, function(mesh) {
    name <- mesh$name %||% ""
    if (!grepl(surface_pattern, name)) {
      return(mesh)
    }

    is_left <- startsWith(name, "left ")
    vertices <- mesh$vertices
    x_range <- range(vertices$x)
    x_center <- mean(x_range)
    half_width <- (x_range[2] - x_range[1]) / 2

    vertices$x <- vertices$x - x_center
    if (positioning == "anatomical") {
      vertices$x <- vertices$x +
        if (is_left) -half_width else half_width
    }

    mesh$vertices <- vertices
    mesh
  })

  p
}


#' Save ggseg3d widget as image
#'
#' Takes a screenshot of a ggseg3d widget and saves it as a PNG image.
#' Requires a Chrome-based browser to be installed.
#'
#' @param p ggseg3d widget object
#' @param file string. Output file path (should end in .png)
#' @param width numeric. Image width in pixels (default: 600)
#' @param height numeric. Image height in pixels (default: 500)
#' @param delay numeric. Seconds to wait for widget to render before capture
#'   (default: 1)
#' @param zoom numeric. Zoom factor for higher resolution (default: 2)
#' @param ... Additional arguments passed to webshot2::webshot
#'
#' @return The file path (invisibly)
#' @export
#' @importFrom webshot2 webshot
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   pan_camera("left lateral") |>
#'   snapshot_brain("brain.png")
#' }
# nocov start
snapshot_brain <- function(
  p,
  file,
  width = 600,
  height = 500,
  delay = 1,
  zoom = 2,
  ...
) {
  check_ggseg3d(p)

  tmpfile <- tempfile(fileext = ".html")
  on.exit(unlink(tmpfile), add = TRUE)

  htmlwidgets::saveWidget(p, tmpfile, selfcontained = TRUE)

  webshot2::webshot(
    url = tmpfile,
    file = file,
    vwidth = width,
    vheight = height,
    delay = delay,
    zoom = zoom,
    ...
  )

  invisible(file)
}
# nocov end
