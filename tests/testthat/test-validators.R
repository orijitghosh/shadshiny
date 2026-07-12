test_that("arg_match_shad errors name the argument and the bad value", {
  err <- expect_error(shad_separator(orientation = "sideways"))
  expect_match(conditionMessage(err), "orientation", fixed = TRUE)
  expect_match(conditionMessage(err), "sideways", fixed = TRUE)
})

test_that("arg_match_shad accepts a valid enum and returns it", {
  expect_silent(shad_separator("vertical"))
})

test_that("icon-only button without a label or aria_label errors", {
  expect_error(shad_button(size = "icon"), "aria_label", fixed = TRUE)
})

test_that("icon button with aria_label is allowed", {
  expect_silent(shad_button(size = "icon", icon = "check", aria_label = "Confirm"))
})

test_that("input_otp validates that group sizes sum to length", {
  expect_error(shad_input_otp("otp", length = 6, groups = c(2, 2)))
  expect_silent(shad_input_otp("otp", length = 6, groups = c(3, 3)))
})
