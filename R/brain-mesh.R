#' Resolve brain surface mesh
#'
#' Resolves and prepares a brain surface mesh for rendering. Delegates to
#' [ggseg.formats::get_brain_mesh()] for inflated surfaces and to
#' [ggseg.meshes::get_cortical_mesh()] for pial, white, semi-inflated, and
#' other surfaces. Returned meshes use the shared anatomical axis convention
#' (`x` = left-right, `y` = anterior-posterior, `z` = superior-inferior) with
#' `lh` positioned at `x <= 0` and `rh` at `x >= 0`, medial edges meeting at
#' the midline (`x = 0`).
#'
#' @param hemisphere `"lh"` or `"rh"`
#' @param surface Surface type: `"inflated"`, `"semi-inflated"`, `"white"`,
#'   `"pial"`, `"sphere"`, `"smoothwm"`, `"orig"`
#' @param brain_meshes Optional user-supplied mesh data. Passed through to
#'   [ggseg.formats::get_brain_mesh()] for format details.
#'
#' @return list with vertices (data.frame with x, y, z) and faces
#'   (data.frame with i, j, k), or NULL if mesh not found
#'
#' @examples
#' mesh <- resolve_brain_mesh("lh", "inflated")
#' str(mesh, max.level = 1)
#'
#' @export
resolve_brain_mesh <- function(
  hemisphere = c("lh", "rh"),
  surface = c(
    "inflated",
    "semi-inflated",
    "white",
    "pial",
    "sphere",
    "smoothwm",
    "orig"
  ),
  brain_meshes = NULL
) {
  hemisphere <- match.arg(hemisphere)
  surface <- match.arg(surface)

  from_ggseg_meshes <- is.null(brain_meshes) && surface != "inflated"

  if (!from_ggseg_meshes) {
    mesh <- ggseg.formats::get_brain_mesh(hemisphere, surface, brain_meshes)
  } else {
    check_ggseg_meshes(surface)
    mesh <- ggseg.meshes::get_cortical_mesh(hemisphere, surface)
  }

  if (is.null(mesh)) {
    return(NULL)
  }

  if (min(mesh$faces$i) == 0) {
    mesh$faces$i <- mesh$faces$i + 1L
    mesh$faces$j <- mesh$faces$j + 1L
    mesh$faces$k <- mesh$faces$k + 1L
  }

  normalize_cortical_mesh(mesh, hemisphere, from_ggseg_meshes)
}


check_ggseg_meshes <- function(surface) {
  if (!requireNamespace("ggseg.meshes", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg ggseg.meshes} is required for {.val {surface}}.",
      "i" = "Install with: {.run install.packages('ggseg.meshes')}"
    ))
  }
}


# ggseg.meshes surfaces are stored rotated 90 deg CCW relative to FreeSurfer
# native axes (see ggseg.meshes/data-raw/make_cortical_meshes.R): stored
# `x` = AP, stored `y` = -LR, stored `z` = SI. ggseg.formats inflated and
# subcortical/cerebellar meshes already use native axes (x = LR, y = AP,
# z = SI). After axis alignment we shift each hemisphere so medial edges sit
# at x = 0 — LH occupies x <= 0, RH occupies x >= 0 — so both hemispheres
# display side-by-side without overlap regardless of surface choice.
normalize_cortical_mesh <- function(mesh, hemisphere, rotate_axes) {
  if (rotate_axes) {
    v <- mesh$vertices
    mesh$vertices$x <- -v$y
    mesh$vertices$y <- v$x
  }

  mesh$vertices$x <- if (hemisphere == "lh") {
    mesh$vertices$x - max(mesh$vertices$x)
  } else {
    mesh$vertices$x - min(mesh$vertices$x)
  }

  mesh
}


#' Map atlas vertex indices to mesh colors
#'
#' Given a ggseg_atlas with vertices column and a brain mesh, creates a color
#' vector for each mesh vertex based on which region it belongs to.
#'
#' @param atlas_data Data frame with region, colour, and vertices columns
#' @param n_vertices Number of vertices in the mesh
#' @param na_colour Color for vertices not in any region
#'
#' @return Character vector of colors, one per mesh vertex
#' @keywords internal
vertices_to_colors <- function(
  atlas_data,
  n_vertices,
  na_colour = "#CCCCCC"
) {
  vertex_colors <- rep(na_colour, n_vertices)

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    region_colour <- atlas_data$colour[i]

    if (length(region_vertices) > 0 && !is.na(region_colour)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_colors[idx] <- region_colour
    }
  }

  vertex_colors
}


