test_that("tabs/accordion/pagination/carousel round-trip via the server", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/tier3-structure"),
                                   name = "structure")
  withr::defer(app$stop())

  expect_equal(app$get_value(input = "tabs"), "one")
  expect_equal(app$get_value(input = "pg"), 1)

  app$click("go")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "tabs"), "two")
  expect_equal(app$get_value(input = "acc"), "a2")
  expect_equal(app$get_value(input = "pg"), 3)
  expect_equal(app$get_value(input = "car"), 2)

  expect_no_js_errors(app)
})
