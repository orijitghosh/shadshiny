test_that("a renderUI-inserted select binds and accepts server updates", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/dynamic-ui"), name = "dynamic")
  withr::defer(app$stop())

  app$click("add")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "dyn"), "a")

  app$click("set_b")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "dyn"), "b")

  expect_no_js_errors(app)
})

# Contract: a component that renderUI() inserts, removes or renders anew
# 1. binds, takes server updates, and (the data table) is served its pages;
# 2. leaves nothing behind when removed with a popup or dialog open: no
#    panel, dialog or overlay in <body>, no live hotkey, no Shiny binding;
# 3. comes back as one root per id, bound and served again.
test_that("five components survive insert, remove and re-render (1-3)", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/dynamic-ui"), name = "lifecycle")
  withr::defer(app$stop())

  phase <- function(p) {
    app$set_inputs(phase = p, allow_no_input_binding_ = TRUE, priority_ = "event")
    app$wait_for_idle()
  }
  js <- function(code) app$get_js(code)
  ids <- c("l_sel", "l_cbx", "l_dp", "l_cmd", "l_tbl")
  roots <- function() {
    js(sprintf("[%s].map(id => document.querySelectorAll('[id=\"' + id + '\"]').length)",
               paste0("'", ids, "'", collapse = ",")))
  }
  table_rows <- function() js("document.querySelectorAll('#l_tbl tbody tr[data-key]').length")
  open_all <- function() {
    app$run_js("['l_sel', 'l_cbx', 'l_dp'].forEach(id => shad.get(document.getElementById(id)).open());
      shad.get(document.querySelector('#l_tbl [data-shad=\"dropdown-menu\"]')).open();
      shad.get(document.getElementById('l_cmd')).open();")
  }
  leftovers <- function() {
    js("Array.from(document.body.children).filter(el =>
          el.matches('[class*=\"__content\"], [data-shad=\"command\"], .shad-command__overlay'))
        .map(el => el.className)")
  }
  hotkey <- function() {
    app$run_js("document.dispatchEvent(new KeyboardEvent('keydown',
      {key: 'k', ctrlKey: true, bubbles: true}))")
    js("document.querySelectorAll('[data-shad=\"command\"][data-state=\"open\"]').length")
  }
  update <- function() {
    app$set_inputs(update = "go", allow_no_input_binding_ = TRUE, priority_ = "event")
    app$wait_for_idle()
  }

  # (1) inserted late: bound, updated, served
  phase("show")
  expect_equal(unlist(roots()), rep(1L, 5))
  expect_equal(app$get_value(input = "l_sel"), "a")
  expect_equal(app$get_value(input = "l_cbx"), "red")
  expect_equal(as.character(app$get_value(input = "l_dp")), "2026-10-14")
  expect_equal(table_rows(), 10L)
  update()
  expect_equal(app$get_value(input = "l_sel"), "b")
  expect_equal(app$get_value(input = "l_cbx"), c("red", "blue"))
  expect_equal(as.character(app$get_value(input = "l_dp")), "2026-10-20")
  expect_equal(js("document.querySelector('#l_cmd [data-value=\"gamma\"]') !== null"), TRUE)

  # (2, 3) rendered anew with everything open
  open_all()
  Sys.sleep(0.2)
  phase("again")
  Sys.sleep(0.6)                                    # exit animations
  expect_equal(unlist(roots()), rep(1L, 5))
  expect_length(leftovers(), 0L)
  expect_equal(js("document.body.style.overflow"), "")
  expect_equal(table_rows(), 10L)
  expect_equal(app$get_value(input = "l_sel"), "a")
  update()
  expect_equal(app$get_value(input = "l_sel"), "b")
  expect_equal(as.character(app$get_value(input = "l_dp")), "2026-10-20")
  expect_equal(hotkey(), 1L)
  app$run_js("shad.get(document.getElementById('l_cmd')).close()")
  Sys.sleep(0.6)

  # (2) removed with everything open
  open_all()
  Sys.sleep(0.2)
  phase("hide")
  Sys.sleep(0.6)
  expect_equal(unlist(roots()), rep(0L, 5))
  expect_length(leftovers(), 0L)
  expect_equal(hotkey(), 0L)

  # (3) back again
  phase("show")
  expect_equal(unlist(roots()), rep(1L, 5))
  expect_equal(app$get_value(input = "l_sel"), "a")
  expect_equal(table_rows(), 10L)
  expect_equal(hotkey(), 1L)

  expect_no_js_errors(app)
})
