test_that("questionnaire round-trips state, update, and lifecycle through Shiny", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/questionnaire"), name = "questionnaire")
  withr::defer(app$stop())

  expect_equal(app$get_value(input = "survey")$active, 1)
  app$run_js("document.querySelector('#survey input[value=\"data\"]').click()")
  app$wait_for_idle()
  app$run_js("document.querySelector('#survey [data-questionnaire-next]').click()")
  app$wait_for_idle()
  app$run_js("document.querySelector('#survey input[type=checkbox][value=\"search\"]').click()")
  app$wait_for_idle()
  # Multiple-choice answers are represented as JSON-safe arrays, even when
  # exactly one option is selected.
  expect_equal(app$get_value(input = "survey")$answers$features, list("search"))

  app$click("set_server")
  app$wait_for_idle()
  expect_equal(app$get_js("document.querySelector('#survey input[type=text]').value"), "From server")
  expect_equal(app$get_value(input = "survey")$active, 3)

  app$click("reset")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "survey")$active, 1)
  expect_no_js_errors(app)
})
