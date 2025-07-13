test_that("Listing products works", {
  expect_true({
    skip_on_cran()
    skip_if_offline()
    inherits(cms_products_list(), "tbl") &&
      inherits(cms_products_list2(), "list")
  })
})

test_that("Citing a product works", {
  skip_on_cran()
  skip_if_offline()
  expect_equal(
    cms_cite_product("SST_MED_PHY_SUBSKIN_L4_NRT_010_036")$`sci:doi`,
    "10.48670/moi-00170"
  )
})

test_that("Product services can be obtained", {
  skip_on_cran()
  skip_if_offline()
  expect_true({
    services <- cms_product_services("GLOBAL_ANALYSISFORECAST_PHY_001_024")
    inherits(services, "tbl") &&
      startsWith(services$native_href[[1]], "https://")
  })
})

test_that("Product meta data can be obtained", {
  skip_on_cran()
  skip_if_offline()
  expect_true({
    pr <- "GLOBAL_ANALYSISFORECAST_PHY_001_024"
    metadat <- cms_product_metadata(pr)
    inherits(metadat, "tbl") &&
      (metadat$collection[[1]] == "GLOBAL_ANALYSISFORECAST_PHY_001_024")
  })
})

test_that("Product details can be obtained", {
  skip_on_cran()
  skip_if_offline()
  expect_true({
    pr <- "GLOBAL_ANALYSISFORECAST_PHY_001_024"
    details <- cms_product_details(pr)
    inherits(details, "list") &&
      (details$id == "GLOBAL_ANALYSISFORECAST_PHY_001_024")
  })
})

test_that("Requesting nonexisting product citation details returns NULL", {
  skip_on_cran()
  skip_if_offline()
  expect_null({
    cms_cite_product("FOOBAR") |> suppressMessages()
  })
})

test_that("Requesting nonexisting product services returns NULL", {
  skip_on_cran()
  skip_if_offline()
  expect_null({
    cms_product_services("FOOBAR") |> suppressMessages()
  })
})

test_that("Requesting nonexisting product details returns NULL", {
  skip_on_cran()
  skip_if_offline()
  expect_null({
    cms_product_details("FOOBAR") |> suppressMessages()
  })
})

test_that("Deprecated argument 'variant' raises warning", {
  skip_on_cran()
  skip_if_offline()
  expect_warning({
    cms_product_details("", variant = "FOOBAR") |> suppressMessages()
  })
})

test_that("Deprecated argument 'layer' raises warning", {
  skip_on_cran()
  skip_if_offline()
  expect_warning({
    cms_product_details("", layer = "FOOBAR") |> suppressMessages()
  })
})
