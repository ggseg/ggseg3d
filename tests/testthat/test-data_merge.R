test_that("data_merge works", {
  atlas3d <- get_atlas("dkt_3d", "LCBC", "left")


  someData <- data.frame(
    area = c("transverse temporal", "insula",
             "pre central","superior parietal"),
    p = sample(seq(0,.5,.001), 4),
    stringsAsFactors = F)

  k <- data_merge(someData, atlas3d)

  expect_equal(names(k),
               c("atlas", "surf", "hemi", "area", "colour", "mesh", "label",
                 "roi", "annot", "acronym", "lobe", "p"))

  someData <- data.frame(
    area = c("transverse templral", "insula",
             "pre central","superior parietal"),
    p = sample(seq(0,.5,.001), 4),
    stringsAsFactors = F)

  k <- expect_warning(data_merge(someData, atlas3d),
                      "transverse templral")

  expect_equal(names(k),
               c("atlas", "surf", "hemi", "area", "colour", "mesh", "label",
                 "roi", "annot", "acronym", "lobe", "p"))

})
