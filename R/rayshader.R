#' Render brain atlas with rgl
#'
#' Creates an rgl 3D scene from a brain atlas. Uses the same atlas
#' preparation pipeline as [ggseg3d()] but outputs to rgl instead of
#' htmlwidgets. The resulting scene can be piped into [pan_camera()],
#' [add_glassbrain()], and [set_background()], then rendered with
#' rayshader's `render_highquality()` or captured with `rgl::snapshot3d()`.
#'
#' @inheritParams ggseg3d
#' @param material Named list of rgl material properties passed to
#'   [rgl::tmesh3d()]. Controls how the mesh surface is shaded.
#'
#' @section Material properties:
#' Useful material list entries:
#' \describe{
#'   \item{`specular`}{`"black"` (matte) or `"white"` (glossy).}
#'   \item{`shininess`}{Specular exponent. Higher = tighter highlights.}
#'   \item{`lit`}{`FALSE` disables lighting.}
#'   \item{`alpha`}{Transparency, 0 (invisible) to 1 (opaque).}
#'   \item{`smooth`}{`TRUE` for Gouraud shading, `FALSE` for flat.}
#' }
#'
#' See [rgl::material3d()] for the full list.
#'
#' @template type-specific-args
#'
#' @return An object of class `ggsegray` (invisibly), which wraps the
#'   rgl device ID. Pipe into [pan_camera()], [add_glassbrain()], or
#'   [set_background()] to modify the scene.
#'
#' @importFrom graphics par plot.new plot.window rect text
#'
#' @examples
#' \dontrun{
#' # rgl requires OpenGL; not run in check environments.
#' ggsegray(hemisphere = "left") |>
#'   pan_camera("left lateral")
#'
#' ggsegray(atlas = aseg()) |>
#'   add_glassbrain(opacity = 0.15) |>
#'   pan_camera("right lateral") |>
#'   set_background("black")
#' }
#'
#' @export
ggsegray <- function(
  .data = NULL,
  atlas = dk(), # nolint [object_usage_linter]
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  material = list(),
  ...,
  label = deprecated(),
  text = deprecated(),
  colour = deprecated()
) {
  if (lifecycle::is_present(label)) {
    lifecycle::deprecate_warn(
      "2.1.0",
      "ggsegray(label=)",
      "ggsegray(label_by=)"
    )
    label_by <- label
  }
  if (lifecycle::is_present(text)) {
    lifecycle::deprecate_warn("2.1.0", "ggsegray(text=)", "ggsegray(text_by=)")
    text_by <- text
  }
  if (lifecycle::is_present(colour)) {
    lifecycle::deprecate_warn(
      "2.1.0",
      "ggsegray(colour=)",
      "ggsegray(colour_by=)"
    )
    colour_by <- colour
  }
  rlang::check_installed("rgl", reason = "to render 3D brain scenes with rgl")

  if (!inherits(atlas, "ggseg_atlas") && !inherits(atlas, "brain_atlas")) {
    cli::cli_abort(
      "{.arg atlas} must be a {.cls ggseg_atlas} object,
      not {.obj_type_friendly {atlas}}."
    )
  }

  if (!is_unified_atlas(atlas)) {
    cli::cli_abort(c(
      "{.arg atlas} is a {.cls ggseg_atlas} but has no 3D data.",
      "i" = "Use atlases from {.pkg ggseg.formats}
      that include vertex or mesh data."
    ))
  }

  prepared <- prepare_brain_meshes(
    atlas,
    .data = .data,
    label_by = label_by,
    text_by = text_by,
    colour_by = colour_by,
    palette = palette,
    na_colour = na_colour,
    na_alpha = na_alpha,
    ...
  )

  rgl::open3d()

  edge_ids <- unlist(lapply(prepared$meshes, function(mesh_entry) {
    mesh3d <- do.call(mesh_entry_to_mesh3d, c(list(mesh_entry), material))
    rgl::shade3d(mesh3d)
    render_edges_rgl(mesh_entry)
  }))

  structure(
    list(
      device = rgl::cur3d(),
      legend_data = prepared$legend_data,
      meshes = prepared$meshes,
      edge_ids = edge_ids
    ),
    class = "ggsegray"
  )
}


#' @noRd
#' @export
print.ggsegray <- function(x, ...) {
  rgl::set3d(x$device)
  print(rgl::rglwidget())
  invisible(x)
}

#' @noRd
#' @importFrom knitr knit_print
#' @export
knit_print.ggsegray <- function(x, ...) {
  # nocov start
  invisible(x)
} # nocov end

