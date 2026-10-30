test_that("the exported public API matches its approved baseline", {
  actual <- public_api_current_exports()
  expected <- public_api_export_baseline()

  expect_identical(
    actual,
    expected,
    info = format_public_api_export_changes(actual, expected)
  )
})

test_that("important public function formals match their approved baseline", {
  exports <- public_api_current_exports()
  expected <- public_api_formals_baseline()
  required <- public_api_required_formal_names(exports)

  missing <- setdiff(required, expected$name)
  expect_identical(
    missing,
    character(),
    info = paste(
      "Important public functions lack formal-argument protection:",
      paste(missing, collapse = ", ")
    )
  )

  actual <- public_api_current_formals(expected$name)
  expect_identical(
    actual,
    expected,
    info = format_public_api_formal_changes(actual, expected)
  )
})
