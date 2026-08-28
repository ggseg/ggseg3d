#' Apply colour palette
#'
#' Processes colour mapping for ggseg_atlas objects using
#' vertex-based colouring.
#'
#' @param colour Column name for colour values
#'
#' @return List with data, fill column name, palette, and colour metadata
#' @inheritParams apply_colours_and_legend
#' @keywords internal
#' @noRd
apply_colour_palette <- function(
  atlas_data,
  colour,
  palette,
  na_colour
) {
  pal_colours <- get_palette(palette)
  is_numeric <- colour %in%
    names(atlas_data) &&
    is.numeric(atlas_data[[colour]])
  data_min <- NA
  data_max <- NA

  if (is_numeric) {
    data_min <- min(atlas_data[[colour]], na.rm = TRUE)
    data_max <- max(atlas_data[[colour]], na.rm = TRUE)

    if (data_min == data_max) {
      atlas_data$new_col <- pal_colours$orig[1]
    } else {
      if (is.null(names(palette))) {
        pal_colours$values <- seq(
          data_min,
          data_max,
          length.out = nrow(pal_colours)
        )
      }
      atlas_data$new_col <- scales::gradient_n_pal(
        pal_colours$orig,
        pal_colours$values,
        "Lab"
      )(atlas_data[[colour]])
    }
    fill <- "new_col"
  } else {
    fill <- colour
  }

  atlas_data$colour <- vapply(
    atlas_data[[fill]],
    function(c) {
      if (is.na(c)) {
        na_colour
      } else if (grepl("^#", c)) {
        c
      } else {
        col2hex(c)
      }
    },
    character(1)
  )

  list(
    data = atlas_data,
    fill = fill,
    palette = pal_colours,
    is_numeric = is_numeric,
    data_min = data_min,
    data_max = data_max
  )
}
