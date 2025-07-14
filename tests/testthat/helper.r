has_account_details <- function() {
  if ((cms_get_username() == "") || cms_get_password() == "") {
    skip("No Copernicus account details found")
  }
}

has_gdal_utils <- function() {
  result <- tryCatch({
    cp <-
      cms_wmts_details(
        product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
        variable = "thetao"
      )
    is.data.frame(cp) && nrow(cp) > 0
  }, error = function(e) FALSE)
  if (!result) {
    skip("No functional GDAL utils available")
  }
}