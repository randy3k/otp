test_that("hotp at", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- HOTP$new(secret)
  expect_true(p$at(7) != "964230")
  expect_true(p$at(8) == "964230")
  expect_true(p$at(9) != "964230")
  expect_true(p$at(19) != "461867")
  expect_true(p$at(20) == "461867")
  expect_true(p$at(21) != "461867")
})


test_that("hotp verify", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- HOTP$new(secret)
  expect_equal(p$verify("964230", 8), 8)
  expect_equal(p$verify("461867", 8), NULL)
  expect_equal(p$verify("461867", 20), 20)
  expect_equal(p$verify("461867", 8, 10), NULL)
  expect_equal(p$verify("461867", 8, 12), 20)
  expect_equal(p$verify("461867", 8, 13), 20)
})


test_that("hotp more digits", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- HOTP$new(secret, digits = 8)
  expect_equal(p$at(8), "20964230")
  expect_equal(p$at(20), "34461867")
})


test_that("hotp different algorithm", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- HOTP$new(secret, algorithm = "sha256")
  expect_equal(p$at(8), "349119")
  expect_equal(p$at(20), "906628")
})


test_that("hotp different algorithm", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- HOTP$new(secret, algorithm = "sha512")
  expect_equal(p$at(8), "131699")
  expect_equal(p$at(20), "771162")
})


test_that("hotp provision", {
  secret <- "JBSWY3DPEHPK3PXP"
  p <- HOTP$new(secret)
  expect_equal(
    p$provisioning_uri("Alice"),
    "otpauth://hotp/Alice?secret=JBSWY3DPEHPK3PXP&counter=0"
  )
  expect_equal(
    p$provisioning_uri("Alice", issuer = "example.com", counter = 5),
    "otpauth://hotp/example.com:Alice?secret=JBSWY3DPEHPK3PXP&issuer=example.com&counter=5"
  )
  p <- HOTP$new(secret, digits = 7, algorithm = "sha256")
  expect_equal(
    p$provisioning_uri("Alice", counter = 5),
    "otpauth://hotp/Alice?secret=JBSWY3DPEHPK3PXP&counter=5&digits=7&algorithm=sha256"
  )
})
