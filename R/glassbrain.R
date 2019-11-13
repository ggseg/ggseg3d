#' Add glass brain to ggseg3d plot
#'
#' Adds a translucent brain on top of a ggseg3d plot
#' to create a point of reference, particularly
#' important for subcortical plots.
#'
#' @param p plotly object
#' @param hemisphere string. hemisphere to plot ("left" or "right")
#' @param colour string. colour to give the glass brain
#' @param opacity numeric. transparency of the glass brain (0-1 float)
#'
#' @return plotly object with glassbrain mesh
#' @export
#'
#' @examples
#' library(magrittr)
#' ggseg3d(atlas="aseg_3d") %>%
#'    add_glassbrain()
add_glassbrain <- function(p,
                       hemisphere = c("left", "right"),
                       colour = "#cecece",
                       opacity=.3){

    cortex <- cortex_3d %>%
      dplyr::filter(hemi %in% hemisphere) %>%
      tidyr::unnest(ggseg_3d)

    colour <- if(grepl("^#", colour)){
      colour
    }else{
      col2hex(colour)
    }

    # add one trace per file inputed
    for(tt in 1:nrow(cortex)){

      col = rep(colour, length(cortex$mesh[[tt]]$it[1,]))

      p = plotly::add_trace(p,
                            x = cortex$mesh[[tt]]$vb["xpts",],
                            y = cortex$mesh[[tt]]$vb["ypts",],
                            z = cortex$mesh[[tt]]$vb["zpts",],

                            i = cortex$mesh[[tt]]$it[1,]-1,
                            j = cortex$mesh[[tt]]$it[2,]-1,
                            k = cortex$mesh[[tt]]$it[3,]-1,

                            facecolor = col,
                            type = "mesh3d",
                            showscale = FALSE,
                            name = "cerebral cortex",
                            opacity = opacity
      )
    }

    p
}
