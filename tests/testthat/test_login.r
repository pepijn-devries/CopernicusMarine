test_that("Login works", {
  skip_on_cran()
  skip_if_not(has_account_details())
  expect_true({
    login <- cms_login()
    login$preferred_username == cms_get_username()
  })
})

test_that("Setting username works", {
  skip_on_cran()
  expect_true({
    cms_set_username("henk", "option")
    cms_set_username("henk", "sysenv")
    cms_get_username() == "henk"
  })
})

test_that("Setting password works", {
  skip_on_cran()
  expect_true({
    cms_set_password("foobar", "option")
    cms_set_password("foobar", "sysenv")
    cms_get_password() == "foobar"
  })
})

test_that("Using dummy account details throws error", {
  skip_on_cran()
  expect_error({
    cms_set_username("henk", "option")
    cms_set_username("henk", "sysenv")
    cms_set_password("foobar", "option")
    cms_set_password("foobar", "sysenv")
    cms_login() |> suppressMessages()
  }, "401 Unauthorized")
})
