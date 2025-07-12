#' How to cite a Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Get details for properly citing a Copernicus product.
#'
#' @inheritParams cms_download_subset
#' @returns Returns a vector of character strings. The first element is always the product title, id and doi.
#' Remaining elements are other associated references. Note that the remaining references are returned as
#' listed at Copernicus. Note that the citing formatting does not appear to be standardised.
#' @rdname cms_cite_product
#' @name cms_cite_product
#' @family product-functions
#' @examples
#' cms_cite_product("SST_MED_PHY_SUBSKIN_L4_NRT_010_036")
#' @author Pepijn de Vries
#' @export
cms_cite_product <- function(product) {
  product_details <- cms_product_details(product)
  if (is.null(product_details)) return(NULL)
  result <- c(
    doi = with(
      product_details,
      sprintf("E.U. Copernicus Marine Service Information; %s - %s (%s). DOI:%s",
              title, id, properties$creationDate, `sci:doi`)), product_details)
  return(result)
}