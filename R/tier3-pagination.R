# pagination -------------------------------------------------------------------

#' Pagination
#'
#' A windowed pager. The item list (first / last / current ±1 / ellipses) is
#' rendered client-side from the seed attributes. `input$<inputId>` is the
#' current page number.
#'
#' @param inputId Input id.
#' @param pages Total number of pages.
#' @param selected Initial current page (1-based).
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the `<nav>`.
#' @returns A pagination tag.
#' @family shadshiny tier-3 components
#' @seealso [update_shad_pagination()]
#' @examples
#' shad_pagination("pg", pages = 10, selected = 2)
#' @export
shad_pagination <- function(inputId, pages, selected = 1, class = NULL, ...) {
  selected <- shiny::restoreInput(id = inputId, default = selected)
  with_deps(htmltools::tags$nav(
    class = shad_class("shad-pagination", extra = class),
    `data-shad` = "pagination", id = inputId,
    `data-pages` = as.integer(pages), `data-page` = as.integer(selected),
    ...,
    htmltools::tags$ul(class = "shad-pagination__list")
  ))
}
