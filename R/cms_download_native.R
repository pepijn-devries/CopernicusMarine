#' @examples
#' cms_download_native(
#'   destination   = tempdir(),
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m"
#' )
#' 
#' @export
cms_download_native <- function(destination, product, layer, ...) {
  services <-
    cms_product_services(product) |>
    dplyr::filter(startsWith(.data$id, layer))
  native_url <- services$native_href
  ## TODO regex used in python toolbox to parse url
  parse_regex <- "^(http|https):\\/\\/([\\w\\-\\.]+)(:[\\d]+)?(\\/.*)"
  
  m <- gregexpr(parse_regex, native_url, perl = TRUE)
  m_start  <- attr(m[[1]], "capture.start")
  m_length <- attr(m[[1]], "capture.length")
  fragments <-
    mapply(function(start, len) {
      substr(native_url, start, start + len)
    }, start = m_start, len = m_length)
  
  endpoint_url <- paste(fragments[1:2], collapse = "//")
  full_path    <- fragments[4]
  segments     <- strsplit(full_path, "/") |> unlist()
  bucket       <- segments[[2]]
  path         <- segments[-1:-2] |> paste(collapse = "/")
  
  my_bucketlist <-
    aws.s3::get_bucket(
      bucket = bucket,
      region = "",
      base_url = fragments[[2]]
    )
  aws.s3::save_object(
    my_bucketlist$Contents,
    file = file.path(destination, basename(my_bucketlist$Contents$Key))
  )
}
