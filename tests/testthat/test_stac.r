test_that("Copernicus files can be downloaded via STAC", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  expect_no_error({
    stac_files <- cms_list_stac_files("GLOBAL_OMI_WMHE_heattrp")
    if (!is.data.frame(stac_files) || nrow(stac_files) == 0)
      stop("Couldn't list files")
    destination   <- tempdir()

    suppressWarnings({
      suppressMessages({
        cms_download_stac(stac_files[1,], destination, overwrite = TRUE, show_progress = FALSE)
        obj <- stars::read_ncdf(file.path(destination, basename(stac_files$current_path[[1]])))
      })
    })
  })
})
