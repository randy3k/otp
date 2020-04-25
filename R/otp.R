#' @docType package
#' @importFrom base64url base32_decode base32_encode
#' @aliases NULL
"_PACKAGE"


OTP <- R6::R6Class(
    "OTP",
    private = list(
        secret = NULL,
        digits = NULL,
        algorithm = NULL,
        generate = function(value) {
            algorithm <- private$algorithm
            if (algorithm == "sha1") {
                sha <- openssl::sha1
            } else if (algorithm == "sha256") {
                sha <- openssl::sha256
            } else if (algorithm == "sha512") {
                sha <- openssl::sha512
            } else {
                stop("unknown algorithm")
            }
            h <- sha(int_to_bytes(value), private$secret)
            sprintf(paste0("%0", private$digits, "d"), dymtrunc(h) %% 10L^private$digits)
        }
    ),
    public = list(
        initialize = function(
                secret,
                digits = 6L,
                algorithm = "sha1") {
            secret <- base32_decode(secret)
            private$secret <- secret
            private$digits <- digits
            private$algorithm <- algorithm
        },
        provisioning_uri = function(type, name, ...) {
            args <- list(...)
            args <- Filter(Negate(is.null), args)

            scheme <- "otpauth"

            stopifnot(!missing(name) && !is.null(name))

            issuer <- args$issuer
            if (is.null(issuer)) {
                label <- name
            } else {
                label <- paste0(issuer, ":", name)
            }

            if (private$digits != 6L) {
                args$digits <- private$digits
            }

            if (private$algorithm != "sha1") {
                args$algorithm <- private$algorithm
            }

            query_string <- paste(
                sapply(
                    names(args),
                    function(a) paste0(a, "=", URLencode(as.character(args[[a]])))),
                collapse = "&")

            if (nzchar(query_string)) {
                query_string <- paste0("&", query_string)
            }

            paste0(scheme, "://", type, "/", URLencode(label), "?secret=",
                base32_encode(private$secret),
                query_string)
        },
        print = function() {
            cat(class(self)[1], "object")
            cat("\n")
        }
    )
)


#' HMAC based One Time Password (HOTP)
#'
#' An R6 class that implements the HMAC based One Time Password (HOTP) algorithm.
#'
#' @details
#' # Initialization
#'
#' \preformatted{
#' HOTP$new(secret, digits = 6L, algorithm = "sha1")
#' }
#' Create an One Time Password object
#' - **secret** a scalar character, the base32-based secret key
#' - **digits** an integer, the number of digits of the password
#' - **algorithm** the hash algorithm used, possible values are
#'   "sha1", "sha256" and "sha512".
#'
#' # Methods
#'
#' \preformatted{
#' HOTP$at(counter)
#' }
#' Generate an one time password at counter value
#' - **counter** a non-negative integer
#'
#'
#' @examples
#' p <- HOTP$new("")
#' @seealso https://tools.ietf.org/html/rfc4226
#' @export
HOTP <- R6::R6Class(
    "HOTP",
    inherit = OTP,
    private = list(
        counter = NULL
    ),
    public = list(
        at = function(counter) {
            private$generate(counter)
        },
        verify = function(code, counter, window = 0L) {
            g <- private$generate
            for (i in seq_len(window + 1L)) {
                if (identical(g(counter + i - 1L), code)) {
                    return(counter + i - 1L)
                }
            }
            NULL
        },
        provisioning_uri = function(name, issuer = NULL, counter = 0L) {
            if (missing(counter)) {
                message("provisioning uri with 0 counter")
            }
            super$provisioning_uri(
                type = "hotp",
                name = name,
                issuer = issuer,
                counter = counter
            )
        }
    )
)

#' Time based One Time Password (TOTP)
#'
#' An R6 class that implements the Time based One Time Password (TOTP) algorithm.
#'
#' @export
TOTP <- R6::R6Class(
    "TOTP",
    inherit = OTP,
    private = list(
        period = NULL,
        time_step = function(t) {
            as.double(as.POSIXct(t)) %/% private$period
        }
    ),
    public = list(
        initialize = function(secret, ..., period = 30) {
            private$period <- period
            super$initialize(secret, ...)
        },
        at_time = function(t) {
            private$generate(private$time_step(t))
        },
        now = function() {
            self$at_time(Sys.time())
        },
        verify = function(code, t = Sys.time(), window = 1L) {
            g <- private$generate
            ts <- private$time_step(Sys.time())
            if (identical(g(ts), code)) {
                return(t)
            }
            for (i in seq_len(window)) {
                if (identical(g(ts - i), code)) {
                    return(as.POSIXct((ts - i) * private$period))
                }
                if (identical(g(ts + i), code)) {
                    return(as.POSIXct((ts + i) * private$period))
                }
            }
            NULL
        },
        provisioning_uri = function(name, issuer = NULL) {
            super$provisioning_uri(
                type = "totp",
                name = name,
                issuer = issuer,
                period = if (private$period == 30) NULL else private$period
            )
        }
    )
)
