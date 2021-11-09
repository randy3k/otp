
<!-- README.md is generated from README.Rmd. Please edit that file -->

# One Time Password Generation and Verification

[![check](https://github.com/randy3k/otp/actions/workflows/check.yaml/badge.svg)](https://github.com/randy3k/otp/actions/workflows/check.yaml)
[![codecov](https://codecov.io/gh/randy3k/otp/branch/master/graph/badge.svg)](https://codecov.io/gh/randy3k/otp)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/otp)](https://cran.r-project.org/package=otp)
[![](http://cranlogs.r-pkg.org/badges/grand-total/otp)](https://cran.r-project.org/package=otp)

Github: <https://github.com/randy3k/otp>

Documentation: <https://randy3k.github.io/otp>

Generating and validating One-time Password based on Hash-based Message
Authentication Code (HOTP) and Time Based One-time Password (TOTP)
according to RFC 4226 <https://tools.ietf.org/html/rfc4226> and RFC 6238
<https://tools.ietf.org/html/rfc6238>.

## Installation

You can install the released version of otp from
[CRAN](https://CRAN.R-project.org) with:

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
```

    ## [1] "964230"

``` r
p$verify("964230", 8)
```

    ## [1] 8

### Time based One Time Password (TOTP)

``` r
p <- TOTP$new("JBSWY3DPEHPK3PXP")
(code <- p$now())
```

    ## [1] "529411"

``` r
p$verify(code)
```

    ## [1] "2021-11-08 21:19:30 PST"

``` r
raster::image(
  qrencoder::qrencode_raster(p$provisioning_uri("otp")),
  asp = 1, col = c("white", "black"), axes = FALSE,
  xlab = "", ylab = ""
)
```

<img src="https://i.imgur.com/TYAO8df.png" width="20%" />

## Related projects

-   Ruby’s [rotp](https://github.com/mdp/rotp).
-   Python’s [pyotp](https://github.com/pyauth/pyotp).
-   [ropt](https://github.com/wrathematics/rotp), an R library for
    client side one time password management.
