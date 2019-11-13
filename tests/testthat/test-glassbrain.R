
test_that("Check glassbrain", {
  p = ggseg3d(atlas = aseg_3d) %>%
    add_glassbrain()

  expect_is(p, c("plotly", "htmlwidget"))
  expect_equal(length(p$x$attrs), 37)

  p = ggseg3d(atlas = aseg_3d) %>%
                add_glassbrain(hemisphere = "left")
  expect_is(p, c("plotly", "htmlwidget"))
  expect_equal(length(p$x$attrs), 35)

  p = ggseg3d(atlas = aseg_3d) %>%
    add_glassbrain(hemisphere = "left",
                   colour = "red")
  expect_equal(length(p$x$attrs), 35)

})
