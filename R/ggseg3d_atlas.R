#' `ggseg3d_atlas` class
#' @param x data.frame to be made a ggseg-atlas
#' @param return return logical
#'
#' @description
#' The `ggseg_3datlas` class is a subclass of [`data.frame`][base::data.frame()],
#' created in order to have different default behaviour. It heavily relies on
#' the "tibble" [`tbl_df`][tibble::tibble()].
#' [tidyverse](https://www.tidyverse.org/packages/), including
#' [dplyr](http://dplyr.tidyverse.org/),
#' [ggplot2](http://ggplot2.tidyverse.org/),
#' [tidyr](http://tidyr.tidyverse.org/), and
#' [readr](http://readr.tidyverse.org/).
#'
#' @section Properties of `ggseg3d_atlas`:
#'
#' Objects of class `ggseg3d_atlas` have:
#' * A `class` attribute of `c("ggseg3d_atlas", "tbl_df", "tbl", "data.frame")`.
#' * A base type of `"list"`, where each element of the list has the same
#'   [NROW()].
#' * A lot of this script and its functions are taken from the
#'   [`tibble`][tibble::tibble()]-package
#'
#' @name ggseg3d_atlas-class
#' @importFrom dplyr tibble as_tibble one_of select everything rename group_by ungroup
#' @importFrom tidyr unnest nest
#' @aliases ggseg3d_atlas ggseg3d_atlas-class
#' @return an object of class 'ggseg3d_atlas'. A nested tibble of different
#'    brain surface shapes, hemispheres and tri-surface mesh information
#'    for different brain regions in a specific atlas.
#' @export
#' @examples
#' tmp <- as.data.frame(dk_3d)
#' class(tmp)
#' new_atlas <- as_ggseg3d_atlas(tmp)
#' class(new_atlas)
#' @seealso [tibble()], [as_tibble()], [tribble()], [print.tbl()], [glimpse()]
as_ggseg3d_atlas <- function(x, return = FALSE) {

  stopifnot(is.data.frame(x))
  ret <- TRUE
  if("ggseg_3d" %in% names(x)) x <- unnest(x, cols = c(ggseg_3d))

  necessaries <- c("atlas", "surf", "hemi", "region", "colour", "mesh")
  miss <- necessaries %in% names(x)
  if(!all(miss)){
    miss <- stats::na.omit(necessaries[!miss])

    if(!return){
      stop(paste0("There are missing necessary columns in the data.frame for it to be a ggseg3d_atlas: '",
                  paste0(as.character(miss), "'", collapse=" '"),
                  call.=FALSE)
      )
    }else{
      ret <- FALSE
    }

  }

  x <- group_by(x, atlas, surf, hemi)
  x <- select(x, one_of(c(necessaries, "label")),
           everything())
  x <- nest(x)
  x <- rename(x, ggseg_3d = data)
  x <- ungroup(x)

  class(x) <- c("ggseg3d_atlas", "tbl_df", "tbl", "data.frame")

  if(!return){
    return(x)
  }else{
    return(ret)
  }
}



#' Check if is ggseg_atlas-class
#'
#' @param x atlas object to check
#'
#' @return logical
#' @export
is_ggseg3d_atlas <- function(x){

  # try to convert to check
  k <- suppressWarnings(
    as_ggseg3d_atlas(x, return = TRUE)
  )

  # check if class is set
  j <- class(x)[1] == "ggseg3d_atlas"

  # Both should be true
  all(c(k,j))
}

## quiets concerns of R CMD check
if(getRversion() >= "2.15.1"){
  utils::globalVariables(c("x", "ggseg_3d", "data"))
}
