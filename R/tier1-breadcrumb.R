#' Breadcrumb
#'
#' A breadcrumb navigation trail. Compose with [shad_breadcrumb_item()],
#' [shad_breadcrumb_separator()] and [shad_breadcrumb_ellipsis()], or pass a
#' named `items` vector for the common case.
#'
#' @param ... Breadcrumb parts. Ignored when `items` is supplied.
#' @param items Optional named character vector: names are labels, values are
#'   hrefs. Use `NA` as the href to mark the current page. Separators are
#'   inserted automatically.
#' @param class Extra CSS classes.
#' @returns A `<nav class="shad-breadcrumb">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_breadcrumb(items = c(Home = "/", Docs = "/docs", Breadcrumb = NA))
#' @export
shad_breadcrumb <- function(..., items = NULL, class = NULL) {
  if (!is.null(items)) {
    labs <- names(items)
    parts <- list()
    for (i in seq_along(items)) {
      href <- items[[i]]
      current <- is.na(href)
      parts[[length(parts) + 1]] <- shad_breadcrumb_item(
        labs[i], href = if (current) NULL else href, current = current
      )
      if (i < length(items)) parts[[length(parts) + 1]] <- shad_breadcrumb_separator()
    }
    list_children <- parts
  } else {
    list_children <- list(...)
  }
  with_deps(htmltools::tags$nav(
    class = shad_class("shad-breadcrumb", extra = class), `aria-label` = "Breadcrumb",
    do.call(htmltools::tags$ol, c(list(class = "shad-breadcrumb__list"), list_children))
  ))
}

#' @rdname shad_breadcrumb
#' @param label Item label.
#' @param href Link URL; omit for a non-link item.
#' @param current If `TRUE`, renders the current-page item (non-link).
#' @export
shad_breadcrumb_item <- function(label, href = NULL, current = FALSE) {
  inner <- if (isTRUE(current)) {
    htmltools::tags$span(
      class = "shad-breadcrumb__page", role = "link",
      `aria-disabled` = "true", `aria-current` = "page", label
    )
  } else if (!is.null(href)) {
    htmltools::tags$a(class = "shad-breadcrumb__link", href = href, label)
  } else {
    htmltools::tags$span(class = "shad-breadcrumb__link", label)
  }
  htmltools::tags$li(class = "shad-breadcrumb__item", inner)
}

#' @rdname shad_breadcrumb
#' @export
shad_breadcrumb_separator <- function() {
  htmltools::tags$li(
    class = "shad-breadcrumb__separator", role = "presentation", `aria-hidden` = "true",
    shad_icon("chevron-right")
  )
}

#' @rdname shad_breadcrumb
#' @export
shad_breadcrumb_ellipsis <- function() {
  htmltools::tags$li(
    class = "shad-breadcrumb__item",
    htmltools::tags$span(
      class = "shad-breadcrumb__ellipsis", role = "presentation", `aria-hidden` = "true",
      shad_icon("more-horizontal"),
      htmltools::tags$span(class = "shad-sr-only", "More pages")
    )
  )
}
