test_that("Glossary is retrieved succesfully", {
  expect_s3_class({
    result <- cms_glossary()
    if (nrow(result) < 2) stop("Returned insufficient rows")
    result
  }, "data.frame")
})