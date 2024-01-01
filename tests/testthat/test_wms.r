test_that("Copernicus WMS tile can be added to a map", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  testthat::expect_error({
    suppressWarnings({
      leaflet::leaflet() |>
        addCopernicusWMSTiles(
          product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
          layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
          variable = "thetao"
        )
    })
  }, NA)
})

test_that("Copernicus WMS tile can be stored as valid geoTIFF", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  expect_error({
    destination <- tempfile("wms", fileext = ".tiff")
    suppressWarnings({
      copernicus_wms2geotiff(
        product     = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer       = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
        variable    = "thetao",
        region      = c(-1, 50, 7, 60),
        destination = destination,
        width       = 1920,
        height      = 1080
      )
    })
    obj <- stars::read_stars(destination)
  }, NA)
})