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

#' Semantic fieldset
#'
#' Experimental.
#' Groups related controls under a native legend while keeping the existing
#' shad_form_field() wrapper as the single-control primitive. The optional
#' description is associated with the fieldset through aria-describedby.
#'
#' @param legend Legend content for the fieldset.
#' @param ... Child controls, field groups, and/or named HTML attributes.
#' @param description Optional help text rendered below the legend.
#' @param variant "legend" (default) or "label" for the legend's visual
#'   treatment.
#' @param class Extra CSS classes.
#' @returns A native <fieldset> tag.
#' @family shadshiny forms
#' @examples
#' shad_fieldset(
#'   "Shipping address",
#'   shad_input("street", "Street"),
#'   shad_field_group(
#'     shad_input("city", "City"),
#'     shad_input("postcode", "Postcode"),
#'     orientation = "horizontal"
#'   ),
#'   description = "Where should we send your order?"
#' )
#' @export
shad_fieldset <- function(legend, ..., description = NULL,
                          variant = c("legend", "label"), class = NULL) {
  variant <- arg_match_shad(variant, c("legend", "label"), "variant")
  dots <- split_dots(...)
  description_id <- if (!is.null(description)) shad_uid("fieldset-description")

  legend_tag <- htmltools::tags$legend(
    class = shad_class(
      "shad-fieldset__legend",
      if (variant == "label") "shad-fieldset__legend--label"
    ),
    legend
  )
  description_tag <- if (!is.null(description)) {
    htmltools::tags$p(
      class = "shad-fieldset__description",
      id = description_id,
      description
    )
  }

  with_deps(do.call(htmltools::tags$fieldset, c(
    drop_nulls(list(
      class = shad_class("shad-fieldset", extra = class),
      `data-variant` = if (variant == "label") "label" else NULL,
      `aria-describedby` = description_id
    )),
    dots$attribs,
    list(legend_tag, description_tag),
    dots$children
  )))
}

#' Field group
#'
#' Experimental.
#' Arranges shad_form_field() children vertically, horizontally, or
#' responsively inside a container-query-aware group.
#'
#' @param ... Child fields and/or named HTML attributes.
#' @param orientation "vertical" (default), "horizontal", or "responsive".
#' @param class Extra CSS classes.
#' @returns A <div> field-group tag.
#' @family shadshiny forms
#' @examples
#' shad_field_group(
#'   shad_input("first", "First name"),
#'   shad_input("last", "Last name"),
#'   orientation = "responsive"
#' )
#' @export
shad_field_group <- function(...,
                             orientation = c("vertical", "horizontal", "responsive"),
                             class = NULL) {
  orientation <- arg_match_shad(
    orientation, c("vertical", "horizontal", "responsive"), "orientation"
  )
  dots <- split_dots(...)

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-field-group", extra = class),
      `data-orientation` = orientation
    ),
    dots$attribs,
    dots$children
  )))
}

#' Field separator
#'
#' Experimental.
#' Inserts a labelled or unlabelled visual separator between fields. For a
#' labelled separator, the visible label is deliberately outside the child
#' separator node so assistive technology does not treat the text as the
#' separator's accessible name.
#'
#' @param label Optional visible separator label.
#' @param class Extra CSS classes.
#' @returns A separator tag.
#' @family shadshiny forms
#' @examples
#' shad_fieldset(
#'   "Sign in",
#'   shad_input("email", "Email"),
#'   shad_field_separator("or"),
#'   shad_button("Continue with a passkey", variant = "outline")
#' )
#' @export
shad_field_separator <- function(label = NULL, class = NULL) {
  if (is.null(label)) {
    return(with_deps(htmltools::tags$div(
      class = shad_class("shad-field-separator", extra = class),
      role = "separator",
      `aria-orientation` = "horizontal",
      `aria-hidden` = "true"
    )))
  }

  with_deps(htmltools::tags$div(
    class = shad_class("shad-field-separator", extra = class),
    htmltools::tags$span(class = "shad-field-separator__label", label),
    htmltools::tags$div(
      class = "shad-field-separator__line",
      role = "separator",
      `aria-orientation` = "horizontal",
      `aria-hidden` = "true"
    )
  ))
}
