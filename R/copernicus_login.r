#' Contact Copernicus Marine login page
#' 
#' `r lifecycle::badge('deprecated')` This login method is only used by the
#' download methods that are deprecated by Copernicus Marine Services. Use
#' [`cms_login()`] instead.
#' 
#' @include cms_login.r
#' @inheritParams cms_login
#' @returns Returns a `logical` value indicating if the login is successful.
#' The response from the login page is returned as an attribute named `response`.
#' @author Pepijn de Vries
#' @examples
#' \dontrun{
#' ## This will return FALSE if you have not set your account details with 'options'.
#' ## If you have specified your account details and there are no other problems,
#' ## it will return TRUE.
#' copernicus_login()
#' }
#' @name copernicus_login
#' @rdname copernicus_login
#' @export
copernicus_login <- function(
    username = getOption("CopernicusMarine_uid", ""),
    password = getOption("CopernicusMarine_pwd", "")) {
  
  cookies <- tempfile("cookies", fileext = ".txt")

  login_form <-
    .try_online({
      "https://cmems-cas.cls.fr/cas/login" |>
        httr2::request() |>
        httr2::req_cookie_preserve(cookies) |>
        httr2::req_perform()
    }, "log-in page")
  if (is.null(login_form)) return(invisible(FALSE))
  
  ## Check if you are already logged in:
  success <-
    login_form |>
    httr2::resp_body_html() |>
    rvest::html_element(xpath = "//div[@id='msg']") |> rvest::html_attr("class")

  if (!is.na(success) && success == "success") {
    message(crayon::white("Already logged in"))
    login_result <- login_form
  } else {
    lt <-
      login_form |>
      httr2::resp_body_html() |>
      rvest::html_element(xpath = "//input[@name='lt']") |>
      rvest::html_attr("value")
    
    # Now submit login form with account details and obtain cookies required to continue
    message(crayon::white("Logging in onto MOTU server..."))

    login_result <-
      .try_online({
        sprintf("https://cmems-cas.cls.fr/cas/login?username=%s&password=%s&lt=%s&execution=e1s1&_eventId=submit",
                utils::URLencode(username), utils::URLencode(password), lt) |>
          httr2::request() |>
          httr2::req_cookie_preserve(cookies) |>
          httr2::req_perform()
      }, "log-in page")
    if (is.null(login_result)) return(invisible(FALSE))
    
    success <-
      login_result |> httr2::resp_body_html() |>
      rvest::html_element(xpath = "//div[@id='msg']") |> rvest::html_attr("class")
  }
  success <- !(is.na(success) || success != "success")
  attr(success, "response") <- login_result
  attr(success, "cookies")  <- cookies
  return(success)
}