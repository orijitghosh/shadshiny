# timeline ---------------------------------------------------------------------

#' Timeline
#'
#' A vertical timeline of dated events (dot + connector + content). Compose from
#' [shad_timeline_item()] children.
#'
#' @param ... [shad_timeline_item()] entries, plus optional named attributes.
#' @param align `"left"` (default) or `"alternate"` (two-column, items alternate
#'   sides of a center spine).
#' @param class Extra CSS classes.
#' @returns A timeline `<ol>` tag.
#' @family shadshiny dashboard
#' @examples
#' shad_timeline(
#'   shad_timeline_item("Order placed", time = "Jul 10", status = "active"),
#'   shad_timeline_item("Shipped", time = "Jul 12")
#' )
#' @export
shad_timeline <- function(..., align = c("left", "alternate"), class = NULL) {
  align <- arg_match_shad(align, c("left", "alternate"), "align")
  dots <- split_dots(...)
  root <- do.call(htmltools::tags$ol, c(
    list(class = shad_class("shad-timeline",
                            if (align == "alternate") "shad-timeline--alternate",
                            extra = class)),
    dots$attribs,
    dots$children
  ))
  with_deps(root)
}

#' Timeline item
#'
#' @param title The item title (string or tags).
#' @param ... Additional content appended after the description.
#' @param time Optional timestamp (rendered in a `<time>` element).
#' @param description Optional description line.
#' @param icon Optional icon inside the dot: a [shad_icon()] name or a tag. When
#'   omitted the dot is a small filled circle.
#' @param status `"default"`, `"active"` (primary-filled dot), or `"muted"`.
#' @param last If `TRUE`, omit the trailing connector (auto for the final child;
#'   set explicitly if composing dynamically).
#' @param class Extra CSS classes.
#' @returns A timeline item `<li>` tag.
#' @family shadshiny dashboard
#' @export
shad_timeline_item <- function(title, ..., time = NULL, description = NULL,
                               icon = NULL, status = c("default", "active", "muted"),
                               last = FALSE, class = NULL) {
  status <- arg_match_shad(status, c("default", "active", "muted"), "status")
  dot <- htmltools::tags$span(class = "shad-timeline__dot", .resolve_icon(icon))
  connector <- if (!isTRUE(last)) {
    htmltools::tags$span(class = "shad-timeline__connector", `aria-hidden` = "true")
  }
  content <- drop_nulls(list(
    if (!is.null(time)) htmltools::tags$time(class = "shad-timeline__time", time),
    htmltools::tags$div(class = "shad-timeline__title", title),
    if (!is.null(description)) {
      htmltools::tags$div(class = "shad-timeline__description", description)
    }
  ))
  htmltools::tags$li(
    class = shad_class("shad-timeline__item", extra = class),
    `data-state` = if (status != "default") status else NULL,
    htmltools::tags$span(class = "shad-timeline__marker", dot, connector),
    do.call(htmltools::tags$div, c(list(class = "shad-timeline__content"),
                                   content, split_dots(...)$children))
  )
}
