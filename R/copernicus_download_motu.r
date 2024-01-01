#' Subset and download a specific marine product from Copernicus
#'
#' `r lifecycle::badge('deprecated')` The MOTU servers will be discontinued by Copernicus Marine Services. Use [`cms_download_subset()`]
#' instead to download subsets.
#'
#' @include cms_login.r
#' @inheritParams cms_login
#' @param destination File or path where the requested file will be downloaded to.
#' @param product An identifier (type `character`) of the desired Copernicus marine product.
#' Can be obtained with [`copernicus_products_list`].
#' @param layer The name of a desired layer within a product (type `character`). Can be obtained with [`copernicus_product_details`].
#' @param variable The name of a desired variable in a specific layer of a product (type `character`).
#' Can be obtained with [`copernicus_product_details`].
#' @param output File type for the output. `"netcdf"` will work in most cases.
#' @param region Specification of the bounding box as a `vector` of `numeric`s WGS84 lat and lon coordinates.
#' Should be in the order of: xmin, ymin, xmax, ymax.
#' @param timerange `r lifecycle::badge('experimental')` A `vector` with two elements (lower and upper value)
#' for a requested time range. The `vector` should be coercible to `POSIXct`.
#' @param verticalrange `r lifecycle::badge('experimental')` A `vector` with two elements (minimum and maximum)
#' numerical values for the depth of the vertical layers (if any).
#' @param sub_variables A `vector` of names of requested sub variables.
#' @param overwrite A `logical` value. When `FALSE` (default), files at the `destination` won't be
#' overwritten when the exist. Instead an error will be thrown if this is the case. When set to
#' `TRUE`, existing files will be overwritten.
#' @returns Returns a `logical` value invisibly indicating whether the requested file was
#' successfully stored at the `destination`.
#' @rdname copernicus_download_motu
#' @name copernicus_download_motu
#' @examples
#' \dontrun{
#' destination <- tempfile("copernicus", fileext = ".nc")
#'
#' ## Assuming that Copernicus account details are provided as `options`
#' copernicus_download_motu(
#'   destination   = destination,
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'   variable      = "sea_water_velocity",
#'   output        = "netcdf",
#'   region        = c(-1, 50, 10, 55),
#'   timerange     = c("2021-01-01", "2021-01-02"),
#'   verticalrange = c(0, 2),
#'   sub_variables = c("uo", "vo")
#' )
#' 
#' mydata <- stars::read_stars(destination)
#' 
#' plot(mydata["vo"])
#' }
#' @author Pepijn de Vries
#' @export
copernicus_download_motu <- function(
    username = getOption("CopernicusMarine_uid", ""),
    password = getOption("CopernicusMarine_pwd", ""),
    destination, product, layer, variable, output, region, timerange, verticalrange, sub_variables, overwrite = FALSE) {
  .Deprecated("cms_download_subset")
  
  login <- copernicus_login(username, password)
  login_result <- attr(login, "response")
  cookies      <- attr(login, "cookies")

  if (!login) stop("Failed to log in. Are you sure you have provided valid credentials?")

  message(crayon::white("Preparing download..."))
 
  product_services <- copernicus_product_services(product) |> dplyr::filter(layer == {{layer}})

  if (nrow(product_services) == 0)
    stop("No services available, please check if you specified the 'product' and 'layer' name correctly, and whether the layer has a MOTU service.")

  if (!"motu" %in% names(product_services) || is.na(product_services$motu))
    return(invisible(FALSE))
  
  product_services <- product_services |> dplyr::pull("motu")
  
  if (missing(timerange)) timerange <- NULL else timerange <- format(as.POSIXct(timerange), "%Y-%m-%d+%H%%3A%M%%3A%S")
  prepare_url <-
    c(
      stringr::str_replace(product_services, "action.*?&", "action=productdownload&"),
      if (missing(output))        NULL else sprintf("output=%s", output),
      if (missing(region))        NULL else sprintf("x_lo=%s&y_lo=%s&x_hi=%s&y_hi=%s",
                                                    region[1], region[2], region[3], region[4]),
      if (is.null(timerange))     NULL else sprintf("t_lo=%s&t_hi=%s", timerange[1], timerange[2]),
      if (missing(verticalrange)) NULL else sprintf("z_lo=%s&z_hi=%s", verticalrange[1], verticalrange[2]),
      if (missing(sub_variables)) NULL else paste0(sprintf("variable=%s", sub_variables), collapse = "&")
    ) |>
    paste0(collapse = "&")

  result <-
    .try_online({
      prepare_url |>
        httr2::request() |>
        httr2::req_cookie_preserve(cookies) |> ## Preserve cookies obtained earlier with account details
        httr2::req_perform()
        }, "Copernicus")
  if (is.null(result)) return(invisible(FALSE))
  
  if (result$headers$`content-type` |> startsWith("text/html")) {
    errors <-
      result |>
      httr2::resp_body_html() |>
      rvest::html_element(xpath = "//p[@class='error']") |>
      rvest::html_text()
    if (!is.na(errors)) {
      message(errors)
      return(invisible(FALSE))
    }
    message(crayon::white("Downloading file..."))
    
    download_url <-
      result |>
      httr2::resp_body_html() |>
      rvest::html_element(xpath = "//form[@name='dlform']") |>
      rvest::html_attr("action")
    if (dir.exists(destination))
      destination <- file.path(destination, basename(download_url))
    if (!overwrite & file.exists(destination))
      stop("Destination file already exists. Set 'overwrite' to TRUE to proceed.")
    download_result <- .try_online({
      download_url |>
        httr2::request() |>
        httr2::req_cookie_preserve(cookies) |>
        httr2::req_perform(destination)
      }, "Copernicus")
    
    if (is.null(download_result)) return(invisible(FALSE))
    message(crayon::green("Done"))
    return(invisible(TRUE))
    
  } else {
    stop("Retrieved unexpected content...")
  }
}
