test_that("pan_camera works", {
  p <- ggseg3d() |>
    pan_camera("right lateral")

  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_identical(p$x$options$camera, "right lateral")

  p <- ggseg3d() |>
    pan_camera("right medial")

  expect_identical(p$x$options$camera, "right medial")

  p <- ggseg3d() |>
    pan_camera("left lateral")

  expect_identical(p$x$options$camera, "left lateral")

  p <- ggseg3d() |>
    pan_camera("left medial")

  expect_identical(p$x$options$camera, "left medial")

  p <- ggseg3d() |>
    pan_camera(camera = list(eye = list(x = -3, y = -4, z = -1)))

  expect_identical(
    p$x$options$camera,
    list(eye = list(x = -3, y = -4, z = -1))
  )
})

test_that("default camera is right lateral", {
  p <- ggseg3d()
  expect_identical(p$x$options$camera, "right lateral")
})
