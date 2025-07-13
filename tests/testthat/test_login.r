test_that("Login works", {
  skip_on_cran()
  has_account_details()
  expect_true({
    login <- cms_login()
    login$preferred_username == cms_get_username()
  })
})