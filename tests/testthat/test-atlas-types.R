test_that("prepare_atlas_data extracts vertices and joins core", {
  vertices_data <- data.frame(
    label = c("bankssts", "caudalanteriorcingulate"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(c(1, 2, 3), c(4, 5, 6))

  atlas <- structure(
    list(
      core = data.frame(
        label = c("bankssts", "caudalanteriorcingulate"),
        region = c("banks sts", "caudal anterior cingulate"),
        hemi = c("left", "left"),
        stringsAsFactors = FALSE
      ),
      vertices = vertices_data,
      palette = c("bankssts" = "#FF0000", "caudalanteriorcingulate" = "#00FF00")
    ),
    class = "ggseg_atlas"
  )

  result <- prepare_atlas_data(atlas, NULL)

  expect_true("label" %in% names(result))
  expect_true("region" %in% names(result))
  expect_true("hemi" %in% names(result))
  expect_true("colour" %in% names(result))
  expect_true("vertices" %in% names(result))
  expect_identical(result$colour[result$label == "bankssts"], "#FF0000")
})

test_that("prepare_atlas_data works with data component", {
  vertices_data <- data.frame(
    label = c("a", "b"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(c(1, 2), c(3, 4))

  atlas <- structure(
    list(
      core = data.frame(
        label = c("a", "b"),
        region = c("region a", "region b"),
        hemi = c("left", "right"),
        stringsAsFactors = FALSE
      ),
      data = structure(
        list(vertices = vertices_data),
        class = "ggseg_atlas_data"
      ),
      palette = c("a" = "#AAAAAA", "b" = "#BBBBBB")
    ),
    class = "ggseg_atlas"
  )

  result <- prepare_atlas_data(atlas, NULL)

  expect_identical(nrow(result), 2L)
  expect_true("vertices" %in% names(result))
})

test_that("prepare_atlas_data merges user data", {
  vertices_data <- data.frame(
    label = c("a", "b"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(c(1, 2), c(3, 4))

  atlas <- structure(
    list(
      core = data.frame(
        label = c("a", "b"),
        region = c("region a", "region b"),
        hemi = c("left", "right"),
        stringsAsFactors = FALSE
      ),
      vertices = vertices_data,
      palette = NULL
    ),
    class = "ggseg_atlas"
  )

  user_data <- data.frame(
    label = c("a", "b"),
    my_value = c(10, 20),
    stringsAsFactors = FALSE
  )

  result <- prepare_atlas_data(atlas, user_data)

  expect_true("my_value" %in% names(result))
  expect_identical(result$my_value[result$label == "a"], 10)
})

test_that("prepare_mesh_atlas_data extracts meshes and joins core", {
  meshes_data <- data.frame(
    label = c("Left-Caudate", "Right-Caudate"),
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(
    list(
      vertices = data.frame(x = 1, y = 2, z = 3),
      faces = data.frame(i = 1, j = 2, k = 3)
    ),
    list(
      vertices = data.frame(x = 4, y = 5, z = 6),
      faces = data.frame(i = 4, j = 5, k = 6)
    )
  )

  atlas <- structure(
    list(
      core = data.frame(
        label = c("Left-Caudate", "Right-Caudate"),
        region = c("caudate", "caudate"),
        hemi = c("subcort", "subcort"),
        stringsAsFactors = FALSE
      ),
      meshes = meshes_data,
      palette = c("Left-Caudate" = "#123456", "Right-Caudate" = "#654321")
    ),
    class = "ggseg_atlas"
  )

  result <- prepare_mesh_atlas_data(atlas, NULL)

  expect_true("label" %in% names(result))
  expect_true("mesh" %in% names(result))
  expect_true("colour" %in% names(result))
  expect_identical(result$colour[result$label == "Left-Caudate"], "#123456")
})

test_that("prepare_mesh_atlas_data works with data component", {
  meshes_data <- data.frame(
    label = "a",
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(
    list(
      vertices = data.frame(x = 1, y = 2, z = 3),
      faces = data.frame(i = 1, j = 2, k = 3)
    )
  )

  atlas <- structure(
    list(
      core = data.frame(
        label = "a",
        region = "region a",
        hemi = "subcort",
        stringsAsFactors = FALSE
      ),
      data = structure(
        list(meshes = meshes_data),
        class = "ggseg_atlas_data"
      ),
      palette = NULL
    ),
    class = "ggseg_atlas"
  )

  result <- prepare_mesh_atlas_data(atlas, NULL)

  expect_identical(nrow(result), 1L)
  expect_true("mesh" %in% names(result))
})

test_that("data_merge_mesh joins user data with atlas", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    region = c("region a", "region b"),
    hemi = c("subcort", "subcort"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(list(), list())

  user_data <- data.frame(
    label = c("a", "b"),
    value = c(100, 200),
    stringsAsFactors = FALSE
  )

  result <- data_merge_mesh(user_data, atlas_data)

  expect_true("value" %in% names(result))
  expect_identical(result$value[result$label == "a"], 100)
})

test_that("data_merge_mesh warns when no common columns", {
  atlas_data <- data.frame(
    label = "a",
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(list())

  user_data <- data.frame(
    unrelated_col = "x",
    stringsAsFactors = FALSE
  )

  expect_warning(
    result <- data_merge_mesh(user_data, atlas_data),
    "No common columns"
  )

  expect_identical(result, atlas_data)
})

test_that("data_merge_mesh joins on region column", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    region = c("region a", "region b"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(list(), list())

  user_data <- data.frame(
    region = c("region a", "region b"),
    score = c(1.5, 2.5),
    stringsAsFactors = FALSE
  )

  result <- data_merge_mesh(user_data, atlas_data)

  expect_true("score" %in% names(result))
  expect_equal(result$score[result$region == "region a"], 1.5)
})

test_that("prepare_mesh_atlas_data merges user data", {
  meshes_data <- data.frame(
    label = c("a", "b"),
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(
    list(
      vertices = data.frame(x = 1, y = 2, z = 3),
      faces = data.frame(i = 1, j = 2, k = 3)
    ),
    list(
      vertices = data.frame(x = 4, y = 5, z = 6),
      faces = data.frame(i = 4, j = 5, k = 6)
    )
  )

  atlas <- structure(
    list(
      core = data.frame(
        label = c("a", "b"),
        region = c("region a", "region b"),
        hemi = c("subcort", "subcort"),
        stringsAsFactors = FALSE
      ),
      meshes = meshes_data,
      palette = NULL
    ),
    class = "ggseg_atlas"
  )

  user_data <- data.frame(
    label = c("a", "b"),
    value = c(100, 200),
    stringsAsFactors = FALSE
  )

  result <- prepare_mesh_atlas_data(atlas, user_data)

  expect_true("value" %in% names(result))
  expect_identical(result$value[result$label == "a"], 100)
})
