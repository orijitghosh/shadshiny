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

# --- server-created overlays --------------------------------------------------

test_that("show_dialog marks an overlay self-opening and self-removing", {
  spec <- shadshiny:::.shad_transient_overlay(shad_dialog("d", title = "T"))
  h <- as.character(spec$tag)
  expect_identical(spec$id, "d")
  expect_identical(spec$kind, "dialog")
  expect_match(h, "data-shad-open")
  expect_match(h, "data-shad-transient")

  # transient = FALSE keeps the overlay in the document after it closes
  keep <- as.character(
    shadshiny:::.shad_transient_overlay(shad_dialog("d", title = "T"), FALSE)$tag)
  expect_match(keep, "data-shad-open")
  expect_false(grepl("data-shad-transient", keep, fixed = TRUE))
})

test_that("show_dialog accepts every modal overlay kind", {
  for (tag in list(shad_dialog("a", title = "T"),
                   shad_alert_dialog("b", title = "T"),
                   shad_sheet("c", title = "T"),
                   shad_drawer("e", title = "T"))) {
    expect_match(as.character(shadshiny:::.shad_transient_overlay(tag)$tag),
                 "data-shad-open")
  }
})

test_that("show_dialog rejects non-overlay and anchored tags", {
  expect_error(shadshiny:::.shad_transient_overlay(shad_badge("x")),
               "non-overlay tag")
  # a popover positions against a trigger, so there is nothing to anchor to
  expect_error(
    shadshiny:::.shad_transient_overlay(shad_popover("p", trigger = shad_button("x"))),
    "got a popover")
  expect_error(shadshiny:::.shad_transient_overlay("not a tag"),
               "must be a shadshiny overlay tag")
})
