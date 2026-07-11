# Typography helpers ----------------------------------------------------------
# Utility classes live in core/shad-base.css (.shad-h1..h4/p/lead/large/small/
# muted/blockquote/code/kbd/list). These thin wrappers apply them to the right
# semantic element.

#' Typography helpers
#'
#' Apply shadshiny's typography utility classes to the appropriate semantic
#' element.
#'
#' @param ... Content (and optional named attributes).
#' @param class Extra CSS classes.
#' @returns An htmltools tag.
#' @name shad_typography
#' @family shadshiny tier-1 components
#' @examples
#' shad_h1("Title")
#' shad_p("A paragraph.")
#' shad_muted("Secondary text")
NULL

#' @rdname shad_typography
#' @export
shad_h1 <- function(..., class = NULL) with_deps(htmltools::tags$h1(class = shad_class("shad-h1", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_h2 <- function(..., class = NULL) with_deps(htmltools::tags$h2(class = shad_class("shad-h2", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_h3 <- function(..., class = NULL) with_deps(htmltools::tags$h3(class = shad_class("shad-h3", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_h4 <- function(..., class = NULL) with_deps(htmltools::tags$h4(class = shad_class("shad-h4", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_p <- function(..., class = NULL) with_deps(htmltools::tags$p(class = shad_class("shad-p", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_lead <- function(..., class = NULL) with_deps(htmltools::tags$p(class = shad_class("shad-lead", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_large <- function(..., class = NULL) with_deps(htmltools::tags$div(class = shad_class("shad-large", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_small <- function(..., class = NULL) with_deps(htmltools::tags$small(class = shad_class("shad-small", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_muted <- function(..., class = NULL) with_deps(htmltools::tags$p(class = shad_class("shad-muted", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_blockquote <- function(..., class = NULL) with_deps(htmltools::tags$blockquote(class = shad_class("shad-blockquote", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_code <- function(..., class = NULL) with_deps(htmltools::tags$code(class = shad_class("shad-code", extra = class), ...))

#' @rdname shad_typography
#' @export
shad_kbd <- function(..., class = NULL) with_deps(htmltools::tags$kbd(class = shad_class("shad-kbd", extra = class), ...))

#' @rdname shad_typography
#' @param ordered If `TRUE`, renders an `<ol>` instead of `<ul>`.
#' @export
shad_list <- function(..., ordered = FALSE, class = NULL) {
  tag <- if (isTRUE(ordered)) htmltools::tags$ol else htmltools::tags$ul
  with_deps(tag(class = shad_class("shad-list", extra = class), ...))
}
