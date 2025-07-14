#' Subset and download a specific marine product from Copernicus
#'
#' `r lifecycle::badge('questioning')` Subset and download a specific marine product from Copernicus.
#' You need to register an account
#' at <https://data.marine.copernicus.eu> before you can use this function.
#'
#' @include cms_login.r
#' @inheritParams cms_login
#' @param destination File or path where the requested file will be downloaded to.
#' @param product An identifier (type `character`) of the desired Copernicus marine product.
#' Can be obtained with [`cms_products_list`].
#' @param layer The name of a desired layer within a product (type `character`). Can be obtained with [`cms_product_details`].
#' @param variable The name of a desired variable in a specific layer of a product (type `character`).
#' Can be obtained with [`cms_product_details`].
#' @param region Specification of the bounding box as a `vector` of `numeric`s WGS84 lat and lon coordinates.
#' Should be in the order of: xmin, ymin, xmax, ymax.
#' @param timerange A `vector` with two elements (lower and upper value)
#' for a requested time range. The `vector` should be coercible to `POSIXct`.
#' @param verticalrange A `vector` with two elements (minimum and maximum)
#' numerical values for the depth of the vertical layers (if any). Note that values below the
#' sea surface needs to be specified as negative values.
#' @param overwrite A `logical` value. When `FALSE` (default), files at the `destination` won't be
#' overwritten when the exist. Instead an error will be thrown if this is the case. When set to
#' `TRUE`, existing files will be overwritten.
#' @returns Returns a `logical` value invisibly indicating whether the requested file was
#' successfully stored at the `destination`.
#' @rdname cms_download_subset
#' @name cms_download_subset
#' @examples
#' \dontrun{
#' destination <- tempfile("copernicus", fileext = ".nc")
#'
#' ## Assuming that Copernicus account details are provided as `options`
#' cms_download_subset(
#'   destination   = destination,
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'   variable      = "sea_water_velocity",
#'   region        = c(-1, 50, 10, 55),
#'   timerange     = c("2021-01-01 UTC", "2021-01-02 UTC"),
#'   verticalrange = c(0, -2)
#' )
#' 
#' mydata <- stars::read_stars(destination)
#' 
#' plot(mydata["vo"])
#' }
#' @author Pepijn de Vries
#' @export
cms_download_subset <- function(
    username = cms_get_username(),
    password = cms_get_password(),
    destination,
    product,
    layer,
    variable,
    region,
    timerange,
    verticalrange,
    overwrite = FALSE) {

  message(paste("Subsetting is currently not possible with this package.",
                "Please check https://github.com/pepijn-devries/CopernicusMarine for the latest news", sep = "\n"))
  return(invisible(TRUE))
}