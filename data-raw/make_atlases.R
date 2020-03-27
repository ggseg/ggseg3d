# load dev version of ggsegExtra
devtools::load_all("../ggsegExtra/")
devtools::load_all(".")


# DK ----
template_dir <- system.file("templates",  package = "ggseg3d")
x <- cortex_2_3datlas("aparc", annot_dir = template_dir)

x <- unnest(x, ggseg_3d)
x <- ungroup(x)

# make nicer label names
x <- dplyr::mutate(
  x,
  region = gsub("inferior", "inferior ", region),
  region = gsub("caudal", "caudal ", region),
  region = gsub("rostral", "rostral ", region),
  region = gsub("middle", "middle ", region),
  region = gsub("lateral", "lateral ", region),
  region = gsub("frontal", "frontal ", region),
  region = gsub("superior", "superior ", region),
  region = gsub("transverse", "transverse ", region),
  region = gsub("pars", "pars ", region),
  region = gsub("posterior", "posterior ", region),
  region = gsub("anterior", "anterior ", region),
  region = gsub("temporal", "temporal ", region),
  region = gsub("medial", "medial ", region),
  region = gsub("corpus", "corpus ", region),
  region = gsub("isthmus", "isthmus ", region),
  region = gsub(" $", "", region),
  region = gsub("unknown", "medial wall", region),
  atlas = "dk_3d"
)

dk_3d <- as_ggseg3d_atlas(x)
usethis::use_data(dk_3d, internal = FALSE, overwrite = TRUE)


# aseg ----
# x <- subcort_2_3datlas()
#
# x <- unnest(x, ggseg_3d)
# x <- ungroup(x)
# x <- filter(x, !grepl("Cerebral", region))
#
# # make nicer label names
# x <- dplyr::mutate(x,
#                    region = gsub("-", " ", region),
#                    atlas = "aseg_3d"
# )
#
# aseg_3d <- as_ggseg3d_atlas(x)

k <- ggsegExtra:::restruct_old_3datlas(aseg_3d)

usethis::use_data(aseg_3d, internal = FALSE, overwrite = TRUE)
