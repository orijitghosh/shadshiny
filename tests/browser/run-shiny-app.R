args <- commandArgs(trailingOnly = TRUE)
repo <- normalizePath(if (length(args)) args[[1]] else ".", mustWork = TRUE)

Sys.unsetenv(c("LANG", "LC_ALL", "LC_CTYPE"))
pkgload::load_all(
  repo,
  export_all = FALSE,
  helpers = FALSE,
  attach_testthat = FALSE,
  quiet = TRUE
)

fixture <- Sys.getenv("SHADSHINY_BROWSER_FIXTURE", unset = "behavioral-app")
shiny::runApp(
  file.path(repo, "tests", "browser", "fixtures", fixture),
  host = "127.0.0.1",
  port = 4174L,
  launch.browser = FALSE
)
