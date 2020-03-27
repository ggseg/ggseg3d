test_that("data_merge works", {
  atlas3d <- get_atlas("dk_3d", "LCBC", "left")

  someData <- data.frame(
    region = c("transverse temporal", "insula",
             "precentral","superior parietal"),
    p = sample(seq(0,.5,.001), 4),
    stringsAsFactors = F)

  k <- data_merge(someData, atlas3d)

  expect_equal(names(k),
               c("atlas", "surf", "hemi", "region", "colour", "mesh", "label",
                 "roi", "annot", "p"))

  someData <- data.frame(
    region = c("transverse templral", "insula",
             "precentral","superior parietal"),
    p = sample(seq(0,.5,.001), 4),
    stringsAsFactors = F)

  k <- expect_warning(data_merge(someData, atlas3d),
                      "transverse templral")

  expect_equal(names(k),
               c("atlas", "surf", "hemi", "region", "colour", "mesh", "label",
                 "roi", "annot", "p"))

})
