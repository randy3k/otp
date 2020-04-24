#' @export
OTP <- R6::R6Class(
    "OTP",
    private = list(
        secret = NULL,
        digits = NULL,
        period = NULL,
        type = NULL,
        generate = function(count) {
            h <- openssl::sha1(int_to_bytes(count), private$secret)
            sprintf(paste0("%0", private$digits, "d"), dymtrunc(h) %% 10L^private$digits)
        }
    ),
    public = list(
        initialize = function(secret, digits = 6L, period = 30L, base32 = TRUE) {
            if (grepl("^otpauth://", secret)) {
                base32 <- TRUE
                m <- re_match("secret=([^&$]+)", secret)[[1]]
                secret <- m[2]
                if (grepl("^otpauth://hotp", secret)) {
                    private$type <- "hotp"
                } else if (grepl("^otpauth://totp", secret)) {
                    private$type <- "totp"
                }
            }
            if (isTRUE(base32)) {
                secret <- base64url::base32_decode(secret)
            }
            private$secret <- secret
            private$digits <- digits
            private$period <- period
        }
    )
)


#' @export
HOTP <- R6::R6Class(
    "HOTP",
    inherit = OTP,
    public = list(
        at = function(count) {
            private$generate(count)
        }
    )
)


#' @export
TOTP <- R6::R6Class(
    "TOTP",
    inherit = OTP,
    public = list(
        at_time = function(t) {
            count <- as.double(as.POSIXct(t)) %/% private$period
            private$generate(count)
        },
        now = function() {
            self$at_time(Sys.time())
        }
    )
)
