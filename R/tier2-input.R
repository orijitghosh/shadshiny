# Native text inputs -----------------------------------------------------------
# input/textarea use Shiny's built-in text bindings (no data-shad binding), so
# updateTextInput()/updateTextAreaInput() work out of the box. When label or
# description is supplied we wrap in the form-field anatomy for free aria wiring.

#' Text input
#'
#' A shadcn-styled `<input>`. Bound by Shiny's native text-input binding, so
#' `input$<inputId>` reflects the value and [shiny::updateTextInput()] works.
#'
#' @param inputId Input id.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param value Initial value.
#' @param placeholder Placeholder text.
#' @param type Input `type` attribute (`"text"`, `"email"`, `"password"`, ...).
#' @param invalid If `TRUE`, sets `aria-invalid="true"` (destructive border).
#' @param disabled If `TRUE`, disables the input.
#' @param description Optional help text (wraps in [shad_form_field()]).
#' @param width CSS width.
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns An `<input>` tag, optionally wrapped in a form field.
#' @family shadshiny tier-2 components
#' @examples
#' shad_input("email", type = "email", placeholder = "you@example.com")
#' shad_input("user", label = "Username", value = "shadcn")
#' @export
shad_input <- function(inputId, label = NULL, value = "", placeholder = NULL,
                       type = "text", invalid = FALSE, disabled = FALSE,
                       description = NULL, width = NULL, class = NULL, ...) {
  wrapped <- !is.null(label) || !is.null(description)
  input_tag <- htmltools::tags$input(
    id = inputId,
    class = shad_class("shad-input", extra = if (!wrapped) class),
    type = type,
    value = if (!is.null(value) && !identical(value, "")) value else NULL,
    placeholder = placeholder,
    `aria-invalid` = if (isTRUE(invalid)) "true" else NULL,
    disabled = flag_attr(disabled),
    style = if (!wrapped) width_style(width) else NULL,
    ...
  )
  if (!wrapped) return(with_deps(input_tag))
  shad_form_field(input_tag, label = label, description = description,
                  class = class)
}

#' Textarea
#'
#' A shadcn-styled multi-line `<textarea>`. Bound by Shiny's native binding;
#' [shiny::updateTextAreaInput()] works. `autosize = TRUE` grows the control to
#' fit its content (behavior handled by the bundled JS).
#'
#' @inheritParams shad_input
#' @param rows Initial visible rows.
#' @param autosize If `TRUE`, the textarea grows with its content.
#' @returns A `<textarea>` tag, optionally wrapped in a form field.
#' @family shadshiny tier-2 components
#' @examples
#' shad_textarea("bio", label = "Bio", placeholder = "Tell us about yourself")
#' shad_textarea("msg", autosize = TRUE)
#' @export
shad_textarea <- function(inputId, label = NULL, value = "", placeholder = NULL,
                          rows = 3, autosize = FALSE, invalid = FALSE,
                          disabled = FALSE, description = NULL, width = NULL,
                          class = NULL, ...) {
  wrapped <- !is.null(label) || !is.null(description)
  ta <- htmltools::tags$textarea(
    id = inputId,
    class = shad_class("shad-textarea", extra = if (!wrapped) class),
    placeholder = placeholder,
    rows = rows,
    `data-shad` = if (isTRUE(autosize)) "textarea" else NULL,
    `data-autosize` = flag_attr(autosize),
    `aria-invalid` = if (isTRUE(invalid)) "true" else NULL,
    disabled = flag_attr(disabled),
    style = if (!wrapped) width_style(width) else NULL,
    ...,
    value
  )
  if (!wrapped) return(with_deps(ta))
  shad_form_field(ta, label = label, description = description, class = class)
}
