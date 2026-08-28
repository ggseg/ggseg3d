test_that("merge_atlas_data joins data correctly", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    region = c("region a", "region b", "region c"),
    hemi = c("left", "right", "left"),
    stringsAsFactors = FALSE
  )

  user_data <- data.frame(
    label = c("a", "b"),
    value = c(10, 20),
    stringsAsFactors = FALSE
  )

  result <- merge_atlas_data(user_data, atlas_data)

  expect_true("value" %in% names(result))
  expect_identical(result$value[result$label == "a"], 10)
  expect_true(is.na(result$value[result$label == "c"]))
})

test_that("merge_atlas_data errors on no common columns", {
  atlas_data <- data.frame(
    label = "a",
    stringsAsFactors = FALSE
  )

  user_data <- data.frame(
    unrelated = "x",
    stringsAsFactors = FALSE
  )

  expect_error(
    merge_atlas_data(user_data, atlas_data),
    "No common columns"
  )
})

test_that("merge_atlas_data warns on unmatched rows", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    stringsAsFactors = FALSE
  )

  user_data <- data.frame(
    label = c("a", "unknown_region"),
    value = c(10, 20),
    stringsAsFactors = FALSE
  )

  expect_warning(
    result <- merge_atlas_data(user_data, atlas_data),
    "did not match"
  )
})

test_that("merge_atlas_data joins on multiple common columns", {
  atlas_data <- data.frame(
    label = c("a", "b", "a"),
    hemi = c("left", "left", "right"),
    region = c("ra", "rb", "ra"),
    stringsAsFactors = FALSE
  )

  user_data <- data.frame(
    label = c("a", "a"),
    hemi = c("left", "right"),
    value = c(100, 200),
    stringsAsFactors = FALSE
  )

  result <- merge_atlas_data(user_data, atlas_data)

  expect_identical(
    result$value[result$label == "a" & result$hemi == "left"],
    100
  )
  expect_identical(
    result$value[result$label == "a" & result$hemi == "right"],
    200
  )
})

test_that("check_ggseg3d passes for valid widget", {
  p <- ggseg3d()
  expect_silent(check_ggseg3d(p))
})

test_that("check_ggseg3d errors for non-widget", {
  expect_error(
    check_ggseg3d(list()),
    "ggseg3d"
  )

  expect_error(
    check_ggseg3d(data.frame()),
    "ggseg3d"
  )

  expect_error(
    check_ggseg3d("not a widget"),
    "ggseg3d"
  )
})

test_that("check_ggseg3d reports correct argument name", {
  my_var <- list()
  expect_error(
    check_ggseg3d(my_var),
    "my_var"
  )
})

test_that("range_norm normalizes to 0-1 range", {
  result <- range_norm(c(0, 5, 10))
  expect_equal(result, c(0, 0.5, 1))

  result <- range_norm(c(10, 20, 30, 40))
  expect_identical(result, c(0, 1 / 3, 2 / 3, 1))
})

test_that("range_norm handles single value", {
  result <- range_norm(c(5, 5))
  expect_true(is.nan(result[1]) || result[1] == 0)
})
