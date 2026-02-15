test_that("Login works", {
  skip_on_cran()
  skip_if_offline()
  has_account_details()
  expect_true({
    login <- cms_login()
    login$preferred_username == cms_get_username()
  })
})

test_that("Warn when trying to log in with invalid credentials", {
  skip_on_cran()
  skip_if_offline()
  expect_warning({
    CopernicusMarine:::.try_login("", "")
  }, "Failed to log in")
})

test_that("Error when logging in with invalid credentials", {
  skip_on_cran()
  skip_if_offline()
  expect_error({
    cms_login("", "")
  }, "Failed to log in")
})

test_that("Setting username works", {
  skip_on_cran()
  expect_true({
    curuid <- cms_get_username()
    on.exit({
      cms_set_username(curuid, "sysenv")
      cms_set_username(curuid, "option")
    }, add = TRUE, after = FALSE)
    cms_set_username("henk", "option")
    cms_set_username("henk", "sysenv")
    cms_get_username() == "henk"
  })
})

test_that("Setting password works", {
  skip_on_cran()
  expect_true({
    curpwd <- cms_get_password()
    on.exit({
      cms_set_password(curpwd, "sysenv")
      cms_set_password(curpwd, "option")
    }, add = TRUE, after = FALSE)
    cms_set_password("foobar", "option")
    cms_set_password("foobar", "sysenv")
    cms_get_password() == "foobar"
  })
})

test_that("Using dummy account details throws error", {
  skip_on_cran()
  expect_error({
    curuid <- cms_get_username()
    curpwd <- cms_get_password()
    on.exit({
      cms_set_username(curuid, "sysenv")
      cms_set_username(curuid, "option")
      cms_set_password(curpwd, "sysenv")
      cms_set_password(curpwd, "option")
    }, add = TRUE, after = FALSE)
    cms_set_username("henk", "option")
    cms_set_username("henk", "sysenv")
    cms_set_password("foobar", "option")
    cms_set_password("foobar", "sysenv")
    cms_login() |> suppressMessages()
  }, "401 Unauthorized")
})
