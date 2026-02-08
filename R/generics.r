.simplify <- function(data) {
  empty_row <- data.frame(a = NA)[,-1]
  result <-
    data |>
    lapply(tibble::enframe) |>
    lapply(
      tidyr::pivot_wider,
      names_from  = "name",
      values_from = "value") |>
    lapply(function(x) {
      if (nrow(x) == 0) {
        empty_row
      } else {
        x
      }
    }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        function (x) {
          if (all(lengths(x) == 1) && all(unlist(lapply(x, lengths)) == 1))
              unlist(x) else x
        }
      )
    )
}

## Some requests result in a 403 status response, which trigger a warning.
## Most likely this is the GDAL library trying to get directory listing
## where the server does not allow it. These warnings are harmless and
## do not affect the outcome. I will therefore muffle these warnings to
## not confuse/bother the end-user.
## Maybe this will be fixed in later GDAL releases.
.muffle_403 <- function(expr) {
  withCallingHandlers({
    expr
  }, warning = function(w) {
    if (grepl(": 403", conditionMessage(w)))
      invokeRestart("muffleWarning")
  })
}

.uri_to_vsi <- function(href, progress, add_zarr = TRUE, streaming = TRUE) {
  s3_root <- stringr::str_extract(href, "(?<=//)[^/]+")
  check <-
    Sys.setenv(AWS_S3_ENDPOINT     = s3_root) &&
    Sys.setenv(AWS_NO_SIGN_REQUEST = "YES") &&
    Sys.setenv(AWS_VIRTUAL_HOSTING = "FALSE")
  
  if (check) {
    vsi <- href |>
      stringr::str_replace("^https?://[^/]+/([^/]+)/(.*)$",
                           sprintf("/vsis3%s/\\1/\\2",
                                   ifelse(streaming, "_streaming", "")))
  } else {
    if (progress)
      cli::cli_progress_message("Failed to set GDAL S3 config, trying alternative")
    vsi <- paste0("/vsicurl/", href)
  }
  if (!add_zarr) return (vsi)
  sprintf("ZARR::\"%s\"", vsi)
}

.get_stars_proxy <- function(vsi, variable) {
  mdim_proxy <- .muffle_403({
    stars::read_mdim(
      vsi,
      proxy = TRUE,
      variable = variable
    )
  })
}