test_that("apply_colour_palette handles numeric data", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    my_value = c(1, 2, 3),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(
    atlas_data,
    "my_value",
    c("blue", "red"),
    "#CCCCCC"
  )

  expect_true(result$is_numeric)
  expect_identical(result$fill, "new_col")
  expect_identical(result$data_min, 1)
  expect_identical(result$data_max, 3)
  expect_true(all(grepl("^#", result$data$colour)))
})

test_that("apply_colour_palette handles categorical data", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    colour = c("#FF0000", "#00FF00", "#0000FF"),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(atlas_data, "colour", NULL, "#CCCCCC")

  expect_false(result$is_numeric)
  expect_identical(result$fill, "colour")
})

test_that("apply_colour_palette handles NA values", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    colour = c("#FF0000", NA, "#0000FF"),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(atlas_data, "colour", NULL, "#AABBCC")

  expect_identical(result$data$colour[2], "#AABBCC")
})

test_that("apply_colour_palette converts named colors to hex", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    colour = c("red", "blue"),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(atlas_data, "colour", NULL, "#CCCCCC")

  expect_identical(result$data$colour[1], "#FF0000")
  expect_identical(result$data$colour[2], "#0000FF")
})

test_that("apply_colour_palette handles single constant value", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    my_value = c(5, 5),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(
    atlas_data,
    "my_value",
    c("blue", "red"),
    "#CCCCCC"
  )

  expect_true(result$is_numeric)
  expect_identical(result$data_min, result$data_max)
})
