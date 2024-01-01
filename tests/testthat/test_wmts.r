test_that("Copernicus WMTS tile can be added to a map", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  testthat::expect_no_error({
      leaflet::leaflet() |>
        addCmsWMTSTiles(
          product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
          layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
          variable = "thetao"
        )
  })
})