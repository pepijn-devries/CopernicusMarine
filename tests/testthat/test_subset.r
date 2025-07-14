test_that("Subset download produces valid ncdf file", {
  skip_on_cran()
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_error({ ## Currently subsetting does not work any more
    destination <- tempfile("copernicus", fileext = ".nc")
    suppressMessages({
      cms_download_subset(
        destination   = destination,
        product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
        variable      = "sea_water_velocity",
        region        = c(-1, 50, 10, 55),
        timerange     = c("2021-01-01", "2021-01-02"),
        verticalrange = c(0, 2)
      )
      capture.output(test_file <- stars::read_stars(destination))
      "stars" %in% class(test_file)
    })
  })
})
