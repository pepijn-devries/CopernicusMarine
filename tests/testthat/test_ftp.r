test_that("Copernicus files can be downloaded via FTP", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_account_details()
  expect_error({
    cop_ftp_files <- copernicus_ftp_list("GLOBAL_OMI_WMHE_heattrp")
    if (!is.data.frame(cop_ftp_files) || nrow(cop_ftp_files) == 0)
      stop("Couldn't list files")
    destination   <- tempdir()
    
    copernicus_ftp_get(cop_ftp_files$url[[1]], destination, overwrite = TRUE, show_progress = F)
    suppressWarnings(
      suppressMessages(
        obj <- stars::read_ncdf(file.path(destination, basename(cop_ftp_files$url[[1]])))
      )
    )
  }, NA)
})