#' Map atlas vertex indices to region labels
#'
#' Given a ggseg_atlas with vertices column and a brain mesh, creates a label
#' vector for each mesh vertex based on which region it belongs to.
#'
#' @param atlas_data Data frame with region and vertices columns
#' @param n_vertices Number of vertices in the mesh
#' @param na_label Label for vertices not in any region
#'
#' @return Character vector of labels, one per mesh vertex
#' @keywords internal
vertices_to_labels <- function(
  atlas_data,
  n_vertices,
  na_label = NA_character_
) {
  vertex_labels <- rep(na_label, n_vertices)

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    region_label <- atlas_data$region[i]

    if (length(region_vertices) > 0 && !is.na(region_label)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_labels[idx] <- region_label
    }
  }

  vertex_labels
}


#' Map vertices to text values for hover display
#'
#' Assigns text values to mesh vertices based on a column in atlas data.
#' Used for per-vertex hover text in the Three.js tooltip.
#'
#' @param atlas_data Data frame with vertices list column
#' @param n_vertices Number of vertices in the mesh
#' @param text_col Name of the column containing text values
#'
#' @return Character vector of text values, one per mesh vertex
#' @keywords internal
vertices_to_text <- function(atlas_data, n_vertices, text_col) {
  vertex_text <- rep(NA_character_, n_vertices)

  if (!text_col %in% names(atlas_data)) {
    return(vertex_text)
  }

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    val <- as.character(atlas_data[[text_col]][i])

    if (length(region_vertices) > 0 && !is.na(val)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_text[idx] <- paste0(text_col, ": ", val)
    }
  }

  vertex_text
}


#' Map vertices to group values for edge detection
#'
#' Assigns group values to mesh vertices based on a column in atlas data.
#' Used for computing boundary edges between different groups rather than
#' between different colors.
#'
#' @param atlas_data Data frame with vertices list column and grouping column
#' @param n_vertices Total number of vertices in the mesh
#' @param group_col Name of the column containing group values
#' @param na_group Value for vertices not in any region
#'
#' @return Character vector of group values, one per mesh vertex
#' @noRd
#' @keywords internal
vertices_to_groups <- function(
  atlas_data,
  n_vertices,
  group_col,
  na_group = NA_character_
) {
  vertex_groups <- rep(na_group, n_vertices)

  if (!group_col %in% names(atlas_data)) {
    cli::cli_abort(
      "Column {.val {group_col}} not found in atlas data."
    )
  }

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    region_group <- as.character(atlas_data[[group_col]][i])

    if (length(region_vertices) > 0 && !is.na(region_group)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_groups[idx] <- region_group
    }
  }

  vertex_groups
}


#' Build mesh list for cortical atlases
#'
#' Creates mesh data structures for cortical ggseg_atlas objects using
#' shared brain meshes with vertex-based colouring.
#'
#' @param atlas_data Prepared atlas data frame
#' @param hemisphere Hemispheres to include
#' @param surface Surface type
#' @param na_colour Colour for NA values
#' @param edge_by Column for edge grouping (or NULL)
#' @param brain_meshes Optional user-supplied brain meshes
#'
#' @return List of mesh data structures
#' @importFrom rlang .data
#' @keywords internal
build_cortical_meshes <- function(
  atlas_data,
  hemisphere,
  surface,
  na_colour,
  edge_by,
  brain_meshes = NULL,
  text_by = NULL,
  label_by = "region"
) {
  hemi_map <- c("right" = "rh", "left" = "lh")

  meshes <- lapply(hemisphere, function(current_hemi) {
    hemi_short <- hemi_map[current_hemi]
    mesh <- resolve_brain_mesh(
      hemisphere = hemi_short,
      surface = surface,
      brain_meshes = brain_meshes
    )

    if (is.null(mesh)) {
      cli::cli_warn(
        "Brain mesh not found for {.val {hemi_short}} {.val {surface}}."
      )
      return(NULL)
    }

    hemi_data <- dplyr::filter(atlas_data, .data$hemi == current_hemi)
    if (nrow(hemi_data) == 0) {
      return(NULL)
    }

    n_vertices <- nrow(mesh$vertices)
    vertex_colors <- vertices_to_colors(hemi_data, n_vertices, na_colour)
    vertex_labels <- vertices_to_labels(hemi_data, n_vertices, na_label = "")

    vertex_texts <- if (!is.null(text_by)) {
      vertices_to_text(hemi_data, n_vertices, text_by)
    }

    if (!is.null(edge_by)) {
      edge_groups <- vertices_to_groups(hemi_data, n_vertices, edge_by)
      boundary <- find_boundary_edges(mesh$faces, edge_groups)
    } else {
      boundary <- find_boundary_edges(mesh$faces, vertex_colors)
    }

    edge_color <- if (!is.null(edge_by)) "#000000" else NULL

    make_mesh_entry(
      name = paste(current_hemi, surface),
      vertices = mesh$vertices,
      faces = mesh$faces,
      colors = vertex_colors,
      color_mode = "vertexcolor",
      boundary_edges = boundary,
      edge_color = edge_color,
      vertex_labels = vertex_labels,
      vertex_texts = vertex_texts
    )
  })

  Filter(Negate(is.null), meshes)
}


