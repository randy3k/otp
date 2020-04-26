<!-- README.md is generated from README.Rmd. Please edit that file -->

# One Time Password Generation and Verificaiton

<!-- badges: start -->

[![CRAN status](https://www.r-pkg.org/badges/version/otp)](https://CRAN.R-project.org/package=otp)
<!-- badges: end -->

Generating and validating HMAC-based One-time Password (HOTP)
and Time Based One-time Password (TOTP) according to RFC 4226 and RFC 6238.

## Installation

You can install the released version of otp from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("otp")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("randy3k/otp")
```

## Example

``` r
library(otp)
```

### HMAC based One Time Password (HOTP)

``` r
p <- HOTP$new("JBSWY3DPEHPK3PXP")
p$at(8)
#> [1] "964230"
p$verify("964230", 8)
#> [1] 8
```

### Time based One Time Password (TOTP)

``` r
p <- TOTP$new("JBSWY3DPEHPK3PXP")
(code <- p$now())
#> [1] "904156"
p$verify(code)
#> [1] "2020-04-25 21:46:00 PDT"
```

## Related projects

  - Ruby’s [rotp](https://github.com/mdp/rotp).
  - Python’s [pyotp](https://github.com/pyauth/pyotp).
  - [ropt](https://github.com/wrathematics/rotp), an R library for client side one time password management.
