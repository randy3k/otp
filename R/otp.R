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
#' - **secret** a scalar character, the base32-based secret key.
#' - **digits** an integer, the number of digits of the password.
#' - **algorithm** the hash algorithm used, possible values are
#'   "sha1", "sha256" and "sha512".
#'
#' # Methods
#'
#' \preformatted{
#' HOTP$at(counter)
#' }
#' Generate an one time password at counter value.
#' - **counter** a non-negative integer.
#'
#' \preformatted{
#' HOTP$verify(code, counter, ahead = 0L)
#' }
#' Verify if a given one time password is valid. Returns the matching `counter` value if there
#' is a match within the `ahead`. Otherwise return `NULL`.
#' - **code** a string of digits.
#' - **counter** a non-negative integer.
#' - **ahead** a non-negative integer, the amount of counter ticks to look ahead.
#'
#' \preformatted{
#' HOTP$provisioning_uri(name, issuer = NULL, counter = 0L)
#' }
#' Return a provisioning uri which is compatible with google authenticator format.
#' - **name** account name.
#' - **issuer** issuer name.
#' - **counter** a non-negative integer, initial counter.
#'
#' @examples
#' p <- HOTP$new("JBSWY3DPEHPK3PXP")
#' p$at(8)
#'
#' p$verify("964230", 8)
#' p$verify("964230", 7, ahead = 3)
#'
#' p$provisioning_uri("Alice", issuer = "example.com", counter = 5)
#' @seealso \url{https://tools.ietf.org/html/rfc4226}
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
        verify = function(code, counter, ahead = 0L) {
            g <- private$generate
            for (i in seq_len(ahead + 1L)) {
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
#' @details
#' # Initialization
#'
#' \preformatted{
#' TOTP$new(secret, digits = 6L, period = 30, algorithm = "sha1")
#' }
#' Create an One Time Password object
#' - **secret** a scalar character, the base32-based secret key.
#' - **digits** an integer, the number of digits of the password.
#' - **period** a positive number, the number of seconds in a time step.
#' - **algorithm** the hash algorithm used, possible values are
#'   "sha1", "sha256" and "sha512".
#'
#' # Methods
#'
#' \preformatted{
#' TOTP$at_time(t)
#' }
#' Generate an one time password at a given time value.
#' - **t** a POSIXct object or an integer that represents the numbers of second since UNIX epoch.
#'
#' \preformatted{
#' HOTP$verify(code, t, behind = 0L)
#' }
#' Verify if a given one time password is valid. Returns the beginning time of the time
#'   step window if there is a match within the `behind`. Otherwise return `NULL`.
#' - **code** a string of digits.
#' - **t** a POSIXct object or an integer that represents the numbers of second since UNIX epoch.
#' - **behind** a non-negative integer, the amount of time steps to look behind. A value of `1`
#'   means to accept the code before `period` second ago.
#'
#' \preformatted{
#' HOTP$provisioning_uri(name, issuer = NULL)
#' }
#' Return a provisioning uri which is compatible with google authenticator format.
#' - **name** account name.
#' - **issuer** issuer name.
#'
#' @examples
#' p <- TOTP$new("JBSWY3DPEHPK3PXP")
#' (code <- p$now())
#' p$verify(code, behind = 1)
#'
#' (current_time <- Sys.time())
#' (code <- p$at_time(current_time))
#' p$verify(code, current_time + 30, behind = 1)
#'
#' p$provisioning_uri("Alice", issuer = "example.com")
#' @seealso \url{https://tools.ietf.org/html/rfc6238}
#' @export
TOTP <- R6::R6Class(
    "TOTP",
    inherit = OTP,
    private = list(
        period = NULL,
        time_step = function(t) {
            if (inherits(t, "POSIXct")) {
                t <- as.double(t)
            }
            t %/% private$period
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
        verify = function(code, t = Sys.time(), behind = 0L) {
            g <- private$generate
            ts <- private$time_step(t)
            if (identical(g(ts), code)) {
                return(.POSIXct(ts * private$period))
            }
            for (i in seq_len(behind)) {
                if (identical(g(ts - i), code)) {
                    return(.POSIXct((ts - i) * private$period))
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
