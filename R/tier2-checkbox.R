# checkbox ---------------------------------------------------------------------

.shad_checkbox_indicators <- htmltools::HTML(paste0(
  '<svg class="shad-checkbox__indicator shad-checkbox__indicator--check" ',
  'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" ',
  'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">',
  '<path pathLength="1" d="M20 6 9 17l-5-5"/></svg>',
  '<svg class="shad-checkbox__indicator shad-checkbox__indicator--minus" ',
  'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" ',
  'stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg>'
))

#' Checkbox
#'
#' A shadcn checkbox. `input$<inputId>` is `TRUE`, `FALSE`, or
#' `"indeterminate"`.
#'
#' @param inputId Input id.
#' @param label Optional label shown next to the box.
#' @param value Initial value: `TRUE`, `FALSE`, or `"indeterminate"`.
#' @param indeterminate If `TRUE`, seeds the indeterminate (mixed) state.
#' @param disabled If `TRUE`, disables the control.
#' @param description Optional help text below the row.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the checkbox button.
#' @returns A checkbox row tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_checkbox("terms", "Accept terms and conditions")
#' shad_checkbox("all", "Select all", indeterminate = TRUE)
#' @export
shad_checkbox <- function(inputId, label = NULL, value = FALSE,
                          indeterminate = FALSE, disabled = FALSE,
                          description = NULL, class = NULL, ...) {
  if (identical(value, "indeterminate")) indeterminate <- TRUE
  state <- if (isTRUE(indeterminate)) {
    "indeterminate"
  } else if (isTRUE(value)) {
    "checked"
  } else {
    "unchecked"
  }
  label_id <- paste0(inputId, "-label")

  box <- htmltools::tags$button(
    type = "button",
    class = "shad-checkbox",
    `data-shad` = "checkbox",
    `data-state` = state,
    id = inputId,
    `aria-labelledby` = if (!is.null(label)) label_id else NULL,
    `data-disabled` = flag_attr(disabled),
    disabled = flag_attr(disabled),
    ...,
    .shad_checkbox_indicators
  )
  label_tag <- if (!is.null(label)) {
    htmltools::tags$label(
      class = "shad-label", id = label_id, `for` = inputId,
      `data-disabled` = flag_attr(disabled), label
    )
  }
  row <- htmltools::tags$div(
    class = shad_class("shad-checkbox-row", extra = if (is.null(description)) class),
    box, label_tag
  )
  if (is.null(description)) return(with_deps(row))
  shad_form_field(row, description = description, class = class)
}
