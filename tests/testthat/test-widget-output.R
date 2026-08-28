test_that("ggseg3dOutput creates shiny output", {
  output <- ggseg3dOutput("brain_plot")

  expect_s3_class(output, "shiny.tag.list")
})

test_that("ggseg3dOutput accepts custom dimensions", {
  output <- ggseg3dOutput("brain_plot", width = "800px", height = "600px")

  expect_s3_class(output, "shiny.tag.list")
})

test_that("renderGgseg3d creates render function", {
  render_fn <- renderGgseg3d({
    ggseg3d()
  })

  expect_type(render_fn, "closure")
})

test_that("renderGgseg3d with quoted expression", {
  expr <- quote(ggseg3d())
  render_fn <- renderGgseg3d(expr, quoted = TRUE)

  expect_type(render_fn, "closure")
})

test_that("updateGgseg3dCamera builds correct message type", {
  mock_session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )

  result <- mock_session$sendCustomMessage(
    paste0("ggseg3d-camera-", "brain_plot"),
    "left lateral"
  )

  expect_identical(result$type, "ggseg3d-camera-brain_plot")
  expect_identical(result$message, "left lateral")
})

test_that("updateGgseg3dBackground converts named color to hex", {
  converted <- col2hex("red")
  expect_identical(converted, "#FF0000")

  converted <- col2hex("blue")
  expect_identical(converted, "#0000FF")
})

test_that("updateGgseg3dCamera function exists and is exported", {
  expect_type(updateGgseg3dCamera, "closure")
})

test_that("updateGgseg3dBackground function exists and is exported", {
  expect_type(updateGgseg3dBackground, "closure")
})

test_that("updateGgseg3dCamera calls sendCustomMessage", {
  messages <- new.env(parent = emptyenv())
  mock_session <- list(
    sendCustomMessage = function(type, message) {
      messages$type <- type
      messages$message <- message
    }
  )

  updateGgseg3dCamera(mock_session, "test_output", "left lateral")

  expect_identical(messages$type, "ggseg3d-camera-test_output")
  expect_identical(messages$message, "left lateral")
})

test_that("updateGgseg3dBackground calls sendCustomMessage with hex color", {
  messages <- new.env(parent = emptyenv())
  mock_session <- list(
    sendCustomMessage = function(type, message) {
      messages$type <- type
      messages$message <- message
    }
  )

  updateGgseg3dBackground(mock_session, "test_output", "red")

  expect_identical(messages$type, "ggseg3d-background-test_output")
  expect_identical(messages$message, "#FF0000")
})

test_that("updateGgseg3dBackground passes hex color through", {
  messages <- new.env(parent = emptyenv())
  mock_session <- list(
    sendCustomMessage = function(type, message) {
      messages$type <- type
      messages$message <- message
    }
  )

  updateGgseg3dBackground(mock_session, "test_output", "#AABBCC")

  expect_identical(messages$message, "#AABBCC")
})
