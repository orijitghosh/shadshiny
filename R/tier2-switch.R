# switch -----------------------------------------------------------------------

#' Switch
#'
#' A shadcn switch (toggle). `input$<inputId>` is a logical.
#'
#' @param inputId Input id.
#' @param label Optional label shown next to the switch.
#' @param value Initial logical value.
#' @param disabled If `TRUE`, disables the control.
#' @param description Optional help text below the row.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the switch button.
#' @returns A switch row tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_switch("wifi", "Wi-Fi", value = TRUE)
#' @export
shad_switch <- function(inputId, label = NULL, value = FALSE, disabled = FALSE,
                        description = NULL, class = NULL, ...) {
  value <- shiny::restoreInput(id = inputId, default = value)
  state <- if (isTRUE(value)) "checked" else "unchecked"
  sw <- htmltools::tags$button(
    type = "button",
    class = "shad-switch",
    `data-shad` = "switch",
    role = "switch",
    `data-state` = state,
    id = inputId,
    `data-disabled` = flag_attr(disabled),
    disabled = flag_attr(disabled),
    ...,
    htmltools::tags$span(class = "shad-switch__thumb", `aria-hidden` = "true")
  )
  label_tag <- if (!is.null(label)) {
    htmltools::tags$label(
      class = "shad-label", `for` = inputId,
      `data-disabled` = flag_attr(disabled), label
    )
  }
  row <- htmltools::tags$div(
    class = shad_class("shad-switch-row", extra = if (is.null(description)) class),
    sw, label_tag
  )
  if (is.null(description)) return(with_deps(row))
  shad_form_field(row, description = description, class = class)
}
