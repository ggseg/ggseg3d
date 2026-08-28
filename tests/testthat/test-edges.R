test_that("find_boundary_edges finds edges between different colors", {
  faces <- data.frame(
    i = c(1, 2),
    j = c(2, 3),
    k = c(3, 4)
  )
  vertex_colors <- c("#FF0000", "#FF0000", "#00FF00", "#00FF00")

  edges <- find_boundary_edges(faces, vertex_colors)

  expect_gt(length(edges), 0)
  edge_vertices <- unlist(edges)
  expect_true(1 %in% edge_vertices || 2 %in% edge_vertices)
})

test_that("find_boundary_edges returns empty for uniform colors", {
  faces <- data.frame(
    i = c(1, 2),
    j = c(2, 3),
    k = c(3, 4)
  )
  vertex_colors <- rep("#FF0000", 4)

  edges <- find_boundary_edges(faces, vertex_colors)

  expect_length(edges, 0)
})

test_that("find_boundary_edges handles single face", {
  faces <- data.frame(i = 1, j = 2, k = 3)
  vertex_colors <- c("#FF0000", "#00FF00", "#0000FF")

  edges <- find_boundary_edges(faces, vertex_colors)

  expect_length(edges, 3)
})

test_that("find_boundary_edges deduplicates shared edges", {
  faces <- data.frame(
    i = c(1, 2),
    j = c(2, 3),
    k = c(3, 3)
  )
  vertex_colors <- c("#FF0000", "#00FF00", "#00FF00", "#00FF00")

  edges <- find_boundary_edges(faces, vertex_colors)

  edge_keys <- vapply(
    edges,
    function(e) paste(sort(e), collapse = "-"),
    character(1)
  )
  expect_length(edge_keys, length(unique(edge_keys)))
})

test_that("find_boundary_edges skips NA groups without NAs in output", {
  faces <- data.frame(
    i = c(1, 2, 3),
    j = c(2, 3, 4),
    k = c(3, 4, 5)
  )
  vertex_colors <- c(NA, NA, "A", "B", NA)

  edges <- find_boundary_edges(faces, vertex_colors)

  expect_gt(length(edges), 0)
  edge_verts <- unlist(edges)
  expect_false(anyNA(edge_verts))
})

test_that("find_boundary_edges returns empty for all-NA groups", {
  faces <- data.frame(i = 1, j = 2, k = 3)
  vertex_colors <- c(NA, NA, NA)

  edges <- find_boundary_edges(faces, vertex_colors)

  expect_length(edges, 0)
})
