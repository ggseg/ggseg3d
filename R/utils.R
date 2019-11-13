# from the package gplots
col2hex <- function (colour){
  col <- grDevices::col2rgb(colour)
  grDevices::rgb(red = col[1, ]/255,
                 green = col[2, ]/255,
                 blue = col[3, ]/255)
}


# get atlas depending on string or env object
get_atlas <- function(atlas, surface, hemisphere){
  atlas3d <- if(!is.character(atlas)){
    atlas
  }else{
    get(atlas)
  }

  if(!any(grepl("3d", atlas3d$atlas))){
    stop(paste0("This is not a 3d atlas, did you mean ", atlas3d$atlas[1], "_3d?"))
  }

  if(!any(atlas3d$surf %in% surface)){
    stop(paste0("There is no surface '",surface,"' in this atlas." ))
  }

  if(!any(atlas3d$hemi %in% hemisphere)){
    stop(paste0("There is no data for the ",hemisphere," hemisphere in this atlas." ))
  }


  atlas3d <- as_ggseg3d_atlas(atlas3d)

  # grab the correct surface and hemisphere
  atlas3d %>%
    dplyr::filter(surf %in% surface,
                  hemi %in% hemisphere) %>%
    tidyr::unnest(cols = ggseg_3d)

}


get_palette <- function(palette){

  if(is.null(palette)){
    palette = c("skyblue", "dodgerblue")
  }

  pal.colours = palette

  # pal.colours = if(length(palette)==1){
  #   if(!palette %in% unlist(lapply(paletteers$palettes, function(x) x$palette))){
  #     stop(paste0("No such palette '", palette, "'. Choose one from the paletteer package."))
  #   }
  #
  #   get_paletteer(palette)
  # }else{
  #   palette
  # }


  pal.colours = data.frame(seq(0,1, length.out = length(pal.colours)),
                           pal.colours, stringsAsFactors = F)
  names(pal.colours) = NULL

  pal.colours
}
