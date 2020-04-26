int_to_bytes <- function(n) {
    b <- raw(8)
    for (i in seq_along(b)) {
        b[8 - i + 1] <- as.raw(n %% 256L)
        n <- n %/% 256L
    }
    b
}

dymtrunc <- function(h) {
    offset <- as.integer(h[length(h)] & as.raw(0xf))
    u <- h[(offset + 1):(offset + 4)]
    u[1] <- u[1] & as.raw(0x7f)
    sum(as.integer(u) * 256 ^ (3:0))
}


re_match <- function(pattern, x) {
    regmatches(x, regexec(pattern, x, perl = T))
}


prase_uri <- function(uri) {
    if (grepl("^otpauth://", uri)) {
        base32 <- TRUE
        m <- re_match("uri=([^&$]+)", uri)[[1]]
        uri <- m[2]
        if (grepl("^otpauth://hotp", uri)) {
            if (is.null(type)) {
                type <- "hotp"
            } else if (type != "hotp") {
                stop("uri type is hotp")
            }
        } else if (grepl("^otpauth://totp", uri)) {
            type <- "totp"
            if (is.null(type)) {
                type <- "totp"
            } else if (type != "totp") {
                stop("uri type is totp")
            }
        }
    }
}
