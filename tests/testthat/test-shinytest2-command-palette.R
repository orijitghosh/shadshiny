test_that("command palette opens from trigger, hotkey and server", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/command-palette"),
                                   name = "command-palette")
  withr::defer(app$stop())

  is_open <- function() {
    app$get_js("!!document.getElementById('pal').__shadInstance.isOpen")
  }
  close <- function() {
    app$run_js("document.getElementById('pal').__shadInstance.close()")
    app$wait_for_idle()
    Sys.sleep(0.6)  # the exit animation restores the portal
  }

  # dialog mode: hidden until opened
  expect_false(is_open())

  app$run_js("document.querySelector('[data-shad-command-open]').click()")
  app$wait_for_idle()
  expect_true(is_open())
  close()

  # mod+k
  app$run_js(paste0("document.dispatchEvent(new KeyboardEvent('keydown',",
                    "{key:'k',ctrlKey:true,bubbles:true}))"))
  app$wait_for_idle()
  expect_true(is_open())
  close()

  app$click("open_server")
  app$wait_for_idle()
  expect_true(is_open())

  expect_no_js_errors(app)
})

test_that("every activation is reported, including a repeat of the same value", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/command-palette"),
                                   name = "command-palette-events")
  withr::defer(app$stop())

  pick <- function(value) {
    app$run_js("document.querySelector('[data-shad-command-open]').click()")
    app$wait_for_idle()
    app$run_js(sprintf(
      "document.querySelector('#pal .shad-command__item[data-value=\"%s\"]').click()",
      value))
    app$wait_for_idle()
    Sys.sleep(0.6)
  }

  pick("reports")
  pick("reports")

  # input$pal would have deduplicated the second one; input$pal_event does not,
  # which is what makes the palette usable for navigation.
  expect_equal(app$get_value(input = "pal_event")$value, "reports")
  expect_match(app$get_value(output = "state"), '"reports" "reports"')

  expect_no_js_errors(app)
})

test_that("update_shad_command swaps the items and the filter follows", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/command-palette"),
                                   name = "command-palette-update")
  withr::defer(app$stop())

  values <- function() {
    app$get_js(paste0("Array.from(document.querySelectorAll",
                      "('#pal .shad-command__item')).map(e => e.dataset.value)"))
  }
  expect_equal(unlist(values()), c("dashboard", "reports", "new"))

  app$click("refresh")
  app$wait_for_idle()
  expect_equal(unlist(values()), "q3")
  # the replacement is re-filtered, so something is highlighted for Enter
  expect_true(app$get_js(
    "!!document.querySelector('#pal .shad-command__item[data-highlighted]')"))
  # swapped-in items are options like the first ones: role, id, no tab stop
  item <- app$get_js(paste0(
    "(() => { const it = document.querySelector('#pal .shad-command__item');",
    " const q = document.querySelector('#pal .shad-command__input');",
    " return [it.getAttribute('role'), it.getAttribute('tabindex'),",
    " String(it.id !== '' && q.getAttribute('aria-activedescendant') === it.id)]; })()"))
  expect_equal(unlist(item), c("option", "-1", "true"))
  # and the replacement empty text answers a query with no match
  empty <- app$get_js(paste0(
    "(() => { const q = document.querySelector('#pal .shad-command__input');",
    " q.value = 'zzz'; q.dispatchEvent(new Event('input', {bubbles: true}));",
    " const e = document.querySelector('#pal .shad-command__empty');",
    " return e.hidden ? 'hidden' : e.textContent; })()"))
  expect_equal(empty, "No results found.")

  expect_no_js_errors(app)
})
