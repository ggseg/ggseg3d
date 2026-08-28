test_that("set_background works", {
  p <- ggseg3d() |> set_background("black")
  expect_equal(p$x$options$backgroundColor, "#000000")

  p <- ggseg3d() |> set_background("#FF5733")
  expect_equal(p$x$options$backgroundColor, "#FF5733")

  p <- ggseg3d() |> set_background("white")
  expect_equal(p$x$options$backgroundColor, "#FFFFFF")
})

test_that("set_legend works", {
  p <- ggseg3d() |> set_legend(TRUE)
  expect_true(p$x$options$showLegend)

  p <- ggseg3d() |> set_legend(FALSE)
  expect_false(p$x$options$showLegend)
})

test_that("set_dimensions works", {
  p <- ggseg3d() |> set_dimensions(width = 800, height = 600)
  expect_equal(p$width, 800)
  expect_equal(p$height, 600)

  p <- ggseg3d() |> set_dimensions(width = 1200)
  expect_equal(p$width, 1200)
  expect_null(p$height)

  p <- ggseg3d() |> set_dimensions(height = 400)
  expect_null(p$width)
  expect_equal(p$height, 400)
})

test_that("set_edges works", {
  p <- ggseg3d() |> set_edges("red")
  expect_equal(p$x$meshes[[1]]$edgeColor, "#FF0000")
  expect_equal(p$x$meshes[[1]]$edgeWidth, 1)

  p <- ggseg3d() |> set_edges("#00FF00", width = 2)
  expect_equal(p$x$meshes[[1]]$edgeColor, "#00FF00")
  expect_equal(p$x$meshes[[1]]$edgeWidth, 2)

  p <- ggseg3d() |>
    set_edges("black") |>
    set_edges(NULL)
  expect_null(p$x$meshes[[1]]$edgeColor)
  expect_null(p$x$meshes[[1]]$edgeWidth)
})

test_that("set_flat_shading works", {
  p <- ggseg3d() |> set_flat_shading(TRUE)
  expect_true(p$x$options$flatShading)

  p <- ggseg3d() |> set_flat_shading(FALSE)
  expect_false(p$x$options$flatShading)

  p <- ggseg3d() |> set_flat_shading()
  expect_true(p$x$options$flatShading)
})

test_that("set_orthographic works", {
  p <- ggseg3d() |> set_orthographic(TRUE)
  expect_true(p$x$options$orthographic)
  expect_equal(p$x$options$frustumSize, 220)

  p <- ggseg3d() |> set_orthographic(FALSE)
  expect_false(p$x$options$orthographic)

  p <- ggseg3d() |> set_orthographic(TRUE, frustum_size = 300)
  expect_true(p$x$options$orthographic)
  expect_equal(p$x$options$frustumSize, 300)
})

test_that("additions reject non-ggseg3d objects", {
  fake_widget <- list(x = list())
  class(fake_widget) <- "htmlwidget"

  expect_error(set_background(fake_widget, "black"), "ggseg3d")
  expect_error(set_legend(fake_widget, TRUE), "ggseg3d")
  expect_error(set_dimensions(fake_widget, 800, 600), "ggseg3d")
  expect_error(set_edges(fake_widget, "black"), "ggseg3d")
  expect_error(set_flat_shading(fake_widget), "ggseg3d")
  expect_error(set_orthographic(fake_widget), "ggseg3d")
  expect_error(pan_camera(fake_widget, "left lateral"), "ggseg3d")
})

test_that("pan_camera validates input", {
  expect_error(
    ggseg3d() |> pan_camera(123),
    "character string or list"
  )
})

test_that("set_positioning centers hemispheres", {
  p <- ggseg3d(hemisphere = c("left", "right")) |>
    set_positioning("centered")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  for (m in p$x$meshes) {
    if (!grepl("left|right", m$name, ignore.case = TRUE)) {
      next
    }
    x_range <- range(m$vertices$x)
    x_center <- mean(x_range)
    expect_true(abs(x_center) < 1)
  }
})

test_that("set_positioning anatomical offsets hemispheres", {
  p <- ggseg3d(hemisphere = c("left", "right")) |>
    set_positioning("anatomical")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  left_mesh <- NULL
  right_mesh <- NULL
  for (m in p$x$meshes) {
    if (grepl("left", m$name, ignore.case = TRUE)) {
      left_mesh <- m
    }
    if (grepl("right", m$name, ignore.case = TRUE)) right_mesh <- m
  }
  expect_true(mean(range(left_mesh$vertices$x)) < 0)
  expect_true(mean(range(right_mesh$vertices$x)) > 0)
})

test_that("set_positioning leaves subcortical region meshes untouched", {
  p <- ggseg3d(atlas = aseg())
  original_meshes <- p$x$meshes

  p_positioned <- p |> set_positioning("centered")
  for (i in seq_along(p_positioned$x$meshes)) {
    expect_equal(
      p_positioned$x$meshes[[i]]$vertices,
      original_meshes[[i]]$vertices
    )
  }
})

test_that("set_positioning rejects non-ggseg3d objects", {
  expect_error(set_positioning(list()), "ggseg3d")
})

test_that("ggseg3d produces anatomically positioned hemispheres by default", {
  p <- ggseg3d(hemisphere = c("left", "right"))
  left <- NULL
  right <- NULL
  for (m in p$x$meshes) {
    if (m$name == "left inflated") {
      left <- m
    }
    if (m$name == "right inflated") right <- m
  }
  expect_lte(max(left$vertices$x), 1e-6)
  expect_gte(min(right$vertices$x), -1e-6)
})

test_that("add_glassbrain warns and returns unchanged when widget is flat", {
  p <- ggseg3d(hemisphere = "left")
  p$x$meshes[[1]]$isFlatmap <- TRUE
  n <- length(p$x$meshes)
  expect_warning(result <- add_glassbrain(p), "flatmap|flat")
  expect_equal(length(result$x$meshes), n)
})

test_that("add_glassbrain warns for unavailable mesh", {
  expect_warning(
    ggseg3d(atlas = aseg()) |>
      add_glassbrain(
        hemisphere = "left",
        surface = "pial",
        brain_meshes = list()
      ),
    "not available"
  )
})

test_that("additions can be chained", {
  p <- ggseg3d() |>
    set_background("black") |>
    set_legend(FALSE) |>
    set_flat_shading(TRUE) |>
    set_orthographic(TRUE) |>
    pan_camera("left lateral")

  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_equal(p$x$options$backgroundColor, "#000000")
  expect_false(p$x$options$showLegend)
  expect_true(p$x$options$flatShading)
  expect_true(p$x$options$orthographic)
  expect_equal(p$x$options$camera, "left lateral")
})
