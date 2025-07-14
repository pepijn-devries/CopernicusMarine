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

test_that("Copernicus WMTS capabilities can be obtained", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  expect_true({
    cap <- cms_wmts_get_capabilities("GLOBAL_ANALYSISFORECAST_PHY_001_024")
    inherits(cap, "list") && length(cap) > 0
  })
})

test_that("WMTS capabilities are NULL for non-existing product", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  expect_null({
    cms_wmts_get_capabilities("FOOBAR") |> suppressMessages()
  })
})

test_that("WMTS tiles cannot be added when there are multiple layers and non selected", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  expect_error({
    leaflet::leaflet() |>
      addCmsWMTSTiles(
        product = "GLOBAL_ANALYSISFORECAST_PHY_001_024"
      )
  })
})

test_that("WMTS tiles cannot be added for non-existing product", {
  skip_on_cran()
  skip_if_offline("data.marine.copernicus.eu")
  has_gdal_utils()
  expect_error({
    leaflet::leaflet() |>
      addCmsWMTSTiles(
        product = "FOOBAR"
      )
  })
})
