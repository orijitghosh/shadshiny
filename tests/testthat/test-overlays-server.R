test_that("overlay open/close send shadshiny:invoke with the right method", {
  openers <- list(
    shad_dialog_open, shad_alert_dialog_open, shad_sheet_open,
    shad_drawer_open, shad_popover_open
  )
  for (f in openers) {
    s <- new_fake_session()
    f("ov", session = s)
    m <- one_message(s)
    expect_identical(m$type, "shadshiny:invoke")
    expect_identical(m$message$method, "open")
    expect_identical(m$message$id, "ov")
  }

  closers <- list(
    shad_dialog_close, shad_alert_dialog_close, shad_sheet_close,
    shad_drawer_close, shad_popover_close
  )
  for (f in closers) {
    s <- new_fake_session()
    f("ov", session = s)
    expect_identical(one_message(s)$message$method, "close")
  }
})

test_that("sidebar toggle invokes toggleCollapsed", {
  s <- new_fake_session()
  shad_sidebar_toggle("sb", session = s)
  m <- one_message(s)
  expect_identical(m$message$method, "toggleCollapsed")
})

test_that("invoke ids are namespaced through session$ns", {
  s <- new_fake_session(ns_prefix = "mod")
  shad_dialog_open("dlg", session = s)
  expect_identical(one_message(s)$message$id, "mod-dlg")
})

test_that("toast dismiss with no id targets all toasts", {
  s <- new_fake_session()
  shad_toast_dismiss(session = s)
  m <- one_message(s)
  expect_identical(m$message$kind, "dismiss")
  expect_null(m$message$id)
})
