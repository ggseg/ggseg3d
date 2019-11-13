data_merge <- function(.data, atlas3d){

    # Find columns they have in common
    cols = names(atlas3d)[names(atlas3d) %in% names(.data)]

    # Merge the brain with the data
    atlas3d = atlas3d %>%
      dplyr::full_join(.data, by = cols, copy=TRUE)

    # Find if there are instances of those columns that
    # are not present in the atlas. Maybe mispelled?
    errs = atlas3d %>%
      dplyr::filter(unlist(lapply(atlas3d$mesh, is.null))) %>%
      dplyr::select(!!cols) %>%
      dplyr::distinct() %>%
      tidyr::unite_("tt", cols, sep = " - ") %>%
      dplyr::summarise(value = paste0(tt, collapse = ", "))

    if(errs != ""){
      warning(paste("Some data is not merged properly into the atlas. Check for spelling mistakes in:",
                    errs$value))

      atlas3d = atlas3d %>%
        dplyr::filter(!unlist(lapply(atlas3d$mesh, is.null)))
    }

    atlas3d
}
