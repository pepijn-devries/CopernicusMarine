test_that("Copernicus WMS tile can be added to a map", {
  has_internet()
  testthat::expect_error({
    leaflet::leaflet() %>%
      addCopernicusWMSTiles(
        product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
        variable = "thetao"
      )
  }, NA)
})

test_that("WMS services can be listed", {
  has_internet()
  expect_true({
    cp <-
      copernicus_wms_details(
        product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
        variable = "thetao"
    )
    is.data.frame(cp) && nrow(cp) > 0
  })
})

test_that("Copernicus WMS tile can be stored as valid geoTIFF", {
  has_internet()
  expect_error({
    destination <- tempfile("wms", fileext = ".tiff")
    copernicus_wms2geotiff(
      product     = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
      layer       = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
      variable    = "thetao",
      region      = c(-1, 50, 7, 60),
      destination = destination,
      width       = 1920,
      height      = 1080
    )
    obj <- stars::read_stars(destination)
  }, NA)
})