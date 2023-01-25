.http_status_ok <- function(x) {
  if (dplyr::between(x$status_code, 100, 199)) {
    message(sprintf("Unexpected informational response from Copernicus (status %i).", x$status_code))
    return(FALSE)
  }
  if (dplyr::between(x$status_code, 300, 399)) {
    message(sprintf("Unexpected redirection from Copernicus (status %i).", x$status_code))
    return(FALSE)
  }
  if (dplyr::between(x$status_code, 400, 499)) {
    message(sprintf(paste("Copernicus reported a client error (status %i).",
                          "You may have requested information that is not available,",
                          "please check your input.",
                          sep = "\n"), x$status_code))
    return(FALSE)
  }
  if (dplyr::between(x$status_code, 500, 599)) {
    message(sprintf("Copernicus reported a server error (status %i).\nPlease try again later.", x$status_code))
    return(FALSE)
  }
  if (x$status_code < 100 || x$status_code >= 600) {
    message(sprintf("Copernicus responded with unknown status (status %i).", x$status_code))
    return(FALSE)
  }
  return(TRUE)
}

.try_online <- function(expr, resource) {
  result <- tryCatch(expr, error = function(e) {
    message(sprintf("Failed to collect information from %s.\n%s", resource, e$message))
    return(NULL)
    })
  if (is.null(result)) return(NULL)
  if (!.http_status_ok(result)) return(NULL)
  return(result)
}