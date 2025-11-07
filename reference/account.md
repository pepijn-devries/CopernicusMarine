# Set or get Copernicus account details

Set or get username and password throughout an R session. This can be
used to obscure your account details in an R script and store them as
either an R option or system environment variable.

## Usage

``` r
cms_get_username()

cms_get_password()

cms_set_username(username, method = c("option", "sysenv"))

cms_set_password(password, method = c("option", "sysenv"))
```

## Arguments

- username:

  Your Copernicus Marine username

- method:

  Either `"option"` to use R options to store account details. Use
  `"sysenv"` to store account details as system environment variable.

- password:

  Your Copernicus Marine password

## Value

Returns your account details for the `get` variant or nothing in case of
the `set` variant.

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  ## Returns your account details only if they have been set for your session
  cms_get_username()
  cms_get_password()
}
```
