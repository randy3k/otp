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
