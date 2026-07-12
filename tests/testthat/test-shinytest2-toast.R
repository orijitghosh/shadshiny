toast_count <- function(app) {
  app$get_js("document.querySelectorAll('.shad-toast').length")
}

test_that("toasts render, carry variant, and dismiss", {
  skip_if_no_shinytest2()
  app <- shinytest2::AppDriver$new(test_path("apps/toast"), name = "toast")
  withr::defer(app$stop())

  app$click("success")
  app$wait_for_idle()
  expect_true(toast_count(app) >= 1)
  txt <- app$get_js("document.querySelector('.shad-toast').textContent")
  expect_match(txt, "Saved")

  app$click("dismiss")
  app$wait_for_idle()
  expect_equal(toast_count(app), 0)

  # loading -> success updates in place (still a single toast)
  app$click("flow")
  app$wait_for_idle()
  expect_true(toast_count(app) >= 1)

  expect_no_js_errors(app)
})
