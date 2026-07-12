# Shared guards for the shinytest2 integration suites. These fixtures need a
# real headless browser (chromote), so they are skipped on CRAN and wherever
# shinytest2/chromote is unavailable.
skip_if_no_shinytest2 <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("shinytest2")
  testthat::skip_if_not_installed("chromote")
  testthat::skip_if_not(
    tryCatch(chromote::find_chrome() != "", error = function(e) FALSE),
    "Chrome not available"
  )
}

# Fail if the browser console logged any error during the scenario.
expect_no_js_errors <- function(app) {
  logs <- app$get_logs()
  errs <- logs[logs$level %in% c("error") & logs$location == "browser", ]
  testthat::expect_equal(nrow(errs), 0L,
                         info = paste(utils::capture.output(print(errs)),
                                      collapse = "\n"))
}
