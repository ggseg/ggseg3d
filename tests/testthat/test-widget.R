test_that("create_ggseg3d_widget creates htmlwidget", {
  meshes <- list(
    list(
      name = "test",
      vertices = list(x = c(0, 1), y = c(0, 1), z = c(0, 1)),
      faces = list(i = 0L, j = 1L, k = 2L),
      colors = c("#FF0000", "#00FF00"),
      colorMode = "vertexcolor"
    )
  )

  widget <- create_ggseg3d_widget(meshes, NULL)

  expect_s3_class(widget, c("ggseg3d", "htmlwidget"))
  expect_identical(widget$x$options$camera, "right lateral")
  expect_true(widget$x$options$showLegend)
  expect_identical(widget$x$options$backgroundColor, "#ffffff")
})

test_that("create_ggseg3d_widget includes legend data", {
  meshes <- list()
  legend_data <- list(
    type = "continuous",
    title = "value",
    min = 0,
    max = 10
  )

  widget <- create_ggseg3d_widget(meshes, legend_data)

  expect_identical(widget$x$colorbar, legend_data)
})

test_that("create_ggseg3d_widget has correct sizing policy", {
  meshes <- list()
  widget <- create_ggseg3d_widget(meshes, NULL)

  expect_identical(widget$sizingPolicy$defaultWidth, 600)
  expect_identical(widget$sizingPolicy$defaultHeight, 500)
})
