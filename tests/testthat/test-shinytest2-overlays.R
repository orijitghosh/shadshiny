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

  count <- function(sel) app$get_js(paste0("document.querySelectorAll(\"", sel, "\").length"))
  wait_for_dom <- function(condition, timeout = 5000) {
    deadline <- as.numeric(Sys.time()) + timeout / 1000
    repeat {
      state <- app$get_js(sprintf("(%s) ? 'ready' : 'pending'", condition))
      if (identical(state, "ready")) return(invisible(NULL))
      if (as.numeric(Sys.time()) >= deadline) {
        stop(sprintf("Timed out waiting for DOM condition: %s", condition),
             call. = FALSE)
      }
      Sys.sleep(0.1)
    }
  }

  expect_equal(count("#made"), 0)

  app$click("show_made")
  # Server insertion is observable before shinytest2 can necessarily settle
  # its global idle tracker; assert the component's actual DOM lifecycle.
  wait_for_dom("document.querySelector('#made') !== null")
  wait_for_dom("document.querySelector('.shad-dialog__content[data-state=\"open\"]') !== null")
  # inserted, opened by the runtime, and Shiny-bound: the input inside it is
  # live, which is the whole point of building the dialog in the server.
  expect_equal(count("#made"), 1)
  expect_true(app$get_value(input = "made"))
  expect_equal(app$get_value(input = "made_name"), "Grace")
  expect_true(count(".shad-dialog__content[data-state='open']") >= 1)

  # transient: closing removes the markup entirely (root, overlay, content)
  app$click("remove_made")
  wait_for_dom("document.querySelector('#made') === null")
  expect_equal(count("#made"), 0)

  # transient = FALSE: stays in the document and can be reopened
  app$click("show_kept")
  wait_for_dom("document.querySelector('#keptdlg') !== null")
  wait_for_dom("document.querySelector('.shad-dialog__content[data-state=\"open\"]') !== null")
  expect_true(app$get_value(input = "keptdlg"))
  app$run_js("document.getElementById('keptdlg').__shadInstance.close()")
  # Wait for the settled state, not the exit animation: the closed panel only
  # sits under <body> until Presence finishes, then returns to its root.
  wait_for_dom("document.querySelector('#keptdlg > .shad-dialog__content[data-state=\"closed\"][hidden]') !== null")
  expect_equal(count("#keptdlg"), 1)
  expect_false(app$wait_for_value(input = "keptdlg", ignore = list(TRUE, NULL)))

  app$run_js("document.getElementById('keptdlg').__shadInstance.open()")
  wait_for_dom("document.querySelector('body > .shad-dialog__content[data-state=\"open\"]') !== null")
  expect_true(app$wait_for_value(input = "keptdlg", ignore = list(FALSE, NULL)))

  expect_no_js_errors(app)
})
