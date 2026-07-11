#' Form field wrapper
#'
#' Wraps a control with a label, help description, and error slot, matching the
#' shadcn form-field anatomy. The bundled JS wires `aria-describedby` from the
#' description/error elements to the contained control on init. Most Tier 2
#' constructors reuse this internally when given `label`/`description`.
#'
#' @param ... The control(s) to wrap, plus optional named attributes.
#' @param label Optional field label text.
#' @param description Optional help text shown below the control.
#' @param error Optional error message. When non-`NULL` the error slot is shown
#'   (otherwise it is rendered but `hidden`, ready for client-side validation).
#' @param required If `TRUE`, appends a visual required marker to the label.
#' @param inputId Optional id for the field root.
#' @param class Extra CSS classes.
#' @returns A `<div class="shad-form-field">` tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_form_field(
#'   shad_input("user", value = "shadcn"),
#'   label = "Username",
#'   description = "This is your public display name."
#' )
#' @export
shad_form_field <- function(..., label = NULL, description = NULL, error = NULL,
                            required = FALSE, inputId = NULL, class = NULL) {
  dots <- split_dots(...)

  label_tag <- if (!is.null(label)) {
    htmltools::tags$label(
      class = "shad-label",
      label,
      if (isTRUE(required)) {
        htmltools::tags$span(
          class = "shad-form-field__required", `aria-hidden` = "true", " *"
        )
      }
    )
  }
  desc_tag <- if (!is.null(description)) {
    htmltools::tags$p(class = "shad-form-field__description", description)
  }
  err_tag <- htmltools::tags$p(
    class = "shad-form-field__error",
    hidden = flag_attr(is.null(error)),
    error
  )

  with_deps(do.call(htmltools::tags$div, c(
    drop_nulls(list(
      class = shad_class("shad-form-field", extra = class),
      id = inputId,
      `data-shad` = "form-field"
    )),
    dots$attribs,
    drop_nulls(list(label_tag)),
    dots$children,
    drop_nulls(list(desc_tag, err_tag))
  )))
}
