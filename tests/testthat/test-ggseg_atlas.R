
tt <- data.frame(atlas = "k",
                 surf = "white",
                 hemi = "left",
                 region = "something",
                 colour = "#d2d2d2",
                 stringsAsFactors = FALSE)
tt$mesh[[1]] = list(it=array(0, dim=3),vb=array(0, dim=3))

test_that("check that ggseg3d_atlas is correct", {

  expect_error(as_ggseg3d_atlas(tt[,-1]),
               "missing necessary columns")
  expect_error(as_ggseg3d_atlas(),
               "is missing, with no default")

  k <- expect_warning(as_ggseg3d_atlas(tt),
                     "Unknown columns")
  expect_equal(names(k),
               c("atlas", "surf", "hemi", "ggseg_3d"))
  expect_equal(nrow(k), 1)
})

test_that("check that is_ggseg_atlas works", {
  expect_false(is_ggseg3d_atlas(tt))

})
