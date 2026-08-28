test_that("Check that ggseg3d is working", {
  p <- ggseg3d()
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true("meshes" %in% names(p$x))
  expect_true("options" %in% names(p$x))
  expect_gt(length(p$x$meshes), 0)
  rm(p)

  lifecycle::expect_deprecated(
    p <- ggseg3d(atlas = "aseg")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_gt(length(p$x$meshes), 0)

  expect_error(ggseg3d(atlas = hhj), "object 'hhj")

  expect_warning(
    ggseg3d(
      .data = data.frame(
        region = c(
          "transverse tempral",
          "insula",
          "precentral",
          "superior parietal"
        ),
        p = sample(seq(0, 0.5, 0.001), 4),
        stringsAsFactors = FALSE
      ),
      colour_by = "p"
    )
  )

  dk_regions <- ggseg.formats::atlas_regions(dk())
  some_data <- data.frame(
    region = dk_regions[1:4],
    p = sample(seq(0, 0.5, 0.001), 4),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = some_data,
    colour_by = "p",
    text_by = "p",
    palette = c("black", "white")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  p <- ggseg3d(
    .data = some_data,
    colour_by = "p",
    text_by = "p",
    palette = c("black", "white")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_false(is.null(p$x$colorbar))
  expect_true(p$x$options$showLegend)

  p_hidden <- p |> set_legend(FALSE)
  expect_false(p_hidden$x$options$showLegend)

  p_sized <- ggseg3d() |> set_dimensions(width = 800, height = 600)
  expect_identical(p_sized$width, 800)
  expect_identical(p_sized$height, 600)
})

test_that("ggseg3d works with aseg subcortical atlas", {
  p <- ggseg3d(atlas = aseg())
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_gt(length(p$x$meshes), 0)
})

test_that("ggseg3d with left hemisphere only", {
  p <- ggseg3d(hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_gt(length(p$x$meshes), 0)
})

test_that("ggseg3d with inflated surface", {
  p <- ggseg3d(hemisphere = "left", surface = "inflated")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d handles edge_by parameter", {
  some_data <- data.frame(
    region = ggseg.formats::atlas_regions(dk())[1:4],
    lobe = c("temporal", "insular", "frontal", "parietal"),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = some_data,
    hemisphere = "left",
    edge_by = "lobe"
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d default colorbar is present", {
  p <- ggseg3d()
  expect_true(!is.null(p$x$colorbar) || p$x$colorbar$type == "discrete")
})

test_that("ggseg3d with custom palette", {
  some_data <- data.frame(
    region = ggseg.formats::atlas_regions(dk())[1:2],
    p = c(0.1, 0.9),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = some_data,
    hemisphere = "left",
    colour_by = "p",
    palette = c("blue" = 0, "white" = 0.5, "red" = 1)
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_identical(p$x$colorbar$type, "continuous")
})

test_that("ggseg3d with na_colour and na_alpha", {
  p <- ggseg3d(hemisphere = "left", na_colour = "red", na_alpha = 0.5)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with label_by parameter", {
  p <- ggseg3d(hemisphere = "left", label_by = "label")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("deprecated params trigger warnings", {
  some_data <- data.frame(
    region = ggseg.formats::atlas_regions(dk())[1:2],
    p = c(0.1, 0.5),
    stringsAsFactors = FALSE
  )

  lifecycle::expect_deprecated(
    ggseg3d(hemisphere = "left", colour = "colour")
  )
  lifecycle::expect_deprecated(
    ggseg3d(hemisphere = "left", label = "label")
  )
  lifecycle::expect_deprecated(
    ggseg3d(.data = some_data, text = "p")
  )
})

test_that("ggseg3d with both hemispheres", {
  p <- ggseg3d(hemisphere = c("left", "right"))
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_gte(length(p$x$meshes), 2)
})

test_that("ggseg3d with atlas object instead of string", {
  p <- ggseg3d(atlas = dk(), hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d unified atlas without user data", {
  p <- ggseg3d(atlas = dk(), hemisphere = "left", .data = NULL)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with aseg mesh atlas", {
  p <- ggseg3d(atlas = aseg(), hemisphere = "subcort")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_gt(length(p$x$meshes), 0)
})

test_that("ggseg3d errors on invalid atlas object", {
  expect_error(ggseg3d(atlas = list()), "ggseg_atlas")
  expect_error(ggseg3d(atlas = data.frame()), "ggseg_atlas")
})

test_that("prepare_brain_meshes handles atlas with centerlines", {
  atlas_data <- data.frame(
    label = "tract_a",
    stringsAsFactors = FALSE
  )

  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3,
    byrow = TRUE
  )
  tangents <- matrix(
    c(1, 0, 0, 1, 0, 0, 1, 0, 0),
    nrow = 3,
    byrow = TRUE
  )

  cl_data <- data.frame(label = "tract_a", stringsAsFactors = FALSE)
  cl_data$points <- list(centerline)
  cl_data$tangents <- list(tangents)

  atlas <- tract_atlas_fixture(
    core = data.frame(
      label = "tract_a",
      region = "tract a",
      hemi = "subcort",
      stringsAsFactors = FALSE
    ),
    centerlines = cl_data,
    palette = c("tract_a" = "#FF0000")
  )

  prepared <- prepare_brain_meshes(atlas)

  expect_type(prepared, "list")
  expect_gt(length(prepared$meshes), 0)
})

test_that("prepare_brain_meshes handles atlas$data$meshes path", {
  meshes_data <- data.frame(
    label = "Left-Caudate",
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:3, y = 1:3, z = 1:3),
      faces = data.frame(i = 1L, j = 2L, k = 3L)
    )
  )

  atlas <- subcortical_atlas_fixture(
    core = data.frame(
      label = "Left-Caudate",
      region = "caudate",
      hemi = "subcort",
      stringsAsFactors = FALSE
    ),
    meshes = meshes_data,
    palette = c("Left-Caudate" = "#FF0000")
  )

  prepared <- prepare_brain_meshes(atlas)

  expect_type(prepared, "list")
  expect_gt(length(prepared$meshes), 0)
})

test_that("prepare_brain_meshes uses orientation coloring for tracts", {
  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3,
    byrow = TRUE
  )
  tangents <- matrix(
    c(1, 0, 0, 0, 1, 0, 0, 0, 1),
    nrow = 3,
    byrow = TRUE
  )

  cl_data <- data.frame(label = "tract_a", stringsAsFactors = FALSE)
  cl_data$points <- list(centerline)
  cl_data$tangents <- list(tangents)

  meshes_data <- data.frame(
    label = "tract_a",
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(NULL)

  atlas <- tract_atlas_fixture(
    core = data.frame(
      label = "tract_a",
      region = "tract a",
      hemi = "subcort",
      stringsAsFactors = FALSE
    ),
    centerlines = cl_data,
    meshes = meshes_data,
    palette = c("tract_a" = "#FF0000")
  )

  prepared <- prepare_brain_meshes(atlas, tract_color = "orientation")

  expect_gt(length(prepared$meshes), 0)
  expect_true(all(grepl("^#", prepared$meshes[[1]]$colors)))
})

test_that("prepare_brain_meshes handles cerebellar atlas with vertices", {
  vertices_data <- data.frame(
    label = "left_I-IV",
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:99L)

  atlas <- cerebellar_atlas_fixture(
    atlas = "suit_lobules",
    core = data.frame(
      label = "left_I-IV",
      region = "I-IV",
      hemi = "left",
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    palette = c("left_I-IV" = "#FF0000")
  )

  prepared <- prepare_brain_meshes(atlas)

  expect_type(prepared, "list")
  expect_gt(length(prepared$meshes), 0)
  expect_identical(prepared$meshes[[1]]$colorMode, "vertexcolor")
  expect_identical(prepared$meshes[[1]]$name, "cerebellum")
  expect_length(
    prepared$meshes[[1]]$vertices$x,
    nrow(ggseg.formats::get_cerebellar_mesh()$vertices)
  )
})

test_that("cerebellar atlas colors correct vertices", {
  vertices_data <- data.frame(
    label = c("left_I-IV", "right_V"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:4L, 100L:104L)

  atlas <- cerebellar_atlas_fixture(
    atlas = "test_cer",
    core = data.frame(
      label = c("left_I-IV", "right_V"),
      region = c("I-IV", "V"),
      hemi = c("left", "right"),
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    palette = c(
      "left_I-IV" = "#FF0000",
      "right_V" = "#00FF00"
    )
  )

  prepared <- prepare_brain_meshes(atlas)
  colors <- prepared$meshes[[1]]$colors

  expect_identical(colors[1:5], rep("#FF0000", 5))
  expect_identical(colors[101:105], rep("#00FF00", 5))
  expect_identical(colors[50], "darkgrey")
})

test_that("cerebellar atlas with deep nuclei renders mixed surface + meshes", {
  vertices_data <- data.frame(
    label = "left_I-IV",
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:4L)

  deep_meshes <- data.frame(
    label = "Left-Dentate",
    stringsAsFactors = FALSE
  )
  deep_meshes$mesh <- list(
    list(
      vertices = data.frame(x = 1:4, y = 1:4, z = 1:4),
      faces = data.frame(i = 1L, j = 2L, k = 3L)
    )
  )

  atlas <- cerebellar_atlas_fixture(
    atlas = "suit_deep",
    core = data.frame(
      label = c("left_I-IV", "Left-Dentate"),
      region = c("I-IV", "Dentate"),
      hemi = c("left", "left"),
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    meshes = deep_meshes,
    palette = c(
      "left_I-IV" = "#FF0000",
      "Left-Dentate" = "#0000FF"
    )
  )

  prepared <- prepare_brain_meshes(atlas)

  expect_gte(length(prepared$meshes), 2)
  surface <- prepared$meshes[[1]]
  expect_identical(surface$name, "cerebellum")
  expect_identical(surface$colorMode, "vertexcolor")
  expect_equal(surface$opacity, 0.3)

  deep <- prepared$meshes[[2]]
  expect_identical(deep$name, "Dentate")
  expect_identical(deep$colorMode, "facecolor")
})

test_that("cerebellar surface_opacity can be overridden", {
  vertices_data <- data.frame(
    label = "left_I-IV",
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:4L)

  deep_meshes <- data.frame(
    label = "Left-Dentate",
    stringsAsFactors = FALSE
  )
  deep_meshes$mesh <- list(
    list(
      vertices = data.frame(x = 1:4, y = 1:4, z = 1:4),
      faces = data.frame(i = 1L, j = 2L, k = 3L)
    )
  )

  atlas <- cerebellar_atlas_fixture(
    atlas = "suit_deep",
    core = data.frame(
      label = c("left_I-IV", "Left-Dentate"),
      region = c("I-IV", "Dentate"),
      hemi = c("left", "left"),
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    meshes = deep_meshes,
    palette = c(
      "left_I-IV" = "#FF0000",
      "Left-Dentate" = "#0000FF"
    )
  )

  prepared <- prepare_brain_meshes(atlas, surface_opacity = 0.5)
  expect_equal(prepared$meshes[[1]]$opacity, 0.5)
})

test_that("merge_legend_data handles NULL inputs", {
  legend <- data.frame(label = "a", colour = "#FF0000")

  expect_null(merge_legend_data(NULL, NULL))
  expect_identical(merge_legend_data(NULL, legend), legend)
  expect_identical(merge_legend_data(legend, NULL), legend)

  combined <- merge_legend_data(legend, legend)
  expect_identical(nrow(combined), 1L)
})

test_that("build_cerebellar_meshes errors when mesh unavailable", {
  local_mocked_bindings(
    get_cerebellar_mesh = function(...) NULL,
    .package = "ggseg.formats"
  )
  expect_error(
    build_cerebellar_meshes(data.frame(), "darkgrey"),
    "SUIT cerebellar mesh"
  )
})

test_that("build_cerebellar_meshes flags flatmap meshes", {
  flat_mesh <- list(
    vertices = data.frame(
      x = c(0, 1, 2, 3),
      y = c(0, 1, 0, 1),
      z = c(0, 0, 0, 0)
    ),
    faces = data.frame(i = c(1L, 2L), j = c(2L, 3L), k = c(3L, 4L))
  )
  local_mocked_bindings(
    get_cerebellar_mesh = function(...) flat_mesh,
    .package = "ggseg.formats"
  )

  atlas_data <- data.frame(
    label = "region1",
    region = "region1",
    colour = "#FF0000"
  )
  atlas_data$vertices <- list(0:3)

  meshes <- build_cerebellar_meshes(atlas_data, "darkgrey")

  expect_length(meshes, 1)
  expect_true(isTRUE(meshes[[1]]$isFlatmap))
})

test_that("check_ggseg_meshes errors when package missing", {
  local_mocked_bindings(
    requireNamespace = function(...) FALSE,
    .package = "base"
  )
  expect_error(check_ggseg_meshes("pial"), "ggseg.meshes")
})

test_that("cerebellar atlas with text_by populates vertex texts", {
  vertices_data <- data.frame(
    label = "left_I-IV",
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:4L)

  atlas <- cerebellar_atlas_fixture(
    atlas = "suit_text",
    core = data.frame(
      label = "left_I-IV",
      region = "I-IV",
      hemi = "left",
      score = 0.75,
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    palette = c("left_I-IV" = "#FF0000")
  )

  prepared <- prepare_brain_meshes(atlas, text_by = "score")
  texts <- prepared$meshes[[1]]$vertexTexts
  expect_false(is.null(texts))
  expect_match(texts[1], "score")
})

test_that("prepare_brain_meshes.default errors on unknown atlas class", {
  fake <- structure(list(), class = "weird_atlas")
  expect_error(prepare_brain_meshes(fake), "No method")
})

test_that("ggseg3d errors on nonexistent string atlas name", {
  expect_error(
    lifecycle::expect_deprecated(
      ggseg3d(atlas = "nonexistent_atlas_xyz")
    ),
    "Could not find atlas"
  )
})

test_that("vertices_to_text returns NA vector when column is missing", {
  atlas_data <- data.frame(
    label = "a",
    region = "r",
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0L, 1L))

  result <- vertices_to_text(atlas_data, 3, "nonexistent")

  expect_length(result, 3)
  expect_true(all(is.na(result)))
})

test_that("text_by works with subcortical atlas", {
  aseg_regions <- ggseg.formats::atlas_regions(aseg())
  some_data <- data.frame(
    region = aseg_regions[1:2],
    p = c(0.1, 0.5),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(.data = some_data, atlas = aseg(), text_by = "p")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  hover_texts <- vapply(
    p$x$meshes,
    function(m) m$hoverText %||% "",
    character(1)
  )
  expect_true(any(grepl("p:", hover_texts, fixed = TRUE)))
})

test_that("text_by works with tract atlas", {
  tracula_regions <- ggseg.formats::atlas_regions(tracula())
  some_data <- data.frame(
    region = tracula_regions[1:2],
    fa = c(0.45, 0.55),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(.data = some_data, atlas = tracula(), text_by = "fa")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  hover_texts <- vapply(
    p$x$meshes,
    function(m) m$hoverText %||% "",
    character(1)
  )
  expect_true(any(grepl("fa:", hover_texts, fixed = TRUE)))
})
