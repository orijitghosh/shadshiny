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

test_that("server-created dialogs open themselves and clean up on close", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/tier3-overlays"),
                                   name = "overlays-server-created")
  withr::defer(app$stop())

  count <- function(sel) app$get_js(sprintf("document.querySelectorAll('%s').length", sel))

  expect_equal(count("#made"), 0)

  app$click("show_made")
  app$wait_for_idle()
  # inserted, opened by the runtime, and Shiny-bound: the input inside it is
  # live, which is the whole point of building the dialog in the server.
  expect_equal(count("#made"), 1)
  expect_true(app$get_value(input = "made"))
  expect_equal(app$get_value(input = "made_name"), "Grace")
  expect_true(count(".shad-dialog__content[data-state='open']") >= 1)

  # transient: closing removes the markup entirely (root, overlay, content)
  app$click("remove_made")
  app$wait_for_idle()
  Sys.sleep(1)  # the teardown waits out the exit animation
  expect_equal(count("#made"), 0)

  # transient = FALSE: stays in the document and can be reopened
  app$click("show_kept")
  app$wait_for_idle()
  expect_true(app$get_value(input = "keptdlg"))
  app$run_js("document.getElementById('keptdlg').__shadInstance.close()")
  app$wait_for_idle()
  Sys.sleep(1)
  expect_equal(count("#keptdlg"), 1)

  expect_no_js_errors(app)
})
