int_to_bytes <- function(n) {
    # compare it to writeBin(n, raw(0), endian = "big")
    # it supports input up to the size around 2^.Machine$double.digits
    b <- raw(8)
    for (i in seq_along(b)) {
        b[8 - i + 1] <- as.raw(n %% 256L)
        n <- n %/% 256L
    }
    b
}

# see section 5.4 of https://tools.ietf.org/html/rfc4226#page-7
dyn_extract <- function(h) {
    offset <- as.integer(h[length(h)] & as.raw(0xf))
    u <- h[(offset + 1):(offset + 4)]
    u[1] <- u[1] & as.raw(0x7f)
    sum(as.integer(u) * 256 ^ (3:0))
}
