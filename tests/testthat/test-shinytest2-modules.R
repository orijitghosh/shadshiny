test_that("ns-qualified update and open work inside a module", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/modules"), name = "modules")
  withr::defer(app$stop())

  expect_equal(app$get_value(input = "w1-sel"), "red")
  expect_equal(app$get_value(input = "w1-cbx"), "red")
  expect_equal(as.character(app$get_value(input = "w1-dp")), "2026-10-14")

  app$click("w1-set")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "w1-sel"), "green")
  expect_equal(app$get_value(input = "w1-cbx"), c("red", "blue"))
  expect_equal(as.character(app$get_value(input = "w1-dp")), "2026-10-20")
  expect_true(app$get_js("document.querySelector('#w1-cmd [data-value=\"gamma\"]') !== null"))

  app$click("w1-open")
  app$wait_for_idle()
  expect_true(app$get_value(input = "w1-dlg"))

  expect_no_js_errors(app)
})

test_that("a module's server table, rendered by its renderUI, is served", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/modules"), name = "modules-table")
  withr::defer(app$stop())

  app$wait_for_js("document.querySelectorAll('#w1-tbl tbody tr[data-key]').length === 5",
                  timeout = 5000)
  expect_equal(app$get_value(input = "w1-tbl")$requestId, 1L)
  app$run_js("shad.get(document.getElementById('w1-tbl')).setValue({page: 2})")
  # The page request leaves through a debounced binding and the rows come back
  # from the server, so wait for them rather than for idleness.
  app$wait_for_js(
    "document.querySelector('#w1-tbl tbody tr[data-key]')?.dataset.key === 'r06'",
    timeout = 5000
  )
  expect_equal(app$get_js("document.querySelector('#w1-tbl tbody tr').dataset.key"), "r06")

  app$click("w1-open_cmd")
  app$wait_for_idle()
  expect_equal(app$get_js("document.getElementById('w1-cmd').dataset.state"), "open")

  expect_no_js_errors(app)
})
