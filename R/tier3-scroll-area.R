# scroll-area & resizable ------------------------------------------------------

.shad_resizable_grip <- htmltools::HTML(paste0(
  '<span class="shad-resizable__grip" aria-hidden="true">',
  '<svg width="6" height="10" viewBox="0 0 6 10" fill="currentColor" ',
  'aria-hidden="true"><circle cx="1.5" cy="2" r="1"/><circle cx="4.5" cy="2" r="1"/>',
  '<circle cx="1.5" cy="5" r="1"/><circle cx="4.5" cy="5" r="1"/>',
  '<circle cx="1.5" cy="8" r="1"/><circle cx="4.5" cy="8" r="1"/></svg></span>'
))

#' Scroll area
#'
#' A container with styled overlay scrollbars. Not a Shiny input.
#'
#' @param ... Scrollable content.
#' @param height Optional CSS height for the area.
#' @param orientation `"vertical"` (default), `"horizontal"`, or `"both"`.
#' @param class Extra CSS classes.
#' @returns A scroll-area tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_scroll_area(height = "12rem", "Lots of content...")
#' @export
shad_scroll_area <- function(..., height = NULL,
                             orientation = c("vertical", "horizontal", "both"),
                             class = NULL) {
  orientation <- arg_match_shad(orientation, c("vertical", "horizontal", "both"),
                                "orientation")
  bars <- list()
  if (orientation %in% c("vertical", "both")) {
    bars <- c(bars, list(htmltools::tags$div(
      class = "shad-scroll-area__scrollbar", `data-orientation` = "vertical",
      htmltools::tags$div(class = "shad-scroll-area__thumb")
    )))
  }
  if (orientation %in% c("horizontal", "both")) {
    bars <- c(bars, list(htmltools::tags$div(
      class = "shad-scroll-area__scrollbar", `data-orientation` = "horizontal",
      htmltools::tags$div(class = "shad-scroll-area__thumb")
    )))
  }
  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-scroll-area", extra = class),
      `data-shad` = "scroll-area",
      style = if (!is.null(height)) paste0("height:", htmltools::validateCssUnit(height), ";")
    ),
    list(htmltools::tags$div(class = "shad-scroll-area__viewport", ...)),
    bars
  )))
}

#' Resizable panel group
#'
#' Draggable, resizable panels. When `inputId` is set, `input$<inputId>` is a
#' numeric vector of panel sizes (fired on drag release).
#'
#' @param inputId Optional input id (binds panel sizes when set).
#' @param ... [shad_resizable_panel()] and [shad_resizable_handle()] children.
#' @param orientation `"horizontal"` (default) or `"vertical"`.
#' @param class Extra CSS classes.
#' @returns A resizable group tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_resizable("r",
#'   shad_resizable_panel("One", default_size = 50),
#'   shad_resizable_handle(),
#'   shad_resizable_panel("Two", default_size = 50))
#' @export
shad_resizable <- function(inputId = NULL, ...,
                           orientation = c("horizontal", "vertical"),
                           class = NULL) {
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"),
                                "orientation")
  with_deps(htmltools::tags$div(
    class = shad_class("shad-resizable", extra = class),
    `data-shad` = "resizable", id = inputId, `data-orientation` = orientation,
    ...
  ))
}

#' @rdname shad_resizable
#' @param default_size Initial size (percentage 0-100).
#' @param min_size,max_size Optional size bounds (percentage).
#' @export
shad_resizable_panel <- function(..., default_size = NULL, min_size = NULL,
                                 max_size = NULL) {
  htmltools::tags$div(
    class = "shad-resizable__panel",
    `data-size` = if (!is.null(default_size)) default_size else NULL,
    `data-min` = if (!is.null(min_size)) min_size else NULL,
    `data-max` = if (!is.null(max_size)) max_size else NULL,
    ...
  )
}

#' @rdname shad_resizable
#' @param with_handle If `TRUE`, render the visible grip.
#' @export
shad_resizable_handle <- function(with_handle = TRUE) {
  htmltools::tags$div(
    class = "shad-resizable__handle",
    if (isTRUE(with_handle)) .shad_resizable_grip
  )
}
