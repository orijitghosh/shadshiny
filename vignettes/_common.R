# Shared setup for shadshiny gallery / guide articles.
# Sourced from each article's first chunk: source("_common.R").
#
# Provides demo(): a framed LIVE preview of one or more shadshiny components,
# with a collapsible, syntax-highlighted view of the exact source that made it.
# Because every shad_*() constructor carries the asset dependency, rendering a
# component in an article embeds the real CSS + JS – the previews below are the
# actual components, initialised client-side (dialogs, tabs, accordions and
# carousels all work), and they follow the site's light/dark switch because
# shadshiny keys dark mode off `[data-bs-theme="dark"]`, which pkgdown sets.

suppressPackageStartupMessages({
  library(shiny)
  library(shadshiny)
  library(htmltools)
})

knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  echo     = FALSE,
  message  = FALSE,
  warning  = FALSE
)

# Syntax-highlight R source to HTML using downlit (a pkgdown dependency), so the
# code in each demo matches the site's own code styling. Falls back to escaped
# plain text if downlit is unavailable.
.shad_highlight <- function(code) {
  if (requireNamespace("downlit", quietly = TRUE)) {
    out <- tryCatch(
      downlit::highlight(code, classes = downlit::classes_pandoc()),
      error = function(e) NULL
    )
    if (length(out) == 1L && !is.na(out) && nzchar(out)) return(htmltools::HTML(out))
  }
  htmltools::htmlEscape(code)
}

# Deparse a captured expression back to readable source. A `{ ... }` block is
# unwrapped so each statement shows on its own, exactly as authored.
.shad_deparse <- function(sub) {
  one <- function(e) paste(deparse(e, width.cutoff = 500L), collapse = "\n")
  if (is.call(sub) && identical(sub[[1]], as.name("{"))) {
    paste(vapply(as.list(sub)[-1], one, character(1)), collapse = "\n")
  } else {
    one(sub)
  }
}

#' Framed live preview + source for a component demo.
#'
#' @param expr  One expression, or a `{ }` block of several, each evaluated and
#'   laid out in the preview stage.
#' @param center Center the stage contents (default) vs. stretch them.
#' @param columns Stack stage children vertically instead of wrapping in a row.
#' @param background Optional preset name to theme just this preview
#'   (e.g. "violet"); applied via `data-shad-theme`.
demo <- function(expr, center = TRUE, columns = FALSE, background = NULL) {
  sub <- substitute(expr)
  env <- parent.frame()
  code <- .shad_deparse(sub)
  ui <- if (is.call(sub) && identical(sub[[1]], as.name("{"))) {
    lapply(as.list(sub)[-1], eval, envir = env)
  } else {
    list(eval(sub, envir = env))
  }

  stage_class <- paste(c(
    "shad-demo__stage",
    if (center)  "shad-demo__stage--center",
    if (columns) "shad-demo__stage--col"
  ), collapse = " ")

  htmltools::tagList(htmltools::tags$div(
    class = "shad-demo",
    `data-shad-theme` = background,
    htmltools::tags$div(class = stage_class, ui),
    htmltools::tags$details(
      class = "shad-demo__code",
      htmltools::tags$summary("Code"),
      htmltools::tags$pre(htmltools::tags$code(
        class = "language-r", .shad_highlight(code)
      ))
    )
  ))
}

# A compact swatch used by the theming gallery.
swatch <- function(token, label = token) {
  htmltools::tags$div(
    class = "shad-swatch",
    htmltools::tags$span(
      class = "shad-swatch__chip",
      style = sprintf("background:var(%s)", token)
    ),
    htmltools::tags$code(label)
  )
}
