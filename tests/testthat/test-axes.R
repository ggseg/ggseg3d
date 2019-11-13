test_that("check that remove_axes works", {
  p = ggseg3d() %>%
    remove_axes()

  expect_is(p, c("plotly", "htmlwidget"))
  expect_equal(length(p$x$attrs), 37)

  expect_true("layoutAttrs" %in% names(p$x))
  expect_equal(p$x$layoutAttrs[[1]]$scene$xaxis,
               list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE,
                    showgrid = FALSE, showbackground = FALSE))
  expect_equal(p$x$layoutAttrs[[1]]$scene$yaxis,
               list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE,
                    showgrid = FALSE, showbackground = FALSE))
  expect_equal(p$x$layoutAttrs[[1]]$scene$zaxis,
               list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE,
                    showgrid = FALSE, showbackground = FALSE))

})
