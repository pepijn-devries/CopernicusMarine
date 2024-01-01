#' @rdname cms_stac
#' @name cms_list_stac_files
#' @export
cms_list_stac_files <- function(product, layer) {
  props <- cms_stac_properties(product, layer)
  if (length(props) == 0) return(NULL)
  assets <- NULL
  props <- dplyr::tibble(assets = props$href) |>
    dplyr::mutate(
      current_path = stringr::str_extract(.data$assets, "/native/.*?$"),
      current_path = gsub("^/", "", .data$current_path),
      split  = strsplit(assets, "/"),
      home   = purrr::map_chr(split, ~{.x[[3]]}),
      native = purrr::map_chr(split, ~{.x[grepl("-native-", .x)]})
    ) |>
    dplyr::select(!dplyr::any_of(c("split", "assets")))

  .list_stac <- function(base_props) {
    prep_url <-
      "https://%s.%s/?delimiter=%%2F&list-type=2&prefix=" |>
      sprintf(base_props$native, base_props$home) |>
      paste0(utils::URLencode(base_props$current_path))
    bucket <-
      purrr::map(
        prep_url, ~{
          result <-
            .try_online({
              .x |>
                httr2::request() |>
                httr2::req_perform()
            }, "list-bucket")
          if (is.null(result)) return(NULL)
          if (is.null(result$headers$`content-type`) || is.na(result$headers$`content-type`))
            result$headers$`content-type` <- "application/xml"
          result <- result |>
            httr2::resp_body_xml() |>
            xml2::as_list()
          result <- result$ListBucketResult
          c_prefix <-
            dplyr::tibble(
              Key = result[names(result) == "CommonPrefixes"] |>
                unlist() |>
                unname()
            )
          content <- result[names(result) == "Contents"] |>
            purrr::map(dplyr::as_tibble) |>
            dplyr::bind_rows() |>
            dplyr::mutate(dplyr::across(dplyr::everything(), unlist))
          result <- dplyr::bind_rows(c_prefix, content)
          result
        })
    bucket <- purrr::imap(
      bucket, ~{
        is_file <- if(!"Size" %in% names(.x)) rep(FALSE, nrow(.x)) else !is.na(.x$Size)
        new_props <- if (any(is_file)) {
          np <-
            base_props[.y,, drop = FALSE] |>
              dplyr::bind_cols(.x[is_file,,drop = FALSE]) |>
              dplyr::select(!dplyr::any_of("current_path"))
          if ("Key" %in% names(np)) np <- np |> dplyr::rename(!!"current_path" := "Key")
          np
        } else {
          NULL
        }
        if (!any(is_file)) {
          new_props <-
            dplyr::bind_rows(
              new_props,
              if (nrow(.x) == 0) NULL else {
                base_props[rep(.y, length(.x$Key)),, drop = FALSE] |>
                  dplyr::mutate(!!"current_path" := .x$Key) |>
                  .list_stac() # call recursively
              }
            )
        }
        return(new_props)
      }
    )
    return(bucket)
  }
  bucket <- .list_stac(props) |> dplyr::bind_rows()
  return(bucket)
}
