python_code <-
  "import copernicusmarine

copernicusmarine.subset(
  dataset_id=\"cmems_mod_glo_phy_anfc_0.083deg_PT1H-m\",
  variables=[\"uo\",\"vo\"],
  minimum_longitude=-2,
  maximum_longitude=8,
  minimum_latitude=52,
  maximum_latitude=59,
  start_datetime=\"2025-01-01T00:00:00\",
  end_datetime=\"2025-01-01T23:00:00\",
  minimum_depth=0.49402499198913574,
  maximum_depth=0.49402499198913574,
)"

cli_code <-
  "copernicusmarine subset
  --dataset-id cmems_mod_glo_phy_anfc_0.083deg_PT1H-m
  --variable uo
  --variable vo
  --start-datetime 2025-01-01T00:00:00
  --end-datetime 2025-01-01T23:00:00
  --minimum-longitude -2
  --maximum-longitude 8
  --minimum-latitude 52
  --maximum-latitude 59
  --minimum-depth 0.49402499198913574
  --maximum-depth 0.49402499198913574"

test_that("Request code can be translated", {
  skip_on_cran()
  skip_if_offline()
  expect_identical({
    cms_translate(cli_code)
  }, cms_translate(python_code))
})