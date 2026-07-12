test_that("a renderUI-inserted select binds and accepts server updates", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/dynamic-ui"), name = "dynamic")
  withr::defer(app$stop())

  app$click("add")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "dyn"), "a")

  app$click("set_b")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "dyn"), "b")

  expect_no_js_errors(app)
})
