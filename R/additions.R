#' Add glass brain to ggseg3d plot
#'
#' Adds a translucent brain on top of a ggseg3d plot
#' to create a point of reference, particularly
#' important for sub-cortical plots.
#'
#' @param p plotly object
#' @param hemisphere string. hemisphere to plot ("left" or "right")
#' @param colour string. colour to give the glass brain
#' @param opacity numeric. transparency of the glass brain (0-1 float)
#'
#' @return plotly object with glass brain tri-surface mesh
#' @export
#'
#' @examples
#' library(dplyr)
#' ggseg3d(atlas="aseg_3d") %>%
#'    add_glassbrain("left")
add_glassbrain <- function(p,
                       hemisphere = c("left", "right"),
                       colour = "#cecece",
                       opacity=.3){

    cortex <- dplyr::filter(cortex_3d,
                            hemi %in% hemisphere)
    cortex <- tidyr::unnest(cortex, ggseg_3d)

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

#' Pan camera position of ggseg3d plot
#'
#' The default position for plotly
#' mesh plots are not satisfying for
#' brain plots. This convenience function
#' can pan the camera to lateral or medial
#' view, or to custom made views if you are
#' plotly savvy.
#'
#' @param p plotly object
#' @param camera string or list.
#' @param aspectratio camera aspect ratio
#'
#' @return plotly object
#' @export
#'
#' @examples
#' library(dplyr)
#' ggseg3d() %>%
#'    pan_camera("right lateral")
pan_camera <- function(p, camera, aspectratio = 1){

  stopifnot(is.character(camera)|is.list(camera))

  views = if(class(camera) != "list"){
    camera <- match.arg(camera, c("left lateral", "left medial",
                                  "right lateral", "right medial"))
    switch(camera,
           "left lateral" = list(eye = list(x = -2.5, y = 0, z = 0)),
           "left medial" = list(eye = list(x = 2, y = 0, z = 0)),
           "right lateral" = list(eye = list(x = 2, y = 0, z = 0)),
           "right medial" = list(eye = list(x = -2.5, y = 0, z = 0))
    )
  }else{
    camera
  }

  # create final plotly plot
  plotly::layout(p,
                 scene = list(camera = views,
                              aspectratio = aspectratio)
  )
}


#' Remove axis information from ggseg3d plot
#'
#' When publishing data visualisation in 3d mesh plots
#' in general the axes are not important, at least
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

