# Server-side update API -------------------------------------------------------
# Thin wrappers over two custom messages. `id` is namespaced via session$ns()
# so every function is Shiny-module-safe. All take `session` last with the
# default reactive domain.

#' Send a method call to a component instance
#' @noRd
shad_invoke <- function(id, method, args = list(),
                        session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("shadshiny:invoke", list(
    id = session$ns(id), method = method, args = args
  ))
  invisible(NULL)
}

#' Set a component instance's value (calls its setValue())
#' @noRd
shad_set_value <- function(id, value,
                           session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("shadshiny:update", list(
    id = session$ns(id), value = value
  ))
  invisible(NULL)
}

#' Set an attribute on a component element
#' @noRd
shad_set_attr <- function(id, attr, value = NULL,
                          session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("shadshiny:attr", list(
    id = session$ns(id), attr = attr, value = value
  ))
  invisible(NULL)
}

#' Set text content on a component element (optionally via a selector)
#' @noRd
shad_set_text <- function(id, text, selector = NULL,
                          session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("shadshiny:text", list(
    id = session$ns(id), selector = selector, text = text
  ))
  invisible(NULL)
}

#' Replace a component's markup (or a region of it) with rendered UI
#'
#' Dependencies are registered with the session and sent alongside the HTML, so
#' the client can bind whatever the fragment contains. The receiving component's
#' `refresh()` runs afterwards, where it has one.
#' @noRd
shad_set_html <- function(id, ui, selector = NULL,
                          session = shiny::getDefaultReactiveDomain()) {
  rendered <- htmltools::renderTags(ui)
  deps <- lapply(
    htmltools::resolveDependencies(rendered$dependencies),
    shiny::createWebDependency
  )
  session$sendCustomMessage("shadshiny:html", list(
    id = session$ns(id), selector = selector,
    html = rendered$html, deps = deps
  ))
  invisible(NULL)
}

# ISO-8601 serialize a Date/character scalar (helper shared with calendar).
.iso_or_null <- function(x) if (is.null(x)) NULL else .iso_date(x)

#' Update bound component values from the server
#'
#' Each function sets the current value of a bound shadshiny input, mirroring
#' Shiny's built-in `update*Input()` helpers. Changing the available *choices*
#' of a component is a non-goal — re-render with [shiny::renderUI()] instead.
#'
#' @param id The input id (namespaced automatically).
#' @param value,selected The new value. See each component's UI constructor for
#'   its value contract.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`; called for its side effect.
#' @name update_shad
#' @family shadshiny server API
NULL

#' @rdname update_shad
#' @export
update_shad_checkbox <- function(id, value,
                                 session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, value, session)
}

#' @rdname update_shad
#' @export
update_shad_radio_group <- function(id, selected,
                                    session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, selected, session)
}

#' @rdname update_shad
#' @export
update_shad_switch <- function(id, value,
                               session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, value, session)
}

#' @rdname update_shad
#' @export
update_shad_slider <- function(id, value,
                               session = shiny::getDefaultReactiveDomain()) {
  value <- as.numeric(value)
  shad_set_value(id, if (length(value) >= 2) value else value[[1]], session)
}

#' @rdname update_shad
#' @export
update_shad_toggle <- function(id, value,
                               session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, value, session)
}

#' @rdname update_shad
#' @export
update_shad_toggle_group <- function(id, selected,
                                     session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, selected, session)
}

#' @rdname update_shad
#' @export
update_shad_select <- function(id, selected,
                               session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, selected, session)
}

#' @rdname update_shad
#' @param multiple For [update_shad_combobox()], whether the combobox is in
#'   multiple mode (forces an array even for a single value).
#' @export
update_shad_combobox <- function(id, selected, multiple = FALSE,
                                 session = shiny::getDefaultReactiveDomain()) {
  if (isTRUE(multiple)) selected <- I(as.character(selected))
  shad_set_value(id, selected, session)
}

#' @rdname update_shad
#' @export
update_shad_input_otp <- function(id, value,
                                  session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, value, session)
}

#' @rdname update_shad
#' @export
update_shad_native_select <- function(id, selected,
                                       session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, as.character(selected), session)
}

#' @rdname update_shad
#' @export
update_shad_calendar <- function(id, value,
                                 session = shiny::getDefaultReactiveDomain()) {
  val <- if (length(value) >= 2) {
    list(start = .iso_date(value[[1]]), end = .iso_date(value[[2]]))
  } else {
    .iso_or_null(value)
  }
  shad_set_value(id, val, session)
}

#' @rdname update_shad
#' @export
update_shad_date_picker <- function(id, value,
                                    session = shiny::getDefaultReactiveDomain()) {
  update_shad_calendar(id, value, session)
}

#' @rdname update_shad
#' @export
update_shad_tabs <- function(id, selected,
                             session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, selected, session)
}

#' @rdname update_shad
#' @export
update_shad_accordion <- function(id, value,
                                  session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, value, session)
}

#' @rdname update_shad
#' @export
update_shad_pagination <- function(id, selected,
                                   session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, as.integer(selected), session)
}

#' @rdname update_shad
#' @export
update_shad_carousel <- function(id, selected,
                                 session = shiny::getDefaultReactiveDomain()) {
  shad_set_value(id, as.integer(selected), session)
}

#' @rdname update_shad
#' @param collapsed,mobile_open For [update_shad_sidebar()]; `NULL` leaves that
#'   facet unchanged.
#' @export
update_shad_sidebar <- function(id, collapsed = NULL, mobile_open = NULL,
                                session = shiny::getDefaultReactiveDomain()) {
  val <- drop_nulls(list(collapsed = collapsed, mobileOpen = mobile_open))
  shad_set_value(id, val, session)
}

#' @rdname update_shad
#' @param max For [update_shad_progress()], the maximum value.
#' @export
update_shad_progress <- function(id, value, max = 100,
                                 session = shiny::getDefaultReactiveDomain()) {
  pct <- max(0, min(100, 100 * value / max))
  state <- if (pct >= 100) "complete" else "loading"
  session$sendCustomMessage("shadshiny:style", list(
    id = session$ns(id), selector = ".shad-progress__indicator",
    prop = "transform", value = sprintf("translateX(-%s%%)", format(100 - pct, digits = 6))
  ))
  shad_set_attr(id, "aria-valuenow", as.character(value), session)
  shad_set_attr(id, "data-state", state, session)
  invisible(NULL)
}

#' @rdname update_shad
#' @param loading,disabled,label For [update_shad_button()]; `NULL` leaves that
#'   facet unchanged.
#' @export
update_shad_button <- function(id, loading = NULL, disabled = NULL, label = NULL,
                               session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(loading)) {
    shad_set_attr(id, "data-loading", if (isTRUE(loading)) TRUE else NULL, session)
    shad_set_attr(id, "aria-busy", if (isTRUE(loading)) "true" else NULL, session)
    shad_set_attr(id, "disabled", if (isTRUE(loading)) TRUE else NULL, session)
  }
  if (!is.null(disabled)) {
    shad_set_attr(id, "disabled", if (isTRUE(disabled)) TRUE else FALSE, session)
  }
  if (!is.null(label)) shad_set_text(id, label, selector = NULL, session)
  invisible(NULL)
}
