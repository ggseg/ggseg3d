test_that("get_palette works", {

  expect_equal(get_palette(NULL),
               structure(list(c(0, 1),
                              c("skyblue", "dodgerblue")),
                         class = "data.frame",
                         row.names = c(NA,-2L))
  )

  expect_equal(get_palette(c("firebrick", "white", "goldenrod")),
               structure(list(c(0, 0.5, 1),
                              c("firebrick", "white", "goldenrod")),
                         class = "data.frame",
                         row.names = c(NA, -3L))
  )

  expect_equal(get_palette(c("#fff", "#d3d3d3", "#32g303")),
  structure(list(c(0, 0.5, 1),
                 c("#fff", "#d3d3d3", "#32g303")),
            class = "data.frame",
            row.names = c(NA,-3L))
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