#' Convert mesh entry to rgl mesh3d object
#'
#' Converts the internal mesh_entry list structure (as built by
#' [make_mesh_entry()]) into an [rgl::tmesh3d()] object for rgl rendering.
#'
#' @param mesh_entry A mesh entry list with vertices, faces, colors,
#'   colorMode, and opacity.
#' @param ... Material properties merged into the `material` list of
#'   [rgl::tmesh3d()]. Overrides defaults (`specular = "black"`,
#'   `shininess = 128`). See [rgl::material3d()] for all options.
#'
#' @return An rgl `mesh3d` object
#' @keywords internal
#' @noRd
mesh_entry_to_mesh3d <- function(mesh_entry, ...) {
  rlang::check_installed("rgl", reason = "to convert meshes")

  vb <- rbind(
    mesh_entry$vertices$x,
    mesh_entry$vertices$y,
    mesh_entry$vertices$z,
    1
  )

  it <- rbind(
    mesh_entry$faces$i + 1L,
    mesh_entry$faces$j + 1L,
    mesh_entry$faces$k + 1L
  )

  mesh_color <- if (mesh_entry$colorMode == "vertexcolor") {
    "vertices"
  } else {
    "faces"
  }

  alpha <- mesh_entry$opacity %||% 1

  material <- list(
    color = mesh_entry$colors,
    alpha = alpha,
    specular = "black",
    shininess = 128
  )
  extra <- list(...)
  material[names(extra)] <- extra

  rgl::tmesh3d(
    vertices = vb,
    indices = it,
    material = material,
    meshColor = mesh_color
  )
}


#' Map camera preset name to position vector
#'
#' Converts a camera preset string to an xyz position vector matching
#' the same presets used in the Three.js viewer.
#'
#' @param preset Character string naming the camera preset.
#'
#' @return Numeric vector of length 3 (x, y, z).
#' @keywords internal
#' @noRd
camera_preset_to_position <- function(preset) {
  presets <- list(
    "left lateral" = c(-350, 0, 0),
    "left_lateral" = c(-350, 0, 0),
    "left medial" = c(350, 0, 0),
    "left_medial" = c(350, 0, 0),
    "right lateral" = c(350, 0, 0),
    "right_lateral" = c(350, 0, 0),
    "right medial" = c(-350, 0, 0),
    "right_medial" = c(-350, 0, 0),
    "left superior" = c(-120, 0, 330),
    "left_superior" = c(-120, 0, 330),
    "right superior" = c(120, 0, 330),
    "right_superior" = c(120, 0, 330),
    "left inferior" = c(-120, 0, -330),
    "left_inferior" = c(-120, 0, -330),
    "right inferior" = c(120, 0, -330),
    "right_inferior" = c(120, 0, -330),
    "left anterior" = c(-120, 330, 0),
    "left_anterior" = c(-120, 330, 0),
    "right anterior" = c(120, 330, 0),
    "right_anterior" = c(120, 330, 0),
    "left posterior" = c(-120, -330, 0),
    "left_posterior" = c(-120, -330, 0),
    "right posterior" = c(120, -330, 0),
    "right_posterior" = c(120, -330, 0)
  )

  pos <- presets[[preset]]
  if (is.null(pos)) {
    available <- unique(gsub("_", " ", names(presets))) # nolint: object_usage_linter
    cli::cli_abort(c(
      "Unknown camera preset {.val {preset}}.",
      "i" = "Available presets: {.val {available}}"
    ))
  }

  pos
}


#' Compute rgl rotation matrix to look at the origin from a given position
#'
#' Builds a 4x4 rotation matrix suitable for `rgl::view3d(userMatrix = ...)`
#' that orients the scene as if the camera is at `eye` looking toward the
#' origin with z pointing up.
#'
#' @param eye Numeric vector of length 3 (x, y, z) — camera position.
#'
#' @return A 4x4 rotation matrix.
#' @keywords internal
#' @noRd
look_at_origin <- function(eye) {
  eye_n <- eye / sqrt(sum(eye^2))

  up <- c(0, 0, 1)
  if (abs(eye_n[3]) > 0.999) {
    up <- c(0, 1, 0)
  }

  fwd <- -eye_n
  right <- c(
    fwd[2] * up[3] - fwd[3] * up[2],
    fwd[3] * up[1] - fwd[1] * up[3],
    fwd[1] * up[2] - fwd[2] * up[1]
  )
  right <- right / sqrt(sum(right^2))

  actual_up <- c(
    right[2] * fwd[3] - right[3] * fwd[2],
    right[3] * fwd[1] - right[1] * fwd[3],
    right[1] * fwd[2] - right[2] * fwd[1]
  )

  m <- diag(4)
  m[1, 1:3] <- right
  m[2, 1:3] <- actual_up
  m[3, 1:3] <- eye_n
  m
}