#' Build mesh list for cerebellar atlases
#'
#' Creates mesh data structures for cerebellar ggseg_atlas objects using
#' the shared SUIT cerebellar surface with vertex-based colouring.
#'
#' @param atlas_data Prepared atlas data frame with vertices column
#' @param na_colour Colour for NA values
#' @param text_by Column for hover text (or NULL)
#' @param label_by Column for vertex labels
#' @param opacity Numeric opacity for the mesh (0 = transparent, 1 = opaque)
#'
#' @return List of mesh data structures
#' @keywords internal
build_cerebellar_meshes <- function(
  atlas_data,
  na_colour,
  text_by = NULL,
  label_by = "region",
  opacity = 1
) {
  mesh <- ggseg.formats::get_cerebellar_mesh()

  if (is.null(mesh)) {
    cli::cli_abort("SUIT cerebellar mesh not available.")
  }

  if (min(mesh$faces$i) == 0) {
    mesh$faces$i <- mesh$faces$i + 1L
    mesh$faces$j <- mesh$faces$j + 1L
    mesh$faces$k <- mesh$faces$k + 1L
  }

  n_vertices <- nrow(mesh$vertices)
  vertex_colors <- vertices_to_colors(atlas_data, n_vertices, na_colour)
  vertex_labels <- vertices_to_labels(
    atlas_data,
    n_vertices,
    na_label = ""
  )

  vertex_texts <- if (!is.null(text_by)) {
    vertices_to_text(atlas_data, n_vertices, text_by)
  }

  boundary <- find_boundary_edges(mesh$faces, vertex_colors)

  entry <- make_mesh_entry(
    name = "cerebellum",
    vertices = mesh$vertices,
    faces = mesh$faces,
    colors = vertex_colors,
    color_mode = "vertexcolor",
    opacity = opacity,
    boundary_edges = boundary,
    vertex_labels = vertex_labels,
    vertex_texts = vertex_texts
  )

  if (is_flat_mesh(mesh$vertices)) {
    entry$isFlatmap <- TRUE
  }

  list(entry)
}


# A flatmap mesh has all vertices in a single plane (negligible extent on one
# axis). Used to detect cerebellar flatmaps that cannot be combined with
# other 3D meshes.
is_flat_mesh <- function(vertices, tol = 1) {
  any(
    c(
      diff(range(vertices$x)),
      diff(range(vertices$y)),
      diff(range(vertices$z))
    ) <
      tol
  )
}


#' Build mesh list for subcortical atlases
#'
#' Creates mesh data structures for subcortical atlases with per-region mesh
#' data using face-based colouring (each structure is a separate mesh).
#'
#' @param atlas_data Prepared atlas data frame with label, colour, and mesh
#'   columns
#' @param na_colour Colour for NA values
#'
#' @return List of mesh data structures
#' @keywords internal
build_subcortical_meshes <- function(
  atlas_data,
  na_colour,
  text_by = NULL,
  label_by = "region"
) {
  meshes <- lapply(seq_len(nrow(atlas_data)), function(i) {
    mesh_data <- atlas_data$mesh[[i]]
    if (is.null(mesh_data)) {
      return(NULL)
    }

    colour <- atlas_data$colour[i]
    if (is.na(colour)) {
      colour <- na_colour
    }
    colour <- unname(ifelse(grepl("^#", colour), colour, col2hex(colour)))

    region_name <- if (label_by %in% names(atlas_data)) {
      atlas_data[[label_by]][i]
    } else {
      atlas_data$label[i]
    }

    hover <- NULL
    if (!is.null(text_by) && text_by %in% names(atlas_data)) {
      val <- atlas_data[[text_by]][i]
      if (!is.na(val)) hover <- paste0(text_by, ": ", val)
    }

    make_mesh_entry(
      name = region_name,
      vertices = mesh_data$vertices,
      faces = mesh_data$faces,
      colors = rep(colour, nrow(mesh_data$faces)),
      color_mode = "facecolor",
      hover_text = hover
    )
  })

  Filter(Negate(is.null), meshes)
}


