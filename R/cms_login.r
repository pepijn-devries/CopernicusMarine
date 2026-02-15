#' Contact Copernicus Marine login page
#' 
#' `r lifecycle::badge('stable')` Contact Copernicus Marine login page
#' and check if login is successful.
#' 
#' This function will return your account details if successful.
#' @param username Your Copernicus marine user name. Can be provided with
#' `cms_get_username()` (default), or as argument here.
#' @param password Your Copernicus marine password. Can be provided as
#' `cms_get_password()` (default), or as argument here.
#' @returns Returns a named `list` with your account details if successful,
#' returns `NULL` otherwise.
#' @author Pepijn de Vries
#' @examples
#' if (interactive()) {
#'   cms_login()
#' }
#' @name cms_login
#' @rdname cms_login
#' @export
cms_login <- function(
    username = cms_get_username(),
    password = cms_get_password()) {

  if (password == "" || username == "") rlang::abort(c(
    x = "Failed to log in",
    i = "Check your credentials"
  ))
  token <- .get_access_token(username, password)

  "https://auth.marine.copernicus.eu/realms/MIS/protocol/openid-connect/userinfo" |>
    httr2::request() |>
    httr2::req_method("POST") |>
    httr2::req_headers(authorization = paste0("Bearer ", token$access_token)) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

.get_access_token <- function(
    username = cms_get_username(),
    password = cms_get_password()) {
  "https://auth.marine.copernicus.eu/realms/MIS/protocol/openid-connect/token" |>
    httr2::request() |>
    httr2::req_method("POST") |>
    httr2::req_body_form(
      client_id  = "toolbox",
      grant_type = "password",
      username   = username,
      password   = password,
      scope      = "openid profile email"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

.try_login <- function(username, password) {
  success <- tryCatch({
    cms_login(username, password)
    TRUE
  }, error = function(e) FALSE)
  if (!success) rlang::warn(c(
    "Failed to log in",
    i = "Trying to proceed without credentials"
  ))
  invisible()
}

#' Set or get Copernicus account details
#' 
#' `r lifecycle::badge('stable')` Set or get username and password throughout an R session.
#' This can be used to obscure your account details in an R script and
#' store them as either an R option or system environment variable.
#' @param username Your Copernicus Marine username
#' @param password Your Copernicus Marine password
#' @param method Either `"option"` to use R options to store account details.
#' Use `"sysenv"` to store account details as system environment variable.
#' @returns Returns your account details for the `get` variant or nothing in case
#' of the `set` variant.
#' @examples
#' if (interactive()) {
#'   ## Returns your account details only if they have been set for your session
#'   cms_get_username()
#'   cms_get_password()
#' }
#' @author Pepijn de Vries
#' @rdname account
#' @export
cms_get_username <- function() {
  username <- Sys.getenv("COPERNICUSMARINE_SERVICE_USERNAME")
  if (username == "") username <- getOption("CopernicusMarine_uid", "")
  return (username)
}

#' @rdname account
#' @export
cms_get_password <- function() {
  password <- Sys.getenv("COPERNICUSMARINE_SERVICE_PASSWORD")
  if (password == "") password <- getOption("CopernicusMarine_pwd", "")
  return (password)
}

#' @rdname account
#' @export
cms_set_username <- function(username, method = c("option", "sysenv")) {
  method <- match.arg(method)
  switch(
    method,
    option = {
      options(CopernicusMarine_uid = username)
    },
    sysenv = {
      Sys.setenv(COPERNICUSMARINE_SERVICE_USERNAME = username)
    })
  return(invisible())
}

#' @rdname account
#' @export
cms_set_password <- function(password, method = c("option", "sysenv")) {
  method <- match.arg(method)
  switch(
    method,
    option = {
      options(CopernicusMarine_pwd = password)
    },
    sysenv = {
      Sys.setenv(COPERNICUSMARINE_SERVICE_PASSWORD = password)
    })
  return(invisible())
}
