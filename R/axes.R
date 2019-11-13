#' Remove axis information from ggseg3d plot
#'
#' When publishing data visualisation in 3d mesh plots
#' in general the axes are not important, atleast
#' they are not for ggseg3d, where the axis values
#' are arbitrary.
#'
#' @param p plotly object
#'
#' @return plotly object without axes
#' @export
#'
#' @examples
#' library(magrittr)
#' ggseg3d() %>%
#'    remove_axes()
remove_axes <- function(p){
    ax <- list(
      title = "",
      zeroline = FALSE,
      showline = FALSE,
      showticklabels = FALSE,
      showgrid = FALSE,
      showbackground = FALSE
    )

    plotly::layout(p,
                   scene = list(
                     xaxis=ax,
                     yaxis=ax,
                     zaxis=ax,
                     plot_bgcolor='transparent',
                     paper_bgcolor='transparent'))
}
