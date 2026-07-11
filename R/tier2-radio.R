# radio-group ------------------------------------------------------------------

#' Radio group
#'
#' A shadcn radio group. `input$<inputId>` is the selected value (a string) or
#' `NULL`.
#'
#' @param inputId Input id.
#' @param label Optional group label (rendered above the group).
#' @param choices A named character vector (`c(Label = "value")`), an unnamed
#'   vector, or a list of [shad_radio_item()] specs.
#' @param selected Initially selected value.
#' @param orientation `"vertical"` (default) or `"horizontal"`.
#' @param disabled If `TRUE`, disables every item.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the group root.
#' @returns A radio-group tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_radio_group("plan", choices = c(Free = "free", Pro = "pro"),
#'                  selected = "pro")
#' @export
shad_radio_group <- function(inputId, label = NULL, choices, selected = NULL,
                             orientation = c("vertical", "horizontal"),
                             disabled = FALSE, class = NULL, ...) {
  orientation <- arg_match_shad(orientation, c("vertical", "horizontal"),
                                "orientation")
  items <- normalize_choices(choices)

  rows <- lapply(seq_along(items), function(i) {
    it <- items[[i]]
    val <- as.character(it$value)
    it_disabled <- isTRUE(disabled) || isTRUE(it$disabled)
    item_id <- paste0(inputId, "-", i)
    state <- if (!is.null(selected) && identical(val, as.character(selected))) {
      "checked"
    } else {
      "unchecked"
    }
    btn <- htmltools::tags$button(
      type = "button", class = "shad-radio", role = "radio",
      `data-value` = val, `data-state` = state, id = item_id,
      `data-disabled` = flag_attr(it_disabled),
      disabled = flag_attr(it_disabled),
      htmltools::tags$span(class = "shad-radio__indicator", `aria-hidden` = "true")
    )
    lab <- htmltools::tags$label(
      class = "shad-label", `for` = item_id,
      `data-disabled` = flag_attr(it_disabled),
      it$label,
      if (!is.null(it$description)) {
        htmltools::tags$span(class = "shad-muted", it$description)
      }
    )
    htmltools::tags$div(class = "shad-radio-row", btn, lab)
  })

  group <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-radio-group", extra = if (is.null(label)) class),
      `data-shad` = "radio-group",
      id = inputId,
      role = "radiogroup",
      `data-orientation` = if (orientation == "horizontal") "horizontal" else NULL,
      ...
    ),
    rows
  ))

  if (is.null(label)) return(with_deps(group))
  shad_form_field(group, label = label, class = class)
}

#' @rdname shad_radio_group
#' @param value The item's value.
#' @param description Optional per-item help text.
#' @export
shad_radio_item <- function(value, label = value, disabled = FALSE,
                            description = NULL) {
  list(value = value, label = label, disabled = disabled,
       description = description)
}