render_edges_rgl <- function(mesh_entry, colour = NULL, width = NULL) {
  edges <- mesh_entry$boundaryEdges
  if (is.null(edges) || length(edges) == 0) {
    return(invisible(NULL))
  }

  edge_color <- colour %||% mesh_entry$edgeColor
  if (is.null(edge_color)) {
    return(invisible(NULL))
  }

  edge_width <- width %||% mesh_entry$edgeWidth %||% 1
  verts <- mesh_entry$vertices

  edge_matrix <- do.call(rbind, edges)
  idx1 <- edge_matrix[, 1] + 1L
  idx2 <- edge_matrix[, 2] + 1L

  cx <- mean(verts$x)
  cy <- mean(verts$y)
  cz <- mean(verts$z)
  nudge <- 0.3

  edge_x <- c(verts$x[idx1], verts$x[idx2])
  edge_y <- c(verts$y[idx1], verts$y[idx2])
  edge_z <- c(verts$z[idx1], verts$z[idx2])
  dx <- edge_x - cx
  dy <- edge_y - cy
  dz <- edge_z - cz
  d <- sqrt(dx^2 + dy^2 + dz^2)
  d[d == 0] <- 1
  edge_x <- edge_x + nudge * dx / d
  edge_y <- edge_y + nudge * dy / d
  edge_z <- edge_z + nudge * dz / d

  n <- length(idx1)
  x <- as.vector(rbind(edge_x[seq_len(n)], edge_x[n + seq_len(n)]))
  y <- as.vector(rbind(edge_y[seq_len(n)], edge_y[n + seq_len(n)]))
  z <- as.vector(rbind(edge_z[seq_len(n)], edge_z[n + seq_len(n)]))

  id <- rgl::segments3d(x, y, z, color = edge_color, lwd = edge_width)
  invisible(id)
}


check_ggsegray <- function(
  p,
  arg = rlang::caller_arg(p),
  call = rlang::caller_env()
) {
  if (!inherits(p, "ggsegray")) {
    cli::cli_abort(
      "{.arg {arg}} must be a {.cls ggsegray} object, not {.obj_type_friendly {p}}.", # nolint: line_length_linter
      call = call
    )
  }
  rlang::check_installed("rgl", reason = "to modify rgl scenes")
  rgl::set3d(p$device)
}


render_legend_rgl <- function(legend_data) {
  if (legend_data$type == "continuous") {
    render_continuous_legend_rgl(legend_data)
  } else if (legend_data$type == "discrete") {
    render_discrete_legend_rgl(legend_data)
  }
}


render_continuous_legend_rgl <- function(legend_data) {
  colors <- legend_data$colors
  title <- legend_data$title
  data_min <- legend_data$min
  data_max <- legend_data$max

  rgl::bgplot3d({
    par(mar = c(0, 0, 0, 0))
    plot.new()
    plot.window(xlim = c(0, 1), ylim = c(0, 1))

    bar_x <- 0.88
    bar_w <- 0.03
    bar_y0 <- 0.25
    bar_y1 <- 0.75
    n_steps <- 100

    y_seq <- seq(bar_y0, bar_y1, length.out = n_steps + 1)
    col_fn <- grDevices::colorRampPalette(colors)
    bar_cols <- col_fn(n_steps)

    invisible(lapply(seq_len(n_steps), function(i) {
      rect(
        bar_x,
        y_seq[i],
        bar_x + bar_w,
        y_seq[i + 1],
        col = bar_cols[i],
        border = NA
      )
    }))
    rect(bar_x, bar_y0, bar_x + bar_w, bar_y1, border = "black", lwd = 0.5)

    tick_x <- bar_x + bar_w + 0.005
    text(
      tick_x,
      bar_y0,
      format(data_min, digits = 2),
      adj = c(0, 0.5),
      cex = 0.7
    )
    text(
      tick_x,
      bar_y1,
      format(data_max, digits = 2),
      adj = c(0, 0.5),
      cex = 0.7
    )

    text(
      bar_x + bar_w / 2,
      bar_y1 + 0.03,
      title,
      adj = c(0.5, 0),
      cex = 0.8,
      font = 2
    )
  })
}


render_discrete_legend_rgl <- function(legend_data) {
  labels <- legend_data$labels
  colors <- legend_data$colors
  title <- legend_data$title

  n <- length(labels)
  max_show <- min(n, 30)
  labels <- labels[seq_len(max_show)]
  colors <- colors[seq_len(max_show)]

  rgl::bgplot3d({
    par(mar = c(0, 0, 0, 0))
    plot.new()
    plot.window(xlim = c(0, 1), ylim = c(0, 1))

    box_size <- 0.015
    line_h <- 0.025
    col_x <- 0.82
    top_y <- 0.95

    text(
      col_x + box_size + 0.005,
      top_y,
      title,
      adj = c(0, 0.5),
      cex = 0.7,
      font = 2
    )

    invisible(lapply(seq_len(max_show), function(i) {
      y <- top_y - i * line_h
      rect(
        col_x,
        y - box_size / 2,
        col_x + box_size,
        y + box_size / 2,
        col = colors[i],
        border = "grey50",
        lwd = 0.3
      )
      text(
        col_x + box_size + 0.005,
        y,
        labels[i],
        adj = c(0, 0.5),
        cex = 0.55
      )
    }))
  })
}
