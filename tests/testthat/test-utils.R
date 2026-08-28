test_that("get_palette works", {
  expect_identical(
    get_palette("blue"),
    data.frame(
      values = c(0, 1),
      norm = c(0, 1),
      orig = "blue",
      hex = "#0000FF",
      stringsAsFactors = FALSE
    )
  )

  expect_identical(
    get_palette(c("blue" = 1)),
    data.frame(
      values = c(1, 2),
      norm = c(0, 1),
      orig = "blue",
      hex = "#0000FF",
      stringsAsFactors = FALSE
    )
  )

  expect_identical(
    get_palette(NULL),
    structure(
      list(
        values = c(0, 0.5, 1),
        norm = c(0, 0.5, 1),
        orig = c("#440154", "#21918c", "#fde725"),
        hex = c("#440154", "#21918C", "#FDE725")
      ),
      row.names = c(NA, -3L),
      class = "data.frame"
    )
  )

  expect_identical(
    get_palette(c("firebrick", "white", "goldenrod")),
    structure(
      list(
        values = c(0, 0.5, 1),
        norm = c(0, 0.5, 1),
        orig = c("firebrick", "white", "goldenrod"),
        hex = c("#B22222", "#FFFFFF", "#DAA520")
      ),
      row.names = c(NA, -3L),
      class = "data.frame"
    )
  )

  expect_identical(
    get_palette(c("#ffffff", "#d3d3d3", "#32f303")),
    structure(
      list(
        values = c(0, 0.5, 1),
        norm = c(0, 0.5, 1),
        orig = c("#ffffff", "#d3d3d3", "#32f303"),
        hex = c("#FFFFFF", "#D3D3D3", "#32F303")
      ),
      row.names = c(NA, -3L),
      class = "data.frame"
    )
  )

  expect_identical(
    get_palette(c("#ffffff" = 0, "#d3d3d3" = 1, "#32f303" = 2)),
    structure(
      list(
        values = c(0, 1, 2),
        norm = c(0, 0.5, 1),
        orig = c("#ffffff", "#d3d3d3", "#32f303"),
        hex = c("#FFFFFF", "#D3D3D3", "#32F303")
      ),
      row.names = c(NA, -3L),
      class = "data.frame"
    )
  )
})

test_that("col2hex works", {
  expect_identical(col2hex("red"), "#FF0000")
  expect_identical(col2hex("green"), "#00FF00")
  expect_identical(col2hex("blue"), "#0000FF")
  expect_identical(col2hex("white"), "#FFFFFF")
  expect_identical(col2hex("black"), "#000000")
})

test_that("get_palette with named numeric palette", {
  pal <- get_palette(c("blue" = 0, "white" = 50, "red" = 100))

  expect_identical(pal$values, c(0, 50, 100))
  expect_identical(pal$orig, c("blue", "white", "red"))
  expect_equal(pal$norm, c(0, 0.5, 1))
})

test_that("get_palette handles two colors", {
  pal <- get_palette(c("blue", "red"))

  expect_identical(nrow(pal), 2L)
  expect_identical(pal$orig, c("blue", "red"))
})

test_that("range_norm normalizes correctly", {
  expect_equal(range_norm(c(0, 50, 100)), c(0, 0.5, 1))
  expect_identical(range_norm(c(10, 20)), c(0, 1))
  expect_equal(range_norm(c(-10, 0, 10)), c(0, 0.5, 1))
})
