# sidebar ----------------------------------------------------------------------

#' Sidebar layout
#'
#' A collapsible application sidebar with a main content area.
#' `input$<inputId>` is a list `list(collapsed=, mobileOpen=, active=)`. Toggle
#' with the ⌘/Ctrl+B shortcut, a [shad_sidebar_trigger()], or
#' [shad_sidebar_toggle()].
#'
#' @param inputId Input id.
#' @param sidebar A [shad_sidebar()].
#' @param main The main content.
#' @param class Extra CSS classes.
#' @returns A sidebar-layout tag.
#' @family shadshiny tier-3 components
#' @seealso [shad_sidebar_toggle()], [update_shad_sidebar()]
#' @examples
#' shad_sidebar_layout("sb",
#'   sidebar = shad_sidebar(
#'     shad_sidebar_group("Platform",
#'       shad_sidebar_item("home", "Home", active = TRUE))),
#'   main = htmltools::div(shad_sidebar_trigger(), "Dashboard"))
#' @export
shad_sidebar_layout <- function(inputId, sidebar, main, class = NULL) {
  with_deps(htmltools::tags$div(
    class = shad_class("shad-sidebar-layout", extra = class),
    `data-shad` = "sidebar", id = inputId,
    htmltools::tags$div(class = "shad-sidebar__overlay", hidden = NA),
    sidebar,
    htmltools::tags$main(class = "shad-sidebar-layout__main", main)
  ))
}

#' @rdname shad_sidebar_layout
#' @param ... Sidebar body content (typically [shad_sidebar_group()]s).
#' @param header,footer Optional header/footer content.
#' @param collapsed If `TRUE`, start collapsed.
#' @export
shad_sidebar <- function(..., header = NULL, footer = NULL, collapsed = FALSE) {
  htmltools::tags$aside(
    class = "shad-sidebar", `aria-label` = "Sidebar",
    `data-state` = if (isTRUE(collapsed)) "collapsed" else NULL,
    if (!is.null(header)) htmltools::tags$div(class = "shad-sidebar__header", header),
    htmltools::tags$div(class = "shad-sidebar__content", ...),
    if (!is.null(footer)) htmltools::tags$div(class = "shad-sidebar__footer", footer)
  )
}

#' @rdname shad_sidebar_layout
#' @param label Optional group label.
#' @export
shad_sidebar_group <- function(label = NULL, ...) {
  htmltools::tags$div(
    class = "shad-sidebar__group",
    if (!is.null(label)) htmltools::tags$div(class = "shad-sidebar__group-label", label),
    do.call(htmltools::tags$ul, c(list(class = "shad-sidebar__menu"), list(...)))
  )
}

#' @rdname shad_sidebar_layout
#' @param value Item value (reported as `active` when clicked).
#' @param icon Optional leading icon.
#' @param badge Optional trailing badge content.
#' @param href Optional link; renders an `<a>` instead of a `<button>`.
#' @param active If `TRUE`, marks the item active.
#' @export
shad_sidebar_item <- function(value, label, icon = NULL, badge = NULL,
                              href = NULL, active = FALSE) {
  inner <- drop_nulls(list(
    resolve_icon(icon),
    htmltools::tags$span(class = "shad-sidebar__label", label),
    if (!is.null(badge)) htmltools::tags$span(class = "shad-sidebar__badge", badge)
  ))
  control <- if (!is.null(href)) {
    do.call(htmltools::tags$a, c(
      list(class = "shad-sidebar__item", href = href, `data-value` = value,
           `data-state` = if (isTRUE(active)) "active" else NULL),
      inner
    ))
  } else {
    do.call(htmltools::tags$button, c(
      list(type = "button", class = "shad-sidebar__item", `data-value` = value,
           `data-state` = if (isTRUE(active)) "active" else NULL),
      inner
    ))
  }
  htmltools::tags$li(control)
}

#' @rdname shad_sidebar_layout
#' @export
shad_sidebar_trigger <- function(class = NULL) {
  htmltools::tags$button(
    type = "button", class = shad_class("shad-sidebar__trigger", extra = class),
    `aria-label` = "Toggle sidebar",
    shad_icon("panel-left")
  )
}
