test_that("Check that ggseg3d is working", {
  p = ggseg3d()
  expect_is(p, c("plotly", "htmlwidget"))
  expect_equal(length(p$x), 6)
  expect_equal(length(p$x$attrs), 37)
  rm(p)

  p = ggseg3d(atlas="aseg_3d")
  expect_equal(length(p$x$attrs), 33)

  expect_error(ggseg3d(atlas=dk), "object 'dk' not found")

  dk <- data.frame(.long = double(),
                   .lat = double(),
                   .id = character(),
                   region = as.character(),
                   hemi = character(),
                   side = character())
  expect_error(ggseg3d(atlas=dk), "This is not a 3d atlas")
  expect_error(ggseg3d(atlas=hhj), "object 'hhj")
  expect_error(ggseg3d(atlas=dk_3d, hemisphere = "hi"), "hemisphere")


  expect_warning(
    ggseg3d(.data=data.frame(
      region = c("transverse tempral", "insula",
                 "precentral","superior parietal"),
      p = sample(seq(0,.5,.001), 4), stringsAsFactors = FALSE),
      colour = "p")
  )

  expect_error(
    ggseg3d(.data=data.frame(
      region = c("transverse temporal", "insula",
                 "precentral","superior parietal"),
      p = sample(seq(0,.5,.001), 4), stringsAsFactors = F),
      colour = "p", palette="ponyomedium")
  )

  someData <- data.frame(
    region = c("transverse temporal", "insula",
               "precentral","superior parietal"),
    p = sample(seq(0,.5,.001), 4),
    stringsAsFactors = F)

  expect_is(
    ggseg3d(.data=someData,
            colour = "p", text="p", palette=c("black", "white")),
    c("plotly", "htmlwidget")
  )

  expect_is(
    ggseg3d(.data=someData,
            colour = "p", text="p", palette=c("black", "white"),
            show.legend = T),
    c("plotly", "htmlwidget")
  )

  expect_error(ggseg3d(atlas = aseg_3d, surface = "white"), "no surface")

})


