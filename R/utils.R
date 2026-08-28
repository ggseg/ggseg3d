check_ggseg3d <- function(
  p,
  arg = rlang::caller_arg(p),
  call = rlang::caller_env()
) {
  if (!inherits(p, "ggseg3d")) {
    cli::cli_abort(
      "{.arg {arg}} must be a {.cls ggseg3d} widget, not {.obj_type_friendly {p}}.", # nolint: line_length_linter
      call = call
    )
  }
}


#' @importFrom dplyr left_join
#' @noRd
merge_atlas_data <- function(.data, atlas_data) {
  cols <- names(atlas_data)[names(atlas_data) %in% names(.data)]

  if (length(cols) == 0) {
    cli::cli_abort(c(
      "No common columns between data and atlas.",
      "i" = "Atlas has: {.field {names(atlas_data)}}",
      "i" = "Data has: {.field {names(.data)}}"
    ))
  }

  merged <- dplyr::left_join(
    atlas_data,
    .data,
    by = cols,
    relationship = "many-to-many"
  )

  unmatched <- .data[!.data[[cols[1]]] %in% atlas_data[[cols[1]]], ]
  if (nrow(unmatched) > 0) {
    unmatched_vals <- unique(unmatched[[cols[1]]]) # nolint: object_usage_linter
    cli::cli_warn(c(
      "Some data rows did not match atlas regions.",
      "i" = "Unmatched: {.val {unmatched_vals}}",
      "i" = "Check for spelling mistakes in: {.field {cols[1]}}"
    ))
  }

  merged
}


col2hex <- function(colour) {
  col <- grDevices::col2rgb(colour)
  grDevices::rgb(
    red = col[1, ] / 255,
    green = col[2, ] / 255,
    blue = col[3, ] / 255
  )
}


make_mesh_entry <- function(
  name,
  vertices,
  faces,
  colors,
  color_mode = "vertexcolor",
  opacity = 1,
  hover_text = NULL,
  boundary_edges = NULL,
  edge_color = NULL,
  edge_width = NULL,
  vertex_labels = NULL,
  vertex_texts = NULL
) {
  entry <- list(
    name = name,
    vertices = list(
      x = unname(as.numeric(vertices$x)),
      y = unname(as.numeric(vertices$y)),
      z = unname(as.numeric(vertices$z))
    ),
    faces = list(
      i = unname(as.integer(faces$i - 1L)),
      j = unname(as.integer(faces$j - 1L)),
      k = unname(as.integer(faces$k - 1L))
    ),
    colors = unname(colors),
    colorMode = color_mode,
    opacity = opacity,
    hoverText = hover_text
  )

  if (!is.null(boundary_edges)) {
    entry$boundaryEdges <- boundary_edges
  }

  if (!is.null(edge_color)) {
    entry$edgeColor <- edge_color
    entry$edgeWidth <- edge_width %||% 1
  }

  if (!is.null(vertex_labels)) {
    entry$vertexLabels <- unname(vertex_labels)
  }

  if (!is.null(vertex_texts)) {
    entry$vertexTexts <- unname(vertex_texts)
  }

  entry
}


find_boundary_edges <- function(faces, vertex_colors) {
  i <- faces$i
  j <- faces$j
  k <- faces$k

  all_v1 <- c(i, j, k)
  all_v2 <- c(j, k, i)

  color1 <- vertex_colors[all_v1]
  color2 <- vertex_colors[all_v2]
  is_boundary <- color1 != color2
  is_boundary[is.na(is_boundary)] <- FALSE

  boundary_v1 <- all_v1[is_boundary]
  boundary_v2 <- all_v2[is_boundary]

  if (length(boundary_v1) == 0) {
    return(list())
  }

  min_v <- pmin(boundary_v1, boundary_v2)
  max_v <- pmax(boundary_v1, boundary_v2)

  n_vertices <- max(c(boundary_v1, boundary_v2))
  edge_keys <- min_v + (max_v - 1L) * n_vertices

  unique_idx <- !duplicated(edge_keys)
  unique_v1 <- boundary_v1[unique_idx]
  unique_v2 <- boundary_v2[unique_idx]

  mapply(
    function(a, b) c(a - 1L, b - 1L),
    unique_v1,
    unique_v2,
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE
  )
}


get_palette <- function(palette) {
  if (is.null(palette)) {
    palette <- c("#440154", "#21918c", "#fde725")
  }

  if (!is.null(names(palette))) {
    pal_colours <- names(palette)
    pal_values <- unname(palette)
    pal_norm <- range_norm(pal_values)
  } else {
    pal_colours <- palette
    pal_norm <- seq(0, 1, length.out = length(pal_colours))
    pal_values <- seq(0, 1, length.out = length(pal_colours))
  }

  pal_colours <- if (length(palette) == 1) {
    data.frame(
      values = c(pal_values, pal_values + 1),
      norm = c(0, 1),
      orig = c(pal_colours, pal_colours),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      values = pal_values,
      norm = pal_norm,
      orig = pal_colours,
      stringsAsFactors = FALSE
    )
  }

  pal_colours$hex <- gradient_n_pal(
    colours = pal_colours$orig,
    values = pal_colours$values,
    space = "Lab"
  )(pal_colours$values)

  pal_colours
}

range_norm <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}
