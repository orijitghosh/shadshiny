test_that("tier 2 inputs seed correctly and reflect server updates", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/tier2"), name = "tier2")
  withr::defer(app$stop())

  # initial seeds
  expect_false(app$get_value(input = "chk"))
  expect_true(app$get_value(input = "sw"))
  expect_equal(app$get_value(input = "rg"), "free")
  expect_equal(app$get_value(input = "sl"), 30)
  expect_equal(app$get_value(input = "sel"), "red")
  expect_equal(app$get_value(input = "cb"), "apple")
  expect_equal(app$get_value(input = "tg"), "left")

  # server-driven updates propagate to input$
  app$click("do_update")
  app$wait_for_idle()
  expect_true(app$get_value(input = "chk"))
  expect_false(app$get_value(input = "sw"))
  expect_equal(app$get_value(input = "rg"), "pro")
  expect_equal(app$get_value(input = "sl"), 70)
  expect_equal(app$get_value(input = "sel"), "green")
  expect_equal(app$get_value(input = "cb"), "banana")
  expect_equal(app$get_value(input = "tg"), "right")

  # DOM state mirrors the value
  # The [data-shad="checkbox"] element is itself the <button> carrying data-state.
  state <- app$get_js("document.querySelector('[data-shad=\"checkbox\"]').getAttribute('data-state')")
  expect_equal(state, "checked")

  expect_no_js_errors(app)
})
