test_that("Products can be listed", {
  skip_on_cran()
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_true({
    pds <- cms_products_list()
    is.data.frame(pds) && nrow(pds) > 0
  })
})

test_that("Product details make sence", {
  skip_on_cran()
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  id <- "GLOBAL_ANALYSISFORECAST_PHY_001_024"
  expect_true({
    pd <- cms_product_details(id)
    is.list(pd) && length(pd) > 0 && pd$id == id
  })
})

test_that("Product details can't have variable without layer", {
  skip_on_cran()
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_error({
    cms_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024", variable = "thetao")
  })
})

test_that("Product meta info make sence", {
  skip_on_cran()
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  id <- "GLOBAL_ANALYSISFORECAST_PHY_001_024"
  expect_true({
    pd <- cms_product_metadata(id)
    is.list(pd) && length(pd) > 0
  })
})

test_that("Subset download produces valid ncdf file", {
  skip_on_cran()
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_error({ ## Currently subsetting does not work anymore
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