#' Build mesh list for tract atlases
#'
#' Creates mesh data structures for tract atlases with per-vertex colouring.
#' Supports palette colours (uniform per tract) or orientation-based RGB
#' colours computed from centerline tangent vectors.
#'
#' @param atlas_data Prepared atlas data frame with label, colour, and mesh
#'   columns
#' @param na_colour Colour for NA values
#' @param color_by How to colour tracts: "colour" (use colour column),
#'   "orientation" (direction-based RGB from tangents)
#'
#' @return List of mesh data structures
#' @keywords internal
build_tract_meshes <- function(
  atlas_data,
  na_colour,
  color_by = "colour",
  atlas_centerlines = NULL,
  text_by = NULL,
  label_by = "region"
) {
  has_centerlines <- !is.null(atlas_centerlines) &&
    !is.null(atlas_centerlines$centerlines)
  has_legacy_meshes <- "mesh" %in% names(atlas_data)

  if (!has_centerlines && !has_legacy_meshes) {
    cli::cli_warn("No centerlines or meshes found for tract atlas")
    return(list())
  }

  meshes <- lapply(seq_len(nrow(atlas_data)), function(i) {
    label <- atlas_data$label[i]

    if (has_centerlines) {
      cl_idx <- which(atlas_centerlines$centerlines$label == label)
      if (length(cl_idx) == 0) {
        return(NULL)
      }

      centerline <- atlas_centerlines$centerlines$points[[cl_idx]]
      tangents <- atlas_centerlines$centerlines$tangents[[cl_idx]]

      mesh_data <- generate_tube_mesh(
        centerline = centerline,
        radius = atlas_centerlines$tube_radius,
        segments = atlas_centerlines$tube_segments
      )
      mesh_data$metadata$tangents <- tangents
    } else {
      mesh_data <- atlas_data$mesh[[i]]
      if (is.null(mesh_data)) return(NULL)
    }

    n_vertices <- nrow(mesh_data$vertices)

    if (color_by == "orientation" && !is.null(mesh_data$metadata$tangents)) {
      vertex_colors <- tangents_to_colors(mesh_data)
    } else {
      colour <- atlas_data$colour[i]
      if (is.na(colour)) {
        colour <- na_colour
      }
      colour <- unname(ifelse(grepl("^#", colour), colour, col2hex(colour)))
      vertex_colors <- rep(colour, n_vertices)
    }

    tract_name <- if (label_by %in% names(atlas_data)) {
      atlas_data[[label_by]][i]
    } else {
      label
    }

    hover <- NULL
    if (!is.null(text_by) && text_by %in% names(atlas_data)) {
      val <- atlas_data[[text_by]][i]
      if (!is.na(val)) hover <- paste0(text_by, ": ", val)
    }

    make_mesh_entry(
      name = tract_name,
      vertices = mesh_data$vertices,
      faces = mesh_data$faces,
      colors = vertex_colors,
      color_mode = "vertexcolor",
      hover_text = hover
    )
  })

  Filter(Negate(is.null), meshes)
}


#' Convert tangent vectors to orientation RGB colours
#'
#' Computes direction-based RGB colours from centerline tangent vectors.
#' Standard tractography colouring: R = left-right (x),
#' G = anterior-posterior (y), B = superior-inferior (z).
#'
#' @param mesh_data Mesh data with vertices data.frame and metadata list
#' @return Character vector of hex colours (one per mesh vertex)
#' @keywords internal
tangents_to_colors <- function(mesh_data) {
  metadata <- mesh_data$metadata
  n_centerline <- metadata$n_centerline_points
  tangents <- metadata$tangents

  n_vertices <- nrow(mesh_data$vertices)
  n_segments <- as.integer(n_vertices / n_centerline)

  abs_tangents <- abs(tangents)
  row_max <- apply(abs_tangents, 1, max)
  row_max[row_max == 0] <- 1
  normalized <- abs_tangents / row_max

  centerline_colors <- grDevices::rgb(
    normalized[, 1],
    normalized[, 2],
    normalized[, 3]
  )

  rep(centerline_colors, each = n_segments)
}


# Tube mesh generation ----

