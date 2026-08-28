test_that("build_cortical_meshes skips hemisphere without data", {
  atlas_data <- data.frame(
    label = "a",
    region = "region a",
    hemi = "left",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1, 2))

  meshes <- build_cortical_meshes(
    atlas_data,
    c("left", "right"),
    "inflated",
    "#CCCCCC",
    NULL
  )

  expect_gte(length(meshes), 1)
})

test_that("build_cortical_meshes with edge_by parameter", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    region = c("region a", "region b"),
    hemi = c("left", "left"),
    colour = c("#FF0000", "#00FF00"),
    lobe = c("frontal", "parietal"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(0:50, 51:100)

  meshes <- build_cortical_meshes(
    atlas_data,
    "left",
    "inflated",
    "#CCCCCC",
    "lobe"
  )

  expect_gt(length(meshes), 0)
  expect_false(is.null(meshes[[1]]$edgeColor))
})

test_that("build_subcortical_meshes handles subcort data", {
  atlas_data <- data.frame(
    label = "Left-Caudate",
    region = "caudate",
    hemi = "subcort",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:3, y = 1:3, z = 1:3),
      faces = data.frame(i = 1, j = 2, k = 3)
    )
  )

  meshes <- build_subcortical_meshes(atlas_data, "#CCCCCC")

  expect_gt(length(meshes), 0)
})

test_that("build_tract_meshes handles tract data with legacy meshes", {
  atlas_data <- data.frame(
    label = "tract1",
    region = "tract 1",
    hemi = "subcort",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:4, y = 1:4, z = 1:4),
      faces = data.frame(i = c(1, 2), j = c(2, 3), k = c(3, 4))
    )
  )

  meshes <- build_tract_meshes(atlas_data, "#CCCCCC", "colour", NULL)

  expect_gt(length(meshes), 0)
})
