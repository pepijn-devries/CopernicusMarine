#' Get Copernicus Marine Terminology Glossary
#' 
#' Function that returns a `data.frame` with a glossary of terminology
#' used by the Copernicus Marine Data Service. It is the same `data.frame`
#' that is used to render `vignette("glossary")`.
#' @param search Search terms to look for in the glossary `data.frame`.
#' Only rows that match these terms are returned. If missing, the
#' entire `data.frame` is returned.
#' @param match_fun Function used to filter the `data.frame`. It needs to
#' be a function that uses a `pattern` argument to match the text in the
#' `data.frame` against. It should return a vector of `logical` values
#' or a vector of `integer` row index values. By default it uses [agrepl()],
#' for a fuzzy match.
#' @param ... Arguments passed to `match_fun`.
#' @returns Returns a `data.frame` with glossary info.
#' @examples
#' cms_glossary("variable", ignore.case = TRUE)
#' @export
cms_glossary <- function(search, match_fun = agrep, ...) {
  glossary <- NULL
  load(system.file("glossary.rdata", package = "CopernicusMarine"))
  result <- if (missing(search)) glossary else {
    indices <-
      lapply(glossary, match_fun, pattern = search, ...) |>
      lapply(\(x) {
        if (is.logical(x)) which(x) else x
      }) |>
      unlist() |>
      unique()
    glossary[indices,]
  }
  return(result)
}