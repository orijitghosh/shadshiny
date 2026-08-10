# The shinytest2 suites drive a real headless Chrome, which leaves its user
# data and crashpad directories behind in the session temp dir. R CMD check
# reports those as detritus, so shut the browser down and sweep them once the
# whole suite is done.
withr::defer(
  {
    if (requireNamespace("chromote", quietly = TRUE) &&
        chromote::has_default_chromote_object()) {
      try(chromote::default_chromote_object()$get_browser()$close(),
          silent = TRUE)
    }
    leftovers <- list.files(
      tempdir(),
      pattern = "^(com\\.google\\.Chrome|scoped_dir|\\.com\\.google\\.Chrome)",
      all.files = TRUE, full.names = TRUE
    )
    unlink(leftovers, recursive = TRUE, force = TRUE)
  },
  teardown_env()
)
