# input-group ------------------------------------------------------------------

#' Input group
#'
#' A bordered shell that wraps a [shad_input()] or [shad_textarea()] together
#' with leading/trailing addons (icons, prefixes, buttons) or block toolbars.
#' The shell owns the border, shadow, and focus/invalid ring; the wrapped
#' control drops its own chrome so the group reads as one field. The control
#' keeps its native Shiny binding — read it with `input$<inputId>` as usual.
#'
#' @param ... Addons ([shad_input_group_addon()]) and the wrapped control, in
#'   render order, and/or named HTML attributes.
#' @param block If `TRUE`, stretch to full width (default is content width).
#' @param invalid If `TRUE`, paint the destructive border/ring (mirror the
#'   wrapped control's `invalid`).
#' @param class Extra CSS classes.
#'
#' @returns An input-group tag.
#' @family shadshiny tier-2 components
#' @seealso [shad_input()], [shad_textarea()], [shad_input_group_addon()]
#' @examples
#' shad_input_group(
#'   shad_input_group_addon(shad_icon("search"), align = "inline-start"),
#'   shad_input("q", placeholder = "Search..."),
#'   block = TRUE
#' )
#' @export
shad_input_group <- function(..., block = FALSE, invalid = FALSE, class = NULL) {
  parts <- split_dots(...)

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-input-group",
                         if (isTRUE(block)) "shad-input-group--block" else NULL,
                         extra = class),
      role = "group",
      `data-invalid` = flag_attr(invalid)
    ),
    parts$attribs,
    parts$children
  )))
}

#' @rdname shad_input_group
#' @param align Addon placement: `"inline-start"`, `"inline-end"`,
#'   `"block-start"`, or `"block-end"`. Block addons take their own full-width
#'   row (toolbar strips).
#' @export
shad_input_group_addon <- function(..., align = c("inline-start", "inline-end",
                                                  "block-start", "block-end"),
                                   class = NULL) {
  align <- arg_match_shad(align, c("inline-start", "inline-end",
                                   "block-start", "block-end"), "align")
  parts <- split_dots(...)
  do.call(htmltools::tags$span, c(
    list(
      class = shad_class("shad-input-group__addon", extra = class),
      `data-align` = align
    ),
    parts$attribs,
    parts$children
  ))
}

#' @rdname shad_input_group
#' @export
shad_input_group_text <- function(..., class = NULL) {
  parts <- split_dots(...)
  do.call(htmltools::tags$span, c(
    list(class = shad_class("shad-input-group__text", extra = class)),
    parts$attribs,
    parts$children
  ))
}

#' @rdname shad_input_group
#' @param label Button label (first positional, for convenience).
#' @param variant Button variant (defaults to `"ghost"` to sit quietly in the
#'   field).
#' @export
shad_input_group_button <- function(label = NULL, ..., variant = "ghost",
                                    class = NULL) {
  shad_button(
    label = label, variant = variant, size = "sm",
    class = shad_class("shad-input-group__button", extra = class), ...
  )
}
