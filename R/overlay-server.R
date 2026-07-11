# Overlay server helpers -------------------------------------------------------
# Every helper is a one-line invoke of the instance's open()/close() method.
# The open state is also readable reactively as input$<id> (logical).

#' Open and close overlays from the server
#'
#' Imperatively open or close a dialog, alert dialog, sheet, drawer, or popover.
#' The open state is also available reactively as `input$<id>`.
#'
#' @param id The overlay's input id (namespaced automatically).
#' @param session The Shiny session.
#' @returns Invisibly `NULL`; called for its side effect.
#' @name shad_overlay_server
#' @family shadshiny server API
NULL

#' @rdname shad_overlay_server
#' @export
shad_dialog_open <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "open", session = session)
}
#' @rdname shad_overlay_server
#' @export
shad_dialog_close <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}

#' @rdname shad_overlay_server
#' @export
shad_alert_dialog_open <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "open", session = session)
}
#' @rdname shad_overlay_server
#' @export
shad_alert_dialog_close <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}

#' @rdname shad_overlay_server
#' @export
shad_sheet_open <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "open", session = session)
}
#' @rdname shad_overlay_server
#' @export
shad_sheet_close <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}

#' @rdname shad_overlay_server
#' @export
shad_drawer_open <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "open", session = session)
}
#' @rdname shad_overlay_server
#' @export
shad_drawer_close <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}

#' @rdname shad_overlay_server
#' @export
shad_popover_open <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "open", session = session)
}
#' @rdname shad_overlay_server
#' @export
shad_popover_close <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}

#' @rdname shad_overlay_server
#' @export
shad_sidebar_toggle <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "toggleCollapsed", session = session)
}
