test_that("ExtendedTask status binds to button lifecycle in a real Shiny app", {
  skip_if_no_shinytest2()
  if (!exists("ExtendedTask", envir = asNamespace("shiny"), inherits = FALSE)) {
    skip("installed Shiny has no ExtendedTask")
  }

  app <- shinytest2::AppDriver$new(test_path("apps/task-button"), name = "task-button")
  withr::defer(app$stop())

  expect_equal(app$get_value(output = "status"), "initial")
  expect_false(app$get_js("document.getElementById('run').disabled"))

  app$click(selector = "#run")
  app$wait_for_js(
    "document.getElementById('run').hasAttribute('data-loading')",
    timeout = 3000
  )
  expect_true(app$get_js("document.getElementById('run').disabled"))
  app$run_js("document.getElementById('run').click()")
  app$wait_for_idle()
  expect_equal(app$get_value(output = "invocations"), "1")
  expect_equal(app$get_value(output = "status"), "success")
  expect_equal(app$get_js("document.getElementById('run').textContent.trim()"), "Complete")
  expect_false(app$get_js("document.getElementById('run').disabled"))

  app$set_inputs(mode = "error")
  app$click(selector = "#run")
  app$wait_for_idle()
  expect_equal(app$get_value(output = "status"), "error")
  expect_equal(app$get_value(output = "invocations"), "2")
  expect_equal(app$get_js("document.getElementById('run').textContent.trim()"), "Try again")
  expect_false(app$get_js("document.getElementById('run').disabled"))
  expect_no_js_errors(app)
})
