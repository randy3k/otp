test_that("totp at", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- TOTP$new(secret)
  t <- .POSIXct(1587872481)
  expect_true(p$at_time(t) == "825314")
  expect_true(p$at_time(1587872481) == "825314")
  expect_true(p$now() != "825314")  # highly unlikely it is true
})


test_that("totp verify", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- TOTP$new(secret)
  t <- .POSIXct(1587872481)
  trunc_t <- .POSIXct((as.double(t) %/% 30) * 30)
  expect_equal(p$verify("825314", t + 30), NULL)
  expect_equal(p$verify("825314", t), trunc_t)
  expect_equal(p$verify("825314", t - 30), NULL)
  expect_equal(p$verify("825314", t + 30, behind = 1), trunc_t)
})


test_that("totp more digits", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- TOTP$new(secret, digits = 8)
  t <- .POSIXct(1587872481)
  trunc_t <- .POSIXct((as.double(t) %/% 30) * 30)
  expect_equal(p$verify("14825314", t + 30), NULL)
  expect_equal(p$verify("14825314", t), trunc_t)
  expect_equal(p$verify("14825314", t - 30), NULL)
  expect_equal(p$verify("14825314", t + 30, behind = 1), trunc_t)
})


test_that("totp different period", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- TOTP$new(secret, period = 10)
  t <- .POSIXct(1587872481)
  trunc_t <- .POSIXct((as.double(t) %/% 10) * 10)
  expect_equal(p$verify("845792", t + 10), NULL)
  expect_equal(p$verify("845792", t), trunc_t)
  expect_equal(p$verify("845792", t - 10), NULL)
  expect_equal(p$verify("845792", t + 10, behind = 1), trunc_t)
  expect_equal(p$verify("845792", t + 20, behind = 1), NULL)
  expect_equal(p$verify("845792", t + 20, behind = 2), trunc_t)
})


test_that("totp different algorithm", {
  secret <- "JBSWY3DPEHPK3PXP"

  p <- TOTP$new(secret, algorithm = "sha256")
  t <- .POSIXct(1587872481)
  expect_equal(p$at_time(t), "213585")
  expect_equal(p$at_time(t + 30), "759908")

  p <- TOTP$new(secret, algorithm = "sha512")
  t <- .POSIXct(1587872481)
  expect_equal(p$at_time(t), "448289")
  expect_equal(p$at_time(t + 30), "761638")
})


test_that("totp provision", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- TOTP$new(secret)
  expect_equal(
    p$provisioning_uri("Alice"),
    "otpauth://totp/Alice?secret=JBSWY3DPEHPK3PXP"
  )
  expect_equal(
    p$provisioning_uri("Alice", issuer = "example.com"),
    "otpauth://totp/example.com:Alice?secret=JBSWY3DPEHPK3PXP&issuer=example.com"
  )
  p <- TOTP$new(secret, digits = 7, algorithm = "sha256", period = 40)
  expect_equal(
    p$provisioning_uri("Alice"),
    "otpauth://totp/Alice?secret=JBSWY3DPEHPK3PXP&period=40&digits=7&algorithm=sha256"
  )
})
