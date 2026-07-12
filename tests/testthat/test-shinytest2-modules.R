test_that("ns-qualified update and open work inside a module", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/modules"), name = "modules")
  withr::defer(app$stop())

  expect_equal(app$get_value(input = "w1-sel"), "red")

  app$click("w1-set")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "w1-sel"), "green")

  app$click("w1-open")
  app$wait_for_idle()
  expect_true(app$get_value(input = "w1-dlg"))

  expect_no_js_errors(app)
})
