# Shipped examples: the UI must be wired and labelled the way the package
# expects, since users copy these apps as starting points.

example_env <- function(name) {
  app <- system.file("examples", name, "app.R", package = "shadshiny")
  env <- new.env(parent = globalenv())
  sys.source(app, envir = env, chdir = TRUE)
  env
}

# The static UI plus any server-rendered pieces named in `rendered`.
example_ui <- function(name, rendered = character()) {
  env <- example_env(name)
  as.character(htmltools::tagList(env$ui, lapply(rendered, function(f) env[[f]]())))
}

# Every <select> needs an accessible name: aria-label or a <label for=id>.
unnamed_selects <- function(html) {
  selects <- regmatches(html, gregexpr("<select[^>]*>", html))[[1]]
  named <- vapply(selects, function(tag) {
    if (grepl("aria-label=", tag, fixed = TRUE)) return(TRUE)
    id <- sub('.*\\sid="([^"]+)".*', "\\1", tag)
    id != tag && grepl(sprintf('for="%s"', id), html, fixed = TRUE)
  }, logical(1))
  unname(selects[!named])
}

test_that("the LLM chat example's Clear button carries the id its server reads", {
  expect_match(example_ui("08-llm-chat"), '<button[^>]*id="clear"')
})

test_that("example native selects all have accessible names", {
  pages <- list(
    `01-auth-onboarding` = example_ui("01-auth-onboarding", "step_profile"),
    `05-settings-profile` = example_ui("05-settings-profile"),
    `kitchen-sink` = example_ui("kitchen-sink")
  )
  for (name in names(pages)) {
    expect_identical(unnamed_selects(pages[[name]]), character(), info = name)
  }
})

# The ggplot theme leaves the plot background transparent so it sits on the
# card; renderPlot() must not paint its default white PNG behind it.
test_that("example plots render on a transparent background", {
  for (name in c("07-data-explorer", "kitchen-sink")) {
    app <- system.file("examples", name, "app.R", package = "shadshiny")
    calls <- Filter(
      function(x) identical(x[[1]], as.name("renderPlot")),
      unlist(lapply(parse(app), function(e) {
        found <- list()
        walk <- function(x) {
          if (is.call(x)) {
            found[[length(found) + 1L]] <<- x
            lapply(as.list(x), walk)
          }
          invisible()
        }
        walk(e)
        found
      }))
    )
    expect_gt(length(calls), 0)
    for (call in calls) {
      expect_identical(as.list(call)$bg, "transparent", info = name)
    }
  }
})
