test_that("native download works", {
  skip_if_offline()
  skip_on_cran()
  on.exit({setTimeLimit(elapse = Inf)})
  expect_true({
    result <- 
      tryCatch({
        setTimeLimit(elapsed = 5)
        cms_download_native(
          destination   = tempdir(),
          product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
          layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
          pattern       = "m_20220630",
          progress      = FALSE
        )
        TRUE
      }, error = function(e) {
        setTimeLimit(elapse = Inf)
        closeAllConnections()
        return(e$message == "reached elapsed time limit")
      })
    unlink(file.path(tempdir(), "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m"), recursive = TRUE)
    result
  })
})