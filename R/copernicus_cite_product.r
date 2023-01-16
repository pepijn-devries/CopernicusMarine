#' How to cite a Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Get details for properly citing a Copernicus product.
#'
#' @inheritParams copernicus_download_motu
#' @return Returns a list of character strings. The first element is always the product title, id and doi.
#' Remaining elements are other associated references. Note that the remaining references are returned as
#' listed at Copernicus. Note that the citing formatting does not appear to be standardised.
#' @rdname copernicus_cite_product
#' @name copernicus_cite_product
#' @family product-functions
#' @examples
#' \dontrun{
#' copernicus_cite_product("SST_MED_PHY_SUBSKIN_L4_NRT_010_036")
#' }
#' @author Pepijn de Vries
#' @export
copernicus_cite_product <- function(product) {
  product_details <- copernicus_product_details(product)
  result <- product_details$refs
  result <- c(doi = with(product_details, sprintf("E.U. Copernicus Marine Service Information; %s - %s (%s). DOI:%s",
                                                  title, id, creationDate, doi)), result)
  return(result)
}
