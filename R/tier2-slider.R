# slider -----------------------------------------------------------------------

#' Slider
#'
#' A shadcn slider. A length-1 `value` renders a single thumb (numeric
#' `input$<inputId>`); a length-2 `value` renders a range (numeric length-2).
#' The binding debounces at 250 ms.
#'
#' @param inputId Input id.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param min,max,step Numeric domain (defaults 0 / 100 / 1).
#' @param value Initial value: length 1 (single) or length 2 (range).
#' @param marks Optional numeric vector of tick positions. If named
#'   (`c("Low" = 0, "High" = 100)`), tick labels are shown.
#' @param orientation `"horizontal"` (default) or `"vertical"`.
#' @param disabled If `TRUE`, disables the control.
#' @param width CSS width.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the slider root.
#' @returns A slider tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_slider("volume", value = 50)
#' shad_slider("price", min = 0, max = 100, value = c(25, 75), step = 5)
#' @export
shad_slider <- function(inputId, label = NULL, min = 0, max = 100, value = min,
                        step = 1, marks = NULL,
                        orientation = c("horizontal", "vertical"),
                        disabled = FALSE, width = NULL, class = NULL, ...) {
  value <- shiny::restoreInput(id = inputId, default = value)
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"),
                                "orientation")
  value <- as.numeric(value)
  is_range <- length(value) >= 2

  marks_attr <- NULL
  marks_labels <- NULL
  if (!is.null(marks)) {
    marks_attr <- paste(as.numeric(marks), collapse = ",")
    marks_labels <- flag_attr(!is.null(names(marks)))
  }

  thumbs <- if (is_range) {
    list(
      htmltools::tags$div(class = "shad-slider__thumb", role = "slider",
                          tabindex = if (isTRUE(disabled)) "-1" else "0",
                          `aria-label` = "Minimum"),
      htmltools::tags$div(class = "shad-slider__thumb", role = "slider",
                          tabindex = if (isTRUE(disabled)) "-1" else "0",
                          `aria-label` = "Maximum")
    )
  } else {
    list(htmltools::tags$div(class = "shad-slider__thumb", role = "slider",
                             tabindex = if (isTRUE(disabled)) "-1" else "0",
                             `aria-label` = "Value"))
  }

  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-slider", extra = if (is.null(label)) class),
      `data-shad` = "slider",
      id = inputId,
      `data-min` = min, `data-max` = max, `data-step` = step,
      `data-value` = value[[1]],
      `data-value2` = if (is_range) value[[2]] else NULL,
      `data-marks` = marks_attr,
      `data-marks-labels` = marks_labels,
      `data-orientation` = if (orientation == "vertical") "vertical" else NULL,
      `data-disabled` = flag_attr(disabled),
      style = width_style(width),
      ...
    ),
    list(htmltools::tags$div(
      class = "shad-slider__track",
      htmltools::tags$div(class = "shad-slider__range")
    )),
    thumbs
  ))

  if (is.null(label)) return(with_deps(root))
  shad_form_field(root, label = label, class = class)
}
