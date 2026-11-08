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

#' Keyboard shortcut group
#'
#' Render keyboard keys with an accessible group wrapper and visual separators.
#'
#' @param ... Keyboard key tags, content, and optional attributes.
#' @param separator One scalar character separator placed between keys.
#' @param class Extra CSS classes.
#' @returns An htmltools tag.
#' @family shadshiny tier-1 components
#' @examples
#' shad_kbd_group(shad_kbd("Ctrl"), shad_kbd("Shift"), shad_kbd("P"))
#' @export
shad_kbd_group <- function(..., separator = "+", class = NULL) {
  separator <- .shad_scalar_character(separator, "separator")
  parts <- split_dots(...)
  children <- parts$children
  children <- children[!vapply(children, is.null, logical(1))]
  content <- list()
  if (length(children)) {
    for (i in seq_along(children)) {
      if (i > 1L) {
        content[[length(content) + 1L]] <- do.call(htmltools::tags$span, c(
          list(class = "shad-kbd-group__separator"),
          stats::setNames(list("true"), "aria-hidden"),
          list(separator)
        ))
      }
      content[[length(content) + 1L]] <- children[[i]]
    }
  }
  with_deps(do.call(htmltools::tags$div, c(
    list(class = shad_class("shad-kbd-group", extra = class), role = "group"),
    parts$attribs,
    content
  )))
}

#' Code block
#'
#' Render escaped source text with optional metadata, copy controls, and line numbers.
#'
#' @param code One scalar character value containing source text.
#' @param language Optional scalar character language label.
#' @param filename Optional scalar character filename label.
#' @param copy One scalar logical indicating whether to show the copy button.
#' @param line_numbers One scalar logical indicating whether to show line numbers.
#' @param class Extra CSS classes.
#' @returns An htmltools figure tag.
#' @family shadshiny tier-1 components
#' @examples
#' shad_code_block("fit <- lm(mpg ~ wt, data = mtcars)",
#'                 language = "r", filename = "model.R")
#' @export
shad_code_block <- function(code, language = NULL, filename = NULL, copy = TRUE,
                            line_numbers = FALSE, class = NULL) {
  code <- .shad_scalar_character(code, "code")
  language <- .shad_scalar_character(language, "language", allow_null = TRUE)
  filename <- .shad_scalar_character(filename, "filename", allow_null = TRUE)
  copy <- .shad_scalar_logical(copy, "copy")
  line_numbers <- .shad_scalar_logical(line_numbers, "line_numbers")

  header_content <- list(
    htmltools::tags$span(
      class = "shad-code-block__title",
      if (is.null(filename)) "Code" else filename
    ),
    if (!is.null(language)) htmltools::tags$span(
      class = "shad-code-block__language", language
    ),
    if (isTRUE(copy)) do.call(htmltools::tags$span, list(
      class = "shad-code-block__controls",
      do.call(htmltools::tags$button, c(
        list(type = "button", class = "shad-code-block__copy"),
        stats::setNames(list("Copy code"), "aria-label"),
        stats::setNames(list(NA), "data-shad-copy-code"),
        list("Copy")
      )),
      do.call(htmltools::tags$span, c(
        list(class = "shad-code-block__status", role = "status"),
        stats::setNames(list("polite"), "aria-live"),
        stats::setNames(list("true"), "aria-atomic"),
        stats::setNames(list(NA), "data-shad-copy-status")
      ))
    ))
  )
  header <- do.call(htmltools::tags$figcaption, c(
    list(class = "shad-code-block__header"),
    drop_nulls(header_content)
  ))

  gutter <- if (isTRUE(line_numbers)) {
    n_lines <- length(strsplit(code, "\n", fixed = TRUE)[[1L]])
    do.call(htmltools::tags$span, c(
      list(class = "shad-code-block__gutter"),
      stats::setNames(list("true"), "aria-hidden"),
      list(paste(seq_len(n_lines), collapse = "\n"))
    ))
  }
  code_attrs <- if (is.null(language)) list() else stats::setNames(list(language), "data-language")
  code_tag <- do.call(htmltools::tags$code, c(
    list(class = "shad-code-block__code"),
    code_attrs,
    list(code)
  ))
  pre <- do.call(htmltools::tags$pre, c(
    list(class = "shad-code-block__pre"),
    drop_nulls(list(gutter, code_tag))
  ))

  with_deps(do.call(htmltools::tags$figure, c(
    list(class = shad_class("shad-code-block", extra = class)),
    stats::setNames(list(NA), "data-shad-code-block"),
    list(header, pre)
  )))
}
#' @rdname shad_typography
#' @param ordered If `TRUE`, renders an `<ol>` instead of `<ul>`.
#' @export
shad_list <- function(..., ordered = FALSE, class = NULL) {
  tag <- if (isTRUE(ordered)) htmltools::tags$ol else htmltools::tags$ul
  with_deps(tag(class = shad_class("shad-list", extra = class), ...))
}
