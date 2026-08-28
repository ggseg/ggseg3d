test_that("build_legend_data returns continuous legend for numeric data", {
  pal_colours <- get_palette(c("blue", "red"))

  result <- build_legend_data(
    is_numeric = TRUE,
    data_min = 0,
    data_max = 10,
    palette = c("blue", "red"),
    pal_colours = pal_colours,
    colour_col = "value",
    label_col = "region",
    fill_col = "new_col",
    data = data.frame()
  )

  expect_identical(result$type, "continuous")
  expect_identical(result$title, "value")
  expect_identical(result$min, 0)
  expect_identical(result$max, 10)
  expect_gt(length(result$colors), 0)
})

test_that("build_legend_data returns discrete legend for categorical data", {
  data <- data.frame(
    region = c("a", "b", "c"),
    colour = c("#FF0000", "#00FF00", "#0000FF"),
    stringsAsFactors = FALSE
  )

  result <- build_legend_data(
    is_numeric = FALSE,
    data_min = NA,
    data_max = NA,
    palette = NULL,
    pal_colours = NULL,
    colour_col = "colour",
    label_col = "region",
    fill_col = "colour",
    data = data
  )

  expect_identical(result$type, "discrete")
  expect_identical(result$title, "region")
  expect_length(result$labels, 3)
  expect_length(result$colors, 3)
})

test_that("build_legend_data returns NULL when data_min equals data_max", {
  result <- build_legend_data(
    is_numeric = TRUE,
    data_min = 5,
    data_max = 5,
    palette = NULL,
    pal_colours = NULL,
    colour_col = "value",
    label_col = "region",
    fill_col = "new_col",
    data = data.frame()
  )

  expect_null(result)
})

test_that("build_continuous_legend works with named palette", {
  pal_colours <- data.frame(
    values = c(0, 5, 10),
    norm = c(0, 0.5, 1),
    orig = c("blue", "white", "red"),
    stringsAsFactors = FALSE
  )

  result <- build_continuous_legend(
    palette = c("blue" = 0, "white" = 5, "red" = 10),
    pal_colours = pal_colours,
    colour_col = "my_value",
    data_min = 0,
    data_max = 10
  )

  expect_identical(result$type, "continuous")
  expect_identical(result$min, 0)
  expect_identical(result$max, 10)
  expect_false(is.null(result$breakpoints))
})

test_that("build_continuous_legend works without named palette", {
  pal_colours <- data.frame(
    values = c(0, 0.5, 1),
    norm = c(0, 0.5, 1),
    orig = c("blue", "white", "red"),
    stringsAsFactors = FALSE
  )

  result <- build_continuous_legend(
    palette = c("blue", "white", "red"),
    pal_colours = pal_colours,
    colour_col = "my_value",
    data_min = 0,
    data_max = 100
  )

  expect_identical(result$type, "continuous")
  expect_identical(result$min, 0)
  expect_identical(result$max, 100)
  expect_false(is.null(result$values))
  expect_length(result$values, 10)
})

test_that("build_discrete_legend handles data.frame input", {
  data <- data.frame(
    region = c("frontal", "temporal", "parietal"),
    colour = c("#FF0000", "#00FF00", "#0000FF"),
    stringsAsFactors = FALSE
  )

  result <- build_discrete_legend(data, "colour", "region")

  expect_identical(result$type, "discrete")
  expect_identical(result$title, "region")
  expect_length(result$labels, 3)
})

test_that("build_discrete_legend handles many unique values", {
  data <- data.frame(
    region = paste0("r", 1:60),
    colour = paste0("#", sprintf("%06X", 1:60)),
    stringsAsFactors = FALSE
  )

  result <- build_discrete_legend(data, "colour", "region")

  expect_null(result)
})

test_that("build_discrete_legend handles NA values", {
  data <- data.frame(
    region = c("a", "b", NA),
    colour = c("#FF0000", "#00FF00", NA),
    stringsAsFactors = FALSE
  )

  result <- build_discrete_legend(data, "colour", "region")

  expect_identical(result$type, "discrete")
  expect_false(anyNA(result$colors))
})

test_that("build_discrete_legend handles tibble input", {
  data <- dplyr::tibble(
    region = c("a", "b"),
    colour = c("#FF0000", "#00FF00")
  )

  result <- build_discrete_legend(data, "colour", "region")

  expect_identical(result$type, "discrete")
  expect_length(result$labels, 2)
})


test_that("build_discrete_legend handles non-dataframe input", {
  data <- matrix(
    c("a", "b", "#FF0000", "#00FF00"),
    ncol = 2,
    dimnames = list(NULL, c("region", "colour"))
  )

  result <- build_discrete_legend(data, "colour", "region")
  expect_identical(result$type, "discrete")
  expect_length(result$labels, 2)
})

test_that("build_discrete_legend removes duplicate labels", {
  data <- data.frame(
    region = c("a", "a", "b"),
    colour = c("#FF0000", "#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )

  result <- build_discrete_legend(data, "colour", "region")

  expect_length(result$labels, 2)
})
