# number-stepper ---------------------------------------------------------------

#' Number input with stepper buttons
#'
#' A numeric input flanked by decrement/increment buttons (hold to repeat,
#' Shift for ×10). A bound Shiny input: `input$<inputId>` is the numeric value
#' (`NULL` while the field is empty/invalid, mirroring [shiny::numericInput()]).
#' A drop-in restyle of `numericInput()`.
#'
#' @param inputId Input id.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param value Initial value.
#' @param min,max Optional numeric bounds (`NA` = unbounded); buttons disable at
#'   the bounds.
#' @param step Increment (default 1; decimals allowed).
#' @param precision Display decimal places (default: inferred from `step`).
#' @param disabled If `TRUE`, disable the control.
#' @param width CSS width.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns A number-stepper tag, bound as a Shiny input.
#' @family shadshiny flow
#' @examples
#' shad_number_input("qty", value = 2, min = 0, max = 10)
#' shad_number_input("dose", value = 1.5, min = 0, max = 5, step = 0.25)
#' @export
shad_number_input <- function(inputId, label = NULL, value = 0, min = NA,
                              max = NA, step = 1, precision = NULL,
                              disabled = FALSE, width = NULL, class = NULL, ...) {
  value <- shiny::restoreInput(id = inputId, default = value)

  input <- htmltools::tags$input(
    class = "shad-input", type = "text", inputmode = "decimal",
    value = value, `aria-label` = label %||% "Number",
    disabled = flag_attr(disabled)
  )
  dec <- htmltools::tags$button(
    type = "button", class = "shad-number-stepper__btn shad-number-stepper__btn--dec",
    `aria-label` = "Decrease", disabled = flag_attr(disabled), .svg("minus")
  )
  inc <- htmltools::tags$button(
    type = "button", class = "shad-number-stepper__btn shad-number-stepper__btn--inc",
    `aria-label` = "Increase", disabled = flag_attr(disabled), .svg("plus")
  )

  root <- htmltools::tags$div(
    class = shad_class("shad-input-group shad-number-stepper",
                       extra = if (is.null(label)) class),
    id = inputId,
    `data-shad` = "number-stepper",
    `data-min` = if (!is.na(min)) min else NULL,
    `data-max` = if (!is.na(max)) max else NULL,
    `data-step` = step,
    `data-precision` = precision,
    `data-disabled` = flag_attr(disabled),
    style = width_style(width),
    ...,
    input, dec, inc
  )

  if (is.null(label)) return(with_deps(root))
  shad_form_field(root, label = label, class = class)
}

#' Update a number input from the server
#'
#' @param id Input id (namespaced automatically).
#' @param value Optional new value.
#' @param min,max,step Optional numeric attribute patches.
#' @param disabled Optional logical.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny flow
#' @export
update_shad_number_input <- function(id, value = NULL, min = NULL, max = NULL,
                                     step = NULL, disabled = NULL,
                                     session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(value)) shad_set_value(id, as.numeric(value), session)
  if (!is.null(min)) shad_set_attr(id, "data-min", min, session)
  if (!is.null(max)) shad_set_attr(id, "data-max", max, session)
  if (!is.null(step)) shad_set_attr(id, "data-step", step, session)
  if (!is.null(disabled)) {
    shad_invoke(id, "setDisabled", list(isTRUE(disabled)), session)
  }
  invisible(NULL)
}