#' Generate tube mesh from centerline
#'
#' Creates a 3D tube mesh around a centerline path using parallel transport
#' frames for smooth geometry without twisting artifacts.
#'
#' @param centerline Matrix with N rows and 3 columns (x, y, z coordinates)
#' @param radius Tube radius. Either a single value or vector of length N.
#' @param segments Number of segments around tube circumference.
#' @return List with vertices (data.frame), faces (data.frame), and metadata
#' @keywords internal
generate_tube_mesh <- function(centerline, radius = 0.5, segments = 8) {
  if (!is.matrix(centerline) || nrow(centerline) < 2) {
    cli::cli_abort("centerline must be a matrix with at least 2 rows")
  }

  n_points <- nrow(centerline)
  frames <- compute_parallel_transp_fr(centerline)

  if (length(radius) == 1) {
    radius <- rep(radius, n_points)
  }

  n_vertices <- n_points * segments
  n_faces <- (n_points - 1) * segments * 2

  vertices <- matrix(0, nrow = n_vertices, ncol = 3)
  faces <- matrix(0L, nrow = n_faces, ncol = 3)

  angles <- seq(0, 2 * pi, length.out = segments + 1)[1:segments]

  for (i in seq_len(n_points)) {
    center <- centerline[i, ]
    normal <- frames$normals[i, ]
    binormal <- frames$binormals[i, ]
    r <- radius[i]

    for (j in seq_len(segments)) {
      angle <- angles[j]
      offset <- r * (cos(angle) * normal + sin(angle) * binormal)
      vertex_idx <- (i - 1) * segments + j
      vertices[vertex_idx, ] <- center + offset
    }
  }

  face_idx <- 1
  for (i in seq_len(n_points - 1)) {
    for (j in seq_len(segments)) {
      j_next <- if (j == segments) 1L else j + 1L

      v1 <- (i - 1L) * segments + j
      v2 <- (i - 1L) * segments + j_next
      v3 <- i * segments + j
      v4 <- i * segments + j_next

      faces[face_idx, ] <- c(v1, v2, v3)
      faces[face_idx + 1L, ] <- c(v2, v4, v3)
      face_idx <- face_idx + 2L
    }
  }

  list(
    vertices = data.frame(
      x = vertices[, 1],
      y = vertices[, 2],
      z = vertices[, 3]
    ),
    faces = data.frame(i = faces[, 1], j = faces[, 2], k = faces[, 3]),
    metadata = list(
      n_centerline_points = n_points,
      centerline = centerline,
      tangents = frames$tangents
    )
  )
}


#' Compute parallel transport frames along curve
#' @keywords internal
compute_parallel_transp_fr <- function(curve) {
  # nolint: object_length_linter
  n <- nrow(curve)

  tangents <- matrix(0, nrow = n, ncol = 3)
  for (i in seq_len(n - 1)) {
    tangents[i, ] <- curve[i + 1, ] - curve[i, ]
    len <- sqrt(sum(tangents[i, ]^2))
    if (len > 0) tangents[i, ] <- tangents[i, ] / len
  }
  tangents[n, ] <- tangents[n - 1, ]

  t0 <- tangents[1, ]
  arbitrary <- if (abs(t0[1]) < 0.9) c(1, 0, 0) else c(0, 1, 0)
  n0 <- cross_product(t0, arbitrary)
  n0 <- n0 / sqrt(sum(n0^2))

  normals <- matrix(0, nrow = n, ncol = 3)
  binormals <- matrix(0, nrow = n, ncol = 3)

  normals[1, ] <- n0
  binormals[1, ] <- cross_product(t0, n0)

  for (i in seq_len(n - 1)) {
    t_curr <- tangents[i, ]
    t_next <- tangents[i + 1, ]

    cross_t <- cross_product(t_curr, t_next)
    cross_norm <- sqrt(sum(cross_t^2))

    if (cross_norm < 1e-10) {
      normals[i + 1, ] <- normals[i, ]
      binormals[i + 1, ] <- binormals[i, ]
    } else {
      axis <- cross_t / cross_norm
      angle <- acos(max(-1, min(1, sum(t_curr * t_next))))

      normals[i + 1, ] <- rotate_vector(normals[i, ], axis, angle)
      normals[i + 1, ] <- normals[i + 1, ] / sqrt(sum(normals[i + 1, ]^2))
      binormals[i + 1, ] <- cross_product(t_next, normals[i + 1, ])
    }
  }

  list(tangents = tangents, normals = normals, binormals = binormals)
}


#' Cross product of two 3D vectors
#' @keywords internal
cross_product <- function(a, b) {
  c(
    a[2] * b[3] - a[3] * b[2],
    a[3] * b[1] - a[1] * b[3],
    a[1] * b[2] - a[2] * b[1]
  )
}


#' Rotate vector around axis by angle (Rodrigues' formula)
#' @keywords internal
rotate_vector <- function(v, axis, angle) {
  cos_a <- cos(angle)
  sin_a <- sin(angle)
  v *
    cos_a +
    cross_product(axis, v) * sin_a +
    axis * sum(axis * v) * (1 - cos_a)
}
