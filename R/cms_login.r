#' Contact Copernicus Marine login page
#' 
#' `r lifecycle::badge('stable')` Contact Copernicus Marine login page
#' and check if login is successful.
#' 
#' This function will return a logical value indicating if the login is successful.
#' It can be used to test your account details.
#' @param username Your Copernicus marine user name. Can be provided as
#' `options(CopernicusMarine_uid = "my_user_name")`, or as argument here.
#' @param password Your Copernicus marine password. Can be provided as
#' `options(CopernicusMarine_pwd = "my_password")`, or as argument here.
#' @returns Returns a `logical` value indicating if the login is successful.
#' The response from the login page is returned as an attribute named `response`.
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

  cookies <- tempfile("cookies", fileext = ".txt")
  
  resp <- .try_online({
    "https://data-be-prd.marine.copernicus.eu/api/logIn" |>
      httr2::request() |>
      httr2::req_cookie_preserve(cookies) |>
      httr2::req_auth_basic(username = username, password = password) |>
      httr2::req_perform()
  }, "login-form")
  if (is.null(resp)) return(NULL)
  
  result <- resp |>
    httr2::resp_body_json()
  
  result <- !identical(result, structure(list(), names = character()))
  
  attr(result, "response") <- resp
  attr(result, "cookies")  <- cookies
  return(result)
}