test_that("Source code should not have things on TODO list", {
  skip_on_ci()
  skip_on_cran()
  skip_if(length(unclass(packageVersion("CopernicusMarine"))[[1]]) > 3,
          "Skipping during development")
            
  expect_false({
    files_to_check <-
      list.files(system.file(package = "CopernicusMarine"),
                 pattern = "[.]r$|NEWS|DESCRIPTION|README", recursive = TRUE, full.names = TRUE)
    files_to_check <- files_to_check[!endsWith(files_to_check, "test_dev.r") &
                                       !endsWith(files_to_check, ".png")]
    any(
      unlist(
        lapply(files_to_check, function(file) {
          content <- suppressWarnings(readLines(file))
          result  <- grepl("TODO", content) & !grepl("grepl\\(\"TODO\"", content) & !grepl("on TODO list", content)
          if (any(result)) {
            warning(sprintf("File `%s` has items on TODO list at lines `%s`", file, paste(which(result), collapse = "`, `")))
          }
          any(result)
        })
      )
    )
  })
})
