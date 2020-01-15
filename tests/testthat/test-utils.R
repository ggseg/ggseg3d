test_that("get_palette works", {

  expect_equal(get_palette("blue"),
               data.frame(values = c(0,1),
                          norm = c(0,1),
                          orig = "blue",
                          hex = "#0000FF",
                          stringsAsFactors = FALSE
                          )
  )


  expect_equal(get_palette(c("blue"=1)),
               data.frame(values = c(1,2),
                          norm = c(0,1),
                          orig = "blue",
                          hex = "#0000FF",
                          stringsAsFactors = FALSE
               )
  )

  expect_equal(get_palette(NULL),
               structure(list(values = c(0, 1),
                              norm = c(0, 1),
                              orig = c("skyblue", "dodgerblue"),
                              hex = c("#87CEEB", "#1E90FF")),
                         row.names = c(NA, -2L),
                         class = "data.frame")
  )

  expect_equal(get_palette(c("firebrick", "white", "goldenrod")),
               structure(list(values = c(0, 0.5, 1),
                              norm = c(0, 0.5, 1),
                              orig = c("firebrick", "white", "goldenrod"),
                              hex = c("#B22222", "#FFFFFF", "#DAA520")),
                         row.names = c(NA, -3L),
                         class = "data.frame")
  )

  expect_equal(get_palette(c("#ffffff", "#d3d3d3", "#32f303")),
               structure(list(values = c(0, 0.5, 1),
                              norm = c(0, 0.5, 1),
                              orig = c("#ffffff", "#d3d3d3", "#32f303"),
                              hex = c("#FFFFFF", "#D3D3D3", "#32F303")),
                         row.names = c(NA, -3L),
                         class = "data.frame")
  )

  expect_equal(get_palette(c("#ffffff" = 0, "#d3d3d3" = 1, "#32f303" = 2)),
               structure(list(values = c(0, 1, 2),
                              norm = c(0, 0.5, 1),
                              orig = c("#ffffff", "#d3d3d3", "#32f303"),
                              hex = c("#FFFFFF", "#D3D3D3", "#32F303")),
                         row.names = c(NA, -3L),
                         class = "data.frame")
  )

})

test_that("get_atlas works", {

  expect_error(get_atlas("dkt3d"), "not found")
  expect_error(get_atlas("dkt_3d"), "surface")
  expect_error(get_atlas("dkt_3d", surface="LCBC"), "hemisphere")

  k <- get_atlas("dkt_3d", surface="LCBC", hemisphere = "left")
  expect_equal(dim(k), c(36,11))
  expect_equal(names(k), c("atlas", "surf", "hemi", "area", "colour", "mesh", "label",
                           "roi", "annot", "acronym", "lobe"))


  expect_error(get_atlas("aseg3d"), "not found")
  expect_error(get_atlas("aseg_3d", surface = "inflated"), "no surface")
  expect_error(get_atlas("aseg_3d", surface="LCBC", hemisphere = "left"), "no data")

  k <- get_atlas("aseg_3d", surface="LCBC", hemisphere = "subcort")
  expect_equal(dim(k), c(32,9))
  expect_equal(names(k), c("atlas", "surf", "hemi", "area", "colour", "mesh", "label",
                           "files", "roi"))

})


test_that("col2hex works",{

  expect_equal(col2hex("red"), "#FF0000")
  expect_equal(col2hex("green"), "#00FF00")

})
