has_internet <- function() {
  if(
    tryCatch(
      "https://data.marine.copernicus.eu" %>%
      httr::GET(httr::timeout(1)) %>%
      httr::http_error(),
      error = function(e) TRUE)
  ) skip("No internet connection")
}

has_account_details <- function() {
  if (is.null(getOption("CopernicusMarine_uid")) || is.null(getOption("CopernicusMarine_pwd"))) {
    skip("No Copernicus account details found")
  }
}
