test_that("v2 inputs seed correctly and reflect server updates", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/v2"), name = "v2")
  withr::defer(app$stop())

  # initial seeds
  expect_equal(app$get_value(input = "rate"), 2)
  expect_equal(app$get_value(input = "num"), 4)
  expect_equal(app$get_value(input = "step"), 1)

  tbl <- app$get_value(input = "tbl")
  expect_equal(tbl$page, 1)
  expect_equal(tbl$pageSize, 5)
  expect_length(tbl$selected, 0)

  # server-driven updates propagate back to input$. The table reports through
  # a debounced binding, so wait for its new value rather than for idleness.
  app$click("do_update")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "rate"), 4)
  expect_equal(app$get_value(input = "num"), 7)
  expect_equal(app$get_value(input = "step"), 2)
  expect_equal(app$get_value(input = "tree"), "pear")
  tbl <- app$wait_for_value(input = "tbl", ignore = list(NULL, tbl))
  expect_equal(as.integer(tbl$selected), c(1L, 3L))

  expect_no_js_errors(app)
})

test_that("the data table sorts and filters on the client", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/v2"), name = "v2-table")
  withr::defer(app$stop())

  # 8 rows at pageSize 5 => 5 rendered
  n_rows <- function() {
    app$get_js("document.querySelectorAll('#tbl tbody tr').length")
  }
  expect_equal(n_rows(), 5)
  # The table reports through a debounced binding (and debounces its filter),
  # so each step waits for input$tbl to change instead of for idleness: on a
  # slow runner Shiny can sit idle for the whole wait before the value lands.
  tbl <- app$get_value(input = "tbl")

  # a header click sorts client-side and reports back through input$
  app$run_js("document.querySelector('#tbl .shad-data-table__sort').click()")
  tbl <- app$wait_for_value(input = "tbl", ignore = list(NULL, tbl))
  expect_equal(tbl$sort[[1]]$column, "model")
  expect_equal(tbl$sort[[1]]$direction, "asc")

  # the global filter narrows the rendered rows without a server round-trip
  app$run_js(paste0(
    "var i = document.querySelector('#tbl .shad-data-table__filter');",
    "i.value = 'Mazda';",
    "i.dispatchEvent(new Event('input', { bubbles: true }));"
  ))
  tbl <- app$wait_for_value(input = "tbl", ignore = list(NULL, tbl))
  expect_equal(tbl$filter$global, "Mazda")
  expect_equal(n_rows(), 2)

  expect_no_js_errors(app)
})

test_that("the rating and number stepper respond to clicks", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/v2"), name = "v2-clicks")
  withr::defer(app$stop())

  # click the 5th star
  app$run_js("document.querySelectorAll('#rate .shad-rating__item')[4].click()")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "rate"), 5)

  # the increment button steps by `step`. It nudges on pointerdown (so
  # hold-to-repeat works), which .click() does not fire.
  app$run_js(paste0(
    "var b = document.querySelector('#num .shad-number-stepper__btn--inc');",
    "b.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));",
    "b.dispatchEvent(new PointerEvent('pointerup', { bubbles: true }));"
  ))
  app$wait_for_idle()
  expect_equal(app$get_value(input = "num"), 5)

  expect_no_js_errors(app)
})

test_that("the theme reporter seeds input$.shad_theme and tracks dark mode", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/v2"), name = "v2-theme")
  withr::defer(app$stop())

  # Regression: the reporter used to read document.body and Shiny.setInputValue
  # unguarded while the bundle loads in <head>, so it threw and aborted the rest
  # of shadshiny-shiny.js -- taking shad.autoInit() and this input with it.
  th <- app$get_value(input = ".shad_theme")
  expect_false(is.null(th))
  expect_false(th$dark)

  app$run_js("document.documentElement.classList.add('dark')")
  app$wait_for_idle()
  expect_true(app$get_value(input = ".shad_theme")$dark)

  # autoInit's MutationObserver must still wire components inserted after load.
  app$run_js(paste0(
    "var d = document.createElement('div');",
    "d.innerHTML = '<div class=\"shad-slider\" data-shad=\"slider\" id=\"dyn\"",
    " data-min=\"0\" data-max=\"100\" data-value=\"10\">",
    "<div class=\"shad-slider__track\"><div class=\"shad-slider__range\"></div></div>",
    "<div class=\"shad-slider__thumb\" role=\"slider\" tabindex=\"0\"></div></div>';",
    "document.body.appendChild(d.firstChild);"
  ))
  app$wait_for_idle()
  expect_true(app$get_js("!!shad.get(document.getElementById('dyn'))"))

  expect_no_js_errors(app)
})
