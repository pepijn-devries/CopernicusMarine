#' @export
cms_get_client_info <- function() {
  ci <- .try_online({
    "https://stac.marine.copernicus.eu/clients-config-v1" |>
      httr2::request() |>
      httr2::req_perform()
  }, "client-info-page")
  if (is.null(ci)) return(NULL) else return(httr2::resp_body_json(ci))
}
#TODO
temp <- function() {
  products <-
    "https://s3.waw4-1.cloudferro.com/mdl-metadata-dta/dataset_product_id_mapping.json" |>
    httr2::request() |>
    httr2::req_perform()
  products |>
    httr2::resp_body_json()
}
## Python definitions TODO this is just not for my own reference. Remove later
# root_metadata_url := catalogue["stacRoot"]
# dataset_product_mapping_url=catalogue["idMapping"]
# stac_catalogue_url=catalogue["stac"]
# catalogue in mds_config["catalogues"]
# 
# url = f"{stac_url}/{product_id}/product.stac.json"
# product_json = connection.get_json_file(url)
# product_collection = pystac.Collection.from_dict(
#   product_json
# )
# "describe": ["mds", "mds/serverlessArco/meta"],
# "get":      ["mds", "mds/serverlessNative", "mds/serverlessArco/meta"],
# "subset":   ["mds", "mds/serverlessArco", "mds/serverlessArco/meta"],