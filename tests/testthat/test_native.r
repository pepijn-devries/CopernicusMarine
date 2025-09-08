test_that("native download works", {
  skip_if_offline()
  skip_on_cran()
  expect_true({
    Sys.setenv(R_COPERNICUS_MARINE_TESTING = TRUE)
    cms_download_native(
      destination   = tempdir(),
      product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
      layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
      prefix        = "2022/06/",
      pattern       = "m_20220630",
      progress      = TRUE
    ) |>
      suppressMessages()
    Sys.unsetenv("R_COPERNICUS_MARINE_TESTING")
    pt <- file.path(tempdir(),
                    "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m_202406")
    fl <- list.files(
      pt, recursive = TRUE, full.names = TRUE)
    result <- if (length(fl) > 0)
      file.size(fl[[1]]) > 0 else FALSE
    unlink(pt, recursive = TRUE)
    result
  })
})

test_that("Native files can be listed", {
  skip_if_offline()
  skip_on_cran()
  expect_true({
    pref <- "2025/06/"
    file_list <-
      cms_list_native_files(
        product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
        prefix        = pref,
        max           = 5L
      )
    nrow(file_list) == 5L && all(grepl(pref, file_list$Key, fixed = TRUE))
  })
})
