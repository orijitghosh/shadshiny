test_that("overlays open/close from the server and report state", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/tier3-overlays"),
                                   name = "overlays")
  withr::defer(app$stop())

  # dialog starts closed
  expect_false(isTRUE(app$get_value(input = "dlg")))

  app$click("open_dlg")
  app$wait_for_idle()
  expect_true(app$get_value(input = "dlg"))
  # The content is portaled to <body> and carries data-state when open.
  open_count <- app$get_js("document.querySelectorAll('.shad-dialog__content[data-state=\"open\"]').length")
  expect_true(open_count >= 1)

  app$click("close_dlg")
  app$wait_for_idle()
  expect_false(app$get_value(input = "dlg"))

  expect_no_js_errors(app)
})
