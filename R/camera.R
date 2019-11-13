#' Pan camera position of ggseg3d plot
#'
#' The default position for plotly
#' mesh plots are not satifsying for
#' brain plots. This convenience function
#' can pan the camera to lateral or medial
#' view, or to custom made views if you are
#' plotly savvy.
#'
#' @param p plotly object
#' @param camera string or list.
#'
#' @return plotly object
#' @export
#'
#' @examples
#' library(magrittr)
#' ggseg3d() %>%
#'    pan_camera("lateral")
pan_camera <- function(p, camera){

  stopifnot(is.character(camera)|is.list(camera))

  views = if(class(camera) != "list"){
    camera <- match.arg(camera, c("lateral", "medial"))
    switch(camera,
           "lateral" = list(eye = list(x = 2, y = 0, z = 1)),
           "medial" = list(eye = list(x = -2.25, y = -0.5, z = -0.5))
    )
  }else{
    camera
  }

  # create final plotly plot
  plotly::layout(p,
                 scene = list(camera = views)
  )
}
