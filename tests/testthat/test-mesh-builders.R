test_that("make_mesh_entry creates correct structure", {
  vertices <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2))
  faces <- data.frame(i = 1, j = 2, k = 3)

  entry <- make_mesh_entry(
    name = "test mesh",
    vertices = vertices,
    faces = faces,
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    color_mode = "vertexcolor",
    opacity = 0.8,
    hover_text = "hover info"
  )

  expect_identical(entry$name, "test mesh")
  expect_identical(entry$vertices$x, c(0, 1, 2))
  expect_identical(entry$vertices$y, c(0, 1, 2))
  expect_identical(entry$vertices$z, c(0, 1, 2))
  expect_identical(entry$faces$i, 0L)
  expect_identical(entry$faces$j, 1L)
  expect_identical(entry$faces$k, 2L)
  expect_identical(entry$colorMode, "vertexcolor")
  expect_equal(entry$opacity, 0.8)
  expect_identical(entry$hoverText, "hover info")
})

test_that("make_mesh_entry includes boundary edges when provided", {
  vertices <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2))
  faces <- data.frame(i = 1, j = 2, k = 3)
  boundary <- list(c(0, 1), c(1, 2))

  entry <- make_mesh_entry(
    name = "test",
    vertices = vertices,
    faces = faces,
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    boundary_edges = boundary
  )

  expect_identical(entry$boundaryEdges, boundary)
})

test_that("make_mesh_entry includes edge color and width when provided", {
  vertices <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2))
  faces <- data.frame(i = 1, j = 2, k = 3)

  entry <- make_mesh_entry(
    name = "test",
    vertices = vertices,
    faces = faces,
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    edge_color = "#000000",
    edge_width = 2
  )

  expect_identical(entry$edgeColor, "#000000")
  expect_identical(entry$edgeWidth, 2)
})

test_that("make_mesh_entry uses default edge width of 1", {
  vertices <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2))
  faces <- data.frame(i = 1, j = 2, k = 3)

  entry <- make_mesh_entry(
    name = "test",
    vertices = vertices,
    faces = faces,
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    edge_color = "#000000"
  )

  expect_identical(entry$edgeWidth, 1)
})

test_that("build_subcortical_meshes creates mesh entries for each region", {
  atlas_data <- data.frame(
    label = c("Left-Caudate", "Right-Caudate"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2)),
      faces = data.frame(i = c(1, 2), j = c(2, 3), k = c(3, 1))
    ),
    list(
      vertices = data.frame(x = c(3, 4, 5), y = c(3, 4, 5), z = c(3, 4, 5)),
      faces = data.frame(i = c(1, 2), j = c(2, 3), k = c(3, 1))
    )
  )

  meshes <- build_subcortical_meshes(atlas_data, "#CCCCCC")

  expect_length(meshes, 2)
  expect_identical(meshes[[1]]$name, "Left-Caudate")
  expect_identical(meshes[[2]]$name, "Right-Caudate")
  expect_identical(meshes[[1]]$colorMode, "facecolor")
})

test_that("build_subcortical_meshes handles NA colours", {
  atlas_data <- data.frame(
    label = "region_a",
    colour = NA_character_,
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2)),
      faces = data.frame(i = 1, j = 2, k = 3)
    )
  )

  meshes <- build_subcortical_meshes(atlas_data, "#AABBCC")

  expect_identical(unique(meshes[[1]]$colors), "#AABBCC")
})

test_that("build_subcortical_meshes skips NULL meshes", {
  atlas_data <- data.frame(
    label = c("region_a", "region_b"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    NULL,
    list(
      vertices = data.frame(x = c(0, 1, 2), y = c(0, 1, 2), z = c(0, 1, 2)),
      faces = data.frame(i = 1, j = 2, k = 3)
    )
  )

  meshes <- build_subcortical_meshes(atlas_data, "#CCCCCC")

  expect_length(meshes, 1)
  expect_identical(meshes[[1]]$name, "region_b")
})

test_that("build_tract_meshes creates vertex-colored meshes", {
  atlas_data <- data.frame(
    label = "tract_a",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(
        x = c(0, 1, 2, 3),
        y = c(0, 1, 2, 3),
        z = c(0, 1, 2, 3)
      ),
      faces = data.frame(i = c(1, 2), j = c(2, 3), k = c(3, 4))
    )
  )

  meshes <- build_tract_meshes(atlas_data, "#CCCCCC", color_by = "colour")

  expect_length(meshes, 1)
  expect_identical(meshes[[1]]$colorMode, "vertexcolor")
  expect_identical(meshes[[1]]$name, "tract_a")
})

test_that("build_tract_meshes handles orientation coloring", {
  atlas_data <- data.frame(
    label = "tract_a",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )

  tangents <- matrix(c(1, 0, 0, 0, 1, 0, 0, 0, 1), nrow = 3, byrow = TRUE)

  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:6, y = 1:6, z = 1:6),
      faces = data.frame(i = c(1, 2), j = c(2, 3), k = c(3, 4)),
      metadata = list(
        n_centerline_points = 3,
        tangents = tangents
      )
    )
  )

  meshes <- build_tract_meshes(atlas_data, "#CCCCCC", color_by = "orientation")

  expect_length(meshes, 1)
  expect_identical(meshes[[1]]$colorMode, "vertexcolor")
  expect_length(meshes[[1]]$colors, 6)
})

test_that("tangents_to_colors computes direction-based colors", {
  mesh_data <- list(
    vertices = data.frame(x = 1:6, y = 1:6, z = 1:6),
    metadata = list(
      n_centerline_points = 3,
      tangents = matrix(
        c(
          1,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          1
        ),
        nrow = 3,
        byrow = TRUE
      )
    )
  )

  colors <- tangents_to_colors(mesh_data)

  expect_length(colors, 6)
  expect_identical(colors[1], grDevices::rgb(1, 0, 0))
  expect_identical(colors[2], grDevices::rgb(1, 0, 0))
  expect_identical(colors[3], grDevices::rgb(0, 1, 0))
  expect_identical(colors[4], grDevices::rgb(0, 1, 0))
  expect_identical(colors[5], grDevices::rgb(0, 0, 1))
  expect_identical(colors[6], grDevices::rgb(0, 0, 1))
})

test_that("tangents_to_colors handles mixed directions", {
  mesh_data <- list(
    vertices = data.frame(x = 1:4, y = 1:4, z = 1:4),
    metadata = list(
      n_centerline_points = 2,
      tangents = matrix(
        c(
          1,
          1,
          0,
          0,
          1,
          1
        ),
        nrow = 2,
        byrow = TRUE
      )
    )
  )

  colors <- tangents_to_colors(mesh_data)

  expect_length(colors, 4)
  expect_true(all(grepl("^#", colors)))
})
