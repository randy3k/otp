<!-- README.md is generated from README.Rmd. Please edit that file -->

# One Time Password Generation and Verification

[![Github
Action](https://github.com/randy3k/otp/workflows/build/badge.svg?branch=master)](https://github.com/randy3k/otp)
[![codecov](https://codecov.io/gh/randy3k/otp/branch/master/graph/badge.svg)](https://codecov.io/gh/randy3k/otp)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/otp)](https://cran.r-project.org/package=otp)
[![](http://cranlogs.r-pkg.org/badges/grand-total/otp)](https://cran.r-project.org/package=otp)

Documentation: [http://randy3k.github.io/otp](https://randy3k.github.io/otp)

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
#> [1] "263223"
p$verify(code)
#> [1] "2020-04-25 22:00:30 PDT"
```

## Related projects

  - Ruby’s [rotp](https://github.com/mdp/rotp).
  - Python’s [pyotp](https://github.com/pyauth/pyotp).
  - [ropt](https://github.com/wrathematics/rotp), an R library for client side one time password management.
