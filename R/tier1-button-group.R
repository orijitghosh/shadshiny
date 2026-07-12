# button-group ----------------------------------------------------------------

#' Button group
#'
#' Joins adjoining buttons into a single segmented control: inner corners
#' collapse, the shared 1px border renders once, and the hovered/focused button
#' raises so its full outline shows. Drop in ordinary [shad_button()]s (any
#' variant; `"outline"` reads best) plus optional [shad_button_group_text()]
#' label segments and [shad_button_group_separator()] hairlines.
#'
#' @param ... Buttons and group parts, and/or named HTML attributes.
#' @param orientation `"horizontal"` (default) or `"vertical"`.
#' @param aria_label Accessible label describing the group.
#' @param class Extra CSS classes.
#'
#' @returns A button-group tag.
#' @family shadshiny tier-1 components
#' @seealso [shad_button()], [shad_button_group_text()],
#'   [shad_button_group_separator()]
#' @examples
#' shad_button_group(
#'   shad_button("Left", variant = "outline"),
#'   shad_button("Center", variant = "outline"),
#'   shad_button("Right", variant = "outline"),
#'   aria_label = "Text alignment"
#' )
#' @export
shad_button_group <- function(..., orientation = c("horizontal", "vertical"),
                              aria_label = NULL, class = NULL) {
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"), "orientation")
  parts <- split_dots(...)

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-button-group", extra = class),
      role = "group",
      `data-orientation` = orientation,
      `aria-label` = aria_label
    ),
    parts$attribs,
    parts$children
  )))
}

#' @rdname shad_button_group
#' @export
shad_button_group_separator <- function(class = NULL) {
  htmltools::tags$div(
    class = shad_class("shad-button-group__separator", extra = class),
    role = "separator", `aria-hidden` = "true"
  )
}

#' @rdname shad_button_group
#' @export
shad_button_group_text <- function(..., class = NULL) {
  parts <- split_dots(...)
  do.call(htmltools::tags$span, c(
    list(class = shad_class("shad-button-group__text", extra = class)),
    parts$attribs,
    parts$children
  ))
}
