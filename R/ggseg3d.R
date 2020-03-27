#' Plot 3D brain parcellations
#'
#' \code{ggseg3d} plots and returns a plotly mesh3d object.
#' @author Athanasia Mowinckel and Didac Pineiro
#'
#' @param .data A data.frame to use for plot aesthetics. Must include a
#' column called "region" corresponding to regions.
#' @param atlas Either a string with the name of a 3d atlas to use.
#' @param hemisphere String. Hemisphere to plot. Either "left" or "right"[default],
#' can also be "subcort".
#' @param surface String. Which surface to plot. Either "pial","white", or "inflated"[default]
#' @param label String. Quoted name of column in atlas/data that should be used to name traces
#' @param text String. Quoated name of column in atlas/data that should be added as extra
#' information in the hover text.
#' @param colour String. Quoted name of column from which colour should be supplied
#' @param palette String. Vector of colour names or HEX colours. Can also be a named
#' numeric vector, with colours as names, and breakpoint for that colour as the value
#' @param na.colour String. Either name, hex of RGB for colour of NA in colour.
#' @param na.alpha Numeric. A number between 0 and 1 to control transparency of NA-regions.
#' @param show.legend Logical. Toggle legend if colour is numeric.
#' @param options.legend list of layout changes to colourbar
#'
#' \strong{Available surfaces:}
#' \itemize{
#' \item `inflated:` Fully inflated surface
#' \item `semi-inflated:` Semi-inflated surface
#' \item `white:` white matter surface
#'  }
#'
#' @return a plotly object
#'
#' @importFrom dplyr filter full_join select distinct summarise
#' @importFrom plotly plot_ly add_trace layout
#' @importFrom scales colour_ramp brewer_pal rescale gradient_n_pal
#' @importFrom tidyr unite_
#' @importFrom magrittr "%>%"
#'
#' @examples
#' ggseg3d()
#' ggseg3d(surface="white")
#' ggseg3d(surface="inflated")
#' ggseg3d(show.legend = FALSE)
#'
#' @seealso \code{\link[plotly]{plot_ly}}, \code{\link[plotly]{add_trace}}, \code{\link[plotly]{layout}}, the plotly package
#'
#' @export
ggseg3d <- function(.data=NULL, atlas="dk_3d",
                    surface = "LCBC", hemisphere = c("right","subcort"),
                    label = "region", text = NULL, colour = "colour",
                    palette = NULL, na.colour = "darkgrey", na.alpha = 1,
                    show.legend = TRUE, options.legend = NULL) {


  # Grab the atlas, even if it has been provided as character string
  atlas3d = get_atlas(atlas,
                      surface = surface,
                      hemisphere = hemisphere)

  # If data has been supplied, merge it
  if(!is.null(.data)){
    atlas3d <- data_merge(.data, atlas3d)
  }

  pal.colours <- get_palette(palette)

  # If colour column is numeric, calculate the gradient
  if(is.numeric(unlist(atlas3d[,colour]))){

    if(is.null(names(palette))){
      pal.colours$values <- seq(min(atlas3d[,colour], na.rm = TRUE),
                                max(atlas3d[,colour], na.rm = TRUE),
                                length.out = nrow(pal.colours))
    }

    atlas3d$new_col = gradient_n_pal(pal.colours$orig, pal.colours$values,"Lab")(
      unlist(atlas3d[,colour]))
    fill = "new_col"

  }else{
    fill = colour
  }

  # initiate plot
  p = plotly::plot_ly()

  # add one trace per file inputed
  for(tt in 1:nrow(atlas3d)){

    col = rep(unlist(atlas3d[tt, fill]), nrow(atlas3d$mesh[[tt]]$faces))

    col = ifelse(is.na(col), na.colour, col)

    op = ifelse(is.na(unlist(atlas3d[tt, fill])), na.alpha, 1)

    txt = if(is.null(text)){
      text
    }else{
      paste0(text, ": ", unlist(atlas3d[tt, text]))
    }

    p = plotly::add_trace(p,
                          x = atlas3d$mesh[[tt]]$vertices$x,
                          y = atlas3d$mesh[[tt]]$vertices$y,
                          z = atlas3d$mesh[[tt]]$vertices$z,

                          i = atlas3d$mesh[[tt]]$faces$i-1,
                          j = atlas3d$mesh[[tt]]$faces$j-1,
                          k = atlas3d$mesh[[tt]]$faces$k-1,

                          facecolor = col,
                          type = "mesh3d",
                          text = txt,
                          showscale = FALSE,
                          opacity = op,
                          name = unlist(atlas3d[tt, label])
    )
  }

  # work around to get legend
  if(show.legend & is.numeric(unlist(atlas3d[,colour]))){

    dt_leg <- dplyr::mutate(pal.colours,
                            x = 0, y = 0, z = 0)

    p <- plotly::add_trace(p, data = dt_leg,
                          x = ~ x, y = ~ y, z = ~ z,

                          intensity =  ~ values,
                          colorscale =  unname(dt_leg[,c("norm", "hex")]),
                          type = "mesh3d",
                          colorbar = options.legend
    )
  }

  p
}

## quiets concerns of R CMD check
if(getRversion() >= "2.15.1"){
  utils::globalVariables(c("tt", "surf", "mesh", "new_col"))
}
