# calendar & date-picker -------------------------------------------------------

# Serialize a Date / character to ISO-8601 (YYYY-MM-DD), or NULL.
.iso_date <- function(x) {
  if (is.null(x) || length(x) == 0) return(NULL)
  x <- x[[1]]
  if (inherits(x, "Date")) return(format(x, "%Y-%m-%d"))
  format(as.Date(x), "%Y-%m-%d")
}

#' Calendar
#'
#' A shadcn calendar. The month grid is rendered client-side from the seed
#' attributes. `input$<inputId>` is a `Date` (single) or length-2 `Date`
#' (range), via the `shadshiny.date` input handler.
#'
#' @param inputId Input id.
#' @param value Initial selection: a `Date`/character (single) or length-2
#'   `Date`/character (range).
#' @param mode `"single"` (default) or `"range"`.
#' @param min,max Selectable bounds (inclusive), `Date`/character.
#' @param month Initially displayed month (`Date` or `"YYYY-MM"`); advisory.
#' @param week_starts_on `0` (Sunday, default) or `1` (Monday).
#' @param disabled If `TRUE`, disables the control.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the calendar root.
#' @returns A calendar tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_calendar("day", value = Sys.Date())
#' shad_calendar("range", mode = "range", week_starts_on = 1)
#' @export
shad_calendar <- function(inputId, value = NULL, mode = c("single", "range"),
                          min = NULL, max = NULL, month = NULL,
                          week_starts_on = 0, disabled = FALSE, class = NULL,
                          ...) {
  if (!is.null(inputId)) value <- shiny::restoreInput(id = inputId, default = value)
  mode <- arg_match_shad(mode, c("single", "range"), "mode")
  v_start <- if (!is.null(value)) .iso_date(value[[1]]) else NULL
  v_end <- if (mode == "range" && length(value) >= 2) .iso_date(value[[2]]) else NULL
  month_attr <- if (!is.null(month)) {
    if (inherits(month, "Date")) format(month, "%Y-%m") else as.character(month)
  }

  with_deps(htmltools::tags$div(
    class = shad_class("shad-calendar", extra = class),
    `data-shad` = "calendar",
    id = inputId,
    `data-mode` = mode,
    `data-value` = v_start,
    `data-value-end` = v_end,
    `data-min` = .iso_date(min),
    `data-max` = .iso_date(max),
    `data-week-start` = as.integer(week_starts_on),
    `data-month` = month_attr,
    `data-disabled` = flag_attr(disabled),
    ...
  ))
}

.shad_date_picker_icon <- htmltools::HTML(paste0(
  '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ',
  'aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/>',
  '<rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>'
))

#' Date picker
#'
#' A shadcn date picker: a trigger button that opens a [shad_calendar()] in a
#' popover. Value contract is identical to [shad_calendar()].
#'
#' @inheritParams shad_calendar
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param placeholder Trigger text shown when nothing is selected.
#' @param width CSS width.
#' @returns A date-picker tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_date_picker("d", label = "Date")
#' shad_date_picker("range", mode = "range")
#' @export
shad_date_picker <- function(inputId, label = NULL, value = NULL,
                             mode = c("single", "range"),
                             placeholder = "Pick a date", min = NULL, max = NULL,
                             disabled = FALSE, width = NULL, class = NULL, ...) {
  value <- shiny::restoreInput(id = inputId, default = value)
  mode <- arg_match_shad(mode, c("single", "range"), "mode")
  # Inner calendar is unbound (no id); the date-picker root is the Shiny input.
  cal <- shad_calendar(
    inputId = NULL, value = value, mode = mode, min = min, max = max,
    week_starts_on = if (mode == "range") 1 else 0
  )

  wrapped <- !is.null(label)
  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-date-picker", extra = if (!wrapped) class),
      `data-shad` = "date-picker",
      id = inputId,
      style = width_style(width),
      ...
    ),
    list(
      htmltools::tags$button(
        type = "button", class = "shad-date-picker__trigger",
        `data-placeholder` = if (is.null(value)) NA else NULL,
        disabled = flag_attr(disabled),
        .shad_date_picker_icon,
        htmltools::tags$span(class = "shad-date-picker__value", placeholder)
      ),
      htmltools::tags$div(
        class = "shad-date-picker__content shad-anim-pop", hidden = NA, cal
      )
    )
  ))

  if (!wrapped) return(with_deps(root))
  shad_form_field(root, label = label, class = class)
}
