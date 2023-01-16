test_that("Products can be listed", {
  has_account_details()
  has_internet()
  expect_true({
    pds <- copernicus_products_list()
    is.data.frame(pds) && nrow(pds) > 0
  })
})

test_that("Product details make sence", {
  has_account_details()
  has_internet()
  id <- "GLOBAL_ANALYSISFORECAST_PHY_001_024"
  expect_true({
    pd <- copernicus_product_details(id)
    is.list(pd) && length(pd) > 0 && pd$id == id
  })
})

test_that("Product details can't have variable without layer", {
  has_account_details()
  has_internet()
  expect_error({
    copernicus_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024", variable = "thetao")
  })
})

test_that("Product meta info make sence", {
  has_account_details()
  has_internet()
  id <- "GLOBAL_ANALYSISFORECAST_PHY_001_024"
  expect_true({
    pd <- copernicus_product_metadata(id)
    is.list(pd) && length(pd) > 0
  })
})

test_that("Motu download produces valid ncdf file", {
  has_account_details()
  has_internet()
  expect_true({
    destination <- tempfile("copernicus", fileext = ".nc")
    copernicus_download_motu(
      destination   = destination,
      product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
      layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
      variable      = "sea_water_velocity",
      output        = "netcdf",
      region        = c(-1, 50, 10, 55),
      timerange     = c("2021-01-01", "2021-01-02"),
      verticalrange = c(0, 2),
      sub_variables = c("uo", "vo")
    )
    test_file <- stars::read_stars(destination)
    "stars" %in% class(test_file)
  })
})
