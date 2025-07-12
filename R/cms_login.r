#' Contact Copernicus Marine login page
#' 
#' `r lifecycle::badge('stable')` Contact Copernicus Marine login page
#' and check if login is successful.
#' 
#' This function will return your account details if successful.
#' @param username Your Copernicus marine user name. Can be provided as
#' `options(CopernicusMarine_uid = "my_user_name")`, or as argument here.
#' @param password Your Copernicus marine password. Can be provided as
#' `options(CopernicusMarine_pwd = "my_password")`, or as argument here.
#' @returns Returns a named `list` with your account details if successful,
#' returns `NULL` otherwise.
#' @author Pepijn de Vries
#' @examples
#' \dontrun{
#' ## This will return FALSE if you have not set your account details with 'options'.
#' ## If you have specified your account details and there are no other problems,
#' ## it will return TRUE.
#' cms_login()
#' }
#' @name cms_login
#' @rdname cms_login
#' @export
cms_login <- function(
    username = getOption("CopernicusMarine_uid", ""),
    password = getOption("CopernicusMarine_pwd", "")) {

  token <- .get_access_token(username, password)
  if (is.null(token)) return(NULL)
  
  details <- .try_online({
    account_details <-
      "https://auth.marine.copernicus.eu/realms/MIS/protocol/openid-connect/userinfo" |>
      httr2::request() |>
      httr2::req_method("POST") |>
      httr2::req_headers(authorization = paste0("Bearer ", token$access_token)) |>
      httr2::req_perform()
  }, "login-page")
  
  if (is.null(details)) return(NULL) else
    return(httr2::resp_body_json(details))
}

.get_access_token <- function(
    username = getOption("CopernicusMarine_uid", ""),
    password = getOption("CopernicusMarine_pwd", "")) {
  token_request <-
    .try_online({
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
        httr2::req_perform()
    }, "login-page")
  if (is.null(token_request))
    return (NULL) else return(httr2::resp_body_json(token_request))
}