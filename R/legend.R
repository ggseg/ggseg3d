#' Build legend data structure
#'
#' Creates the appropriate legend data structure based on whether the
#' colour variable is numeric (continuous colorbar) or categorical
#' (discrete legend).
#'
#' @param is_numeric Whether the colour variable is numeric
#' @param data_min Minimum data value (for continuous)
#' @param data_max Maximum data value (for continuous)
#' @param palette Original palette specification
#' @param pal_colours Processed palette colours
#' @param colour_col Name of the colour column
#' @param label_col Name of the label column
#' @param fill_col Name of the fill column
#' @param data Atlas data
#'
#' @return List with legend specification or NULL
#' @keywords internal
#' @noRd
build_legend_data <- function(
  is_numeric,
  data_min,
  data_max,
  palette,
  pal_colours,
  colour_col,
  label_col,
  fill_col,
  data
) {
  if (is_numeric && !is.na(data_min) && data_min != data_max) {
    return(build_continuous_legend(
      palette,
      pal_colours,
      colour_col,
      data_min,
      data_max
    ))
  }

  if (!is_numeric) {
    return(build_discrete_legend(data, fill_col, label_col))
  }

  NULL
}


#' Build continuous legend
#'
#' Creates a continuous colorbar legend specification for numeric data.
#'
#' @param palette Original palette specification
#' @param pal_colours Processed palette colours
#' @param colour_col Name of the colour column (used as title)
#' @param data_min Minimum data value
#' @param data_max Maximum data value
#'
#' @return List with continuous legend specification
#' @keywords internal
#' @noRd
build_continuous_legend <- function(
  palette,
  pal_colours,
  colour_col,
  data_min,
  data_max
) {
  if (!is.null(names(palette))) {
    list(
      type = "continuous",
      title = colour_col,
      min = min(pal_colours$values),
      max = max(pal_colours$values),
      colors = unname(vapply(pal_colours$orig, col2hex, character(1))),
      breakpoints = unname(pal_colours$values)
    )
  } else {
    colorbar_values <- seq(data_min, data_max, length.out = 10)
    colorbar_colors <- scales::gradient_n_pal(
      pal_colours$orig,
      pal_colours$values,
      "Lab"
    )(colorbar_values)

    list(
      type = "continuous",
      title = colour_col,
      min = data_min,
      max = data_max,
      colors = unname(colorbar_colors),
      values = unname(colorbar_values)
    )
  }
}


#' Build discrete legend
#'
#' Creates a discrete legend specification for categorical data.
#'
#' @param data Atlas data
#' @param fill_col Name of the fill column
#' @param label_col Name of the label column
#'
#' @return List with discrete legend specification or NULL if too many
#'   categories
#' @keywords internal
#' @noRd
build_discrete_legend <- function(data, fill_col, label_col) {
  if (is.data.frame(data)) {
    unique_values <- unique(data[[fill_col]])
  } else {
    unique_values <- unique(unlist(data[, fill_col]))
  }
  unique_values <- unique_values[!is.na(unique_values)]

  if (length(unique_values) > 50) {
    return(NULL)
  }

  if (is.data.frame(data)) {
    color_label_map <- stats::setNames(
      as.character(data[[fill_col]]),
      as.character(data[[label_col]])
    )
  } else {
    color_label_map <- stats::setNames(
      as.character(unlist(data[, fill_col])),
      as.character(unlist(data[, label_col]))
    )
  }
  color_label_map <- color_label_map[!is.na(names(color_label_map))]
  color_label_map <- color_label_map[!duplicated(names(color_label_map))]

  list(
    type = "discrete",
    title = label_col,
    labels = unname(names(color_label_map)),
    colors = unname(color_label_map)
  )
}
