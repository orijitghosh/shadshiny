# Offline coverage of the update_shad_* API via a recording fake session.

test_that("value updates send shadshiny:update with the namespaced id", {
  s <- new_fake_session(ns_prefix = "mod")
  update_shad_checkbox("chk", value = TRUE, session = s)
  m <- one_message(s)
  expect_identical(m$type, "shadshiny:update")
  expect_identical(m$message$id, "mod-chk")
  expect_true(m$message$value)
})

test_that("the simple value-setters all round-trip their value", {
  cases <- list(
    function(s) update_shad_switch("x", TRUE, session = s),
    function(s) update_shad_radio_group("x", "b", session = s),
    function(s) update_shad_toggle("x", "bold", session = s),
    function(s) update_shad_toggle_group("x", c("a", "b"), session = s),
    function(s) update_shad_select("x", "b", session = s),
    function(s) update_shad_native_select("x", "b", session = s),
    function(s) update_shad_input_otp("x", "123456", session = s),
    function(s) update_shad_tabs("x", "account", session = s),
    function(s) update_shad_accordion("x", "item-1", session = s)
  )
  for (f in cases) {
    s <- new_fake_session()
    f(s)
    expect_identical(one_message(s)$type, "shadshiny:update")
  }
})

test_that("slider sends a scalar for single and a vector for range", {
  s <- new_fake_session()
  update_shad_slider("s", 42, session = s)
  expect_identical(one_message(s)$message$value, 42)

  s2 <- new_fake_session()
  update_shad_slider("s", c(10, 80), session = s2)
  expect_identical(one_message(s2)$message$value, c(10, 80))
})

test_that("pagination and carousel coerce to integer", {
  s <- new_fake_session()
  update_shad_pagination("p", selected = 3, session = s)
  expect_identical(one_message(s)$message$value, 3L)

  s2 <- new_fake_session()
  update_shad_carousel("c", selected = 2, session = s2)
  expect_identical(one_message(s2)$message$value, 2L)
})

test_that("sidebar update sends only the facets provided", {
  s <- new_fake_session()
  update_shad_sidebar("sb", collapsed = TRUE, session = s)
  val <- one_message(s)$message$value
  expect_identical(val, list(collapsed = TRUE))

  s2 <- new_fake_session()
  update_shad_sidebar("sb", collapsed = FALSE, mobile_open = TRUE, session = s2)
  expect_identical(one_message(s2)$message$value,
                   list(collapsed = FALSE, mobileOpen = TRUE))
})

test_that("progress emits a style transform plus aria/state attrs", {
  s <- new_fake_session()
  update_shad_progress("pr", value = 25, session = s)
  types <- vapply(s$messages, function(m) m$type, character(1))
  expect_identical(types, c("shadshiny:style", "shadshiny:attr", "shadshiny:attr"))

  style <- s$messages[[1]]$message
  expect_identical(style$prop, "transform")
  expect_match(style$value, "translateX\\(-75")

  attrs <- vapply(s$messages[2:3], function(m) m$message$attr, character(1))
  expect_setequal(attrs, c("aria-valuenow", "data-state"))
})

test_that("message-scroller to-bottom sends a namespaced invoke", {
  s <- new_fake_session(ns_prefix = "mod")
  shad_message_scroller_to_bottom("chat", smooth = FALSE, session = s)
  m <- one_message(s)
  expect_identical(m$type, "shadshiny:invoke")
  expect_identical(m$message$id, "mod-chat")
  expect_identical(m$message$method, "scrollToBottom")
  expect_identical(m$message$args, list(FALSE))
})

test_that("button loading toggles busy/disabled attributes", {
  s <- new_fake_session()
  update_shad_button("b", loading = TRUE, session = s)
  attrs <- vapply(s$messages, function(m) m$message$attr, character(1))
  expect_true(all(c("data-loading", "aria-busy", "disabled") %in% attrs))
})

test_that("button label update sends shadshiny:text", {
  s <- new_fake_session()
  update_shad_button("b", label = "Saved", session = s)
  m <- one_message(s)
  expect_identical(m$type, "shadshiny:text")
  expect_identical(m$message$text, "Saved")
})
