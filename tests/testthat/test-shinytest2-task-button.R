test_that("ExtendedTask status binds to button lifecycle in a real Shiny app", {
  skip_if_no_shinytest2()
  if (!exists("ExtendedTask", envir = asNamespace("shiny"), inherits = FALSE)) {
    skip("installed Shiny has no ExtendedTask")
  }

  app <- shinytest2::AppDriver$new(test_path("apps/task-button"), name = "task-button")
  withr::defer(app$stop())
  wait_for_label <- function(label) {
    app$wait_for_js(
      sprintf("document.getElementById('run').textContent.trim() === '%s'", label),
      timeout = 5000
    )
  }

  expect_equal(app$get_value(output = "status"), "initial")
  expect_false(app$get_js("document.getElementById('run').disabled"))

  app$click(selector = "#run")
  app$wait_for_js(
    "document.getElementById('run').hasAttribute('data-loading')",
    timeout = 3000
  )
  expect_true(app$get_js("document.getElementById('run').disabled"))
  app$run_js("document.getElementById('run').click()")
  # The task settles on a later() timer and ExtendedTask does not keep Shiny
  # busy, so wait for the settled status rather than for idleness.
  status <- app$wait_for_value(output = "status", ignore = list(NULL, "", "initial", "running"))
  expect_equal(status, "success")
  wait_for_label("Complete")
  expect_equal(app$get_value(output = "invocations"), "1")
  expect_equal(app$get_js("document.getElementById('run').textContent.trim()"), "Complete")
  expect_false(app$get_js("document.getElementById('run').disabled"))

  app$set_inputs(mode = "error")
  app$click(selector = "#run")
  status <- app$wait_for_value(output = "status", ignore = list(NULL, "", "success", "running"))
  expect_equal(status, "error")
  wait_for_label("Try again")
  expect_equal(app$get_value(output = "invocations"), "2")
  expect_equal(app$get_js("document.getElementById('run').textContent.trim()"), "Try again")
  expect_false(app$get_js("document.getElementById('run').disabled"))
  expect_no_js_errors(app)
})
