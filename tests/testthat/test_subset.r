test_that("Subset download produces expected data", {
  skip_on_cran()
  skip_if_not_installed("blosc")
  skip_if_not_installed("ncmeta")
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_true({
    data_sub <-
      cms_download_subset(
        product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
        variable      = c("uo"),
        region        = c(-1, 50, 10, 55),
        timerange     = c("2025-01-01"),
        verticalrange = c(0, -1)
      ) |>
      suppressMessages()
    
    file_reference <- file.path(tempdir(), "test_data_python.nc")
    download.file("https://raw.githubusercontent.com/pepijn-devries/CopernicusMarine/refs/heads/master/data-raw/test_data_python.nc",
                  file_reference, method = "curl", quiet = TRUE)
    data_reference <- stars::read_ncdf(file_reference) |> suppressMessages()
    unlink(file_reference)
    
    matching_bbox <-
      abs(as.numeric(
        sf::st_distance(
          sf::st_bbox(data_sub) |> sf::st_as_sfc(),
          sf::st_bbox(data_reference) |> sf::st_as_sfc()
        )
      )) < 1e-2
    
    dm <- c("longitude", "latitude")
    matching_dimensions <- all(dim(data_sub)[dm] == dim(data_reference)[dm])
    matching_values <- all(na.omit(c(data_reference["uo",,,1,1][["uo"]])) ==
                            na.omit(c(data_sub["uo",,,,][["uo"]])))
    matching_bbox && matching_dimensions && matching_values
  })
})

test_that("Subsetting out of range results in error", {
  skip_on_cran()
  skip_if_not_installed("blosc")
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_error({
    data_sub <-
      cms_download_subset(
        product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
        variable      = c("uo"),
        region        = c(-1, 50, 10, 55),
        timerange     = c("1900-01-01", "1900-01-02"),
        verticalrange = c(0, -2)
      ) |>
      suppressMessages()
  })
})

test_that("A static map can be downloaded", {
  skip_on_cran()
  skip_if_not_installed("blosc")
  has_account_details()
  skip_if_offline("data.marine.copernicus.eu")
  expect_no_error({
    cms_download_subset(
      product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
      layer         = "cmems_mod_glo_phy_anfc_0.083deg_static_202211--ext--coords",
      variable      = c("e1t"),
      region        = c(-1, 50, 10, 55)
    ) |>
      suppressMessages()
  })
})

test_that("Codes are converted correctly to periods", {
  expect_true({
    all((lapply(c("PT1H", "PT5H", "P1D", "P1M"), CopernicusMarine:::.code_to_period) |>
           lapply(as.numeric) |>
           unlist()) == c(3600, 21600, 86400, 2629800))
  })
})

test_that("Unknown time code throws error", {
  expect_error({
    CopernicusMarine:::.code_to_period("XXX")
  })
})