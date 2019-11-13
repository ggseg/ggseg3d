test_that("pan_camera works", {
  p <- ggseg3d() %>%
    pan_camera("lat")

  expect_true("layoutAttrs" %in% names(p$x))

  expect_equal(p$x$layoutAttrs[[1]]$scene$camera ,
               list(eye = list(x = 2, y = 0, z = 1))
               )

  p <- ggseg3d() %>%
    pan_camera("medial")

  expect_true("layoutAttrs" %in% names(p$x))

  expect_equal(p$x$layoutAttrs[[1]]$scene$camera ,
               list(eye = list(x = -2.25, y = -0.5, z = -0.5))
  )


  p <- ggseg3d() %>%
    pan_camera(camera = list(eye = list(x = -3, y = -4, z = -1)))

  expect_true("layoutAttrs" %in% names(p$x))

  expect_equal(p$x$layoutAttrs[[1]]$scene$camera ,
               list(eye = list(x = -3, y = -4, z = -1))
  )
})
