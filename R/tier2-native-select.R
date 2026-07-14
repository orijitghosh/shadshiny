# native-select ----------------------------------------------------------------

.shad_native_chevron <- htmltools::HTML(paste0(
  '<svg class="shad-icon shad-native-select__chevron" viewBox="0 0 24 24" ',
  'fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>'
))

# One <option>. `value` and `label` are scalars; marks selected when it matches.
.shad_native_option <- function(value, label, selected) {
  htmltools::tags$option(
    value = as.character(value),
    selected = if (!is.null(selected) &&
                   as.character(value) %in% as.character(selected)) NA else NULL,
    label
  )
}

# Render a flat (named or unnamed) vector/list of choices into <option>s.
.shad_native_flat <- function(choices, selected) {
  choices <- unlist(choices)
  vals <- unname(choices)
  labs <- names(choices)
  if (is.null(labs)) labs <- as.character(vals)
  labs[!nzchar(labs)] <- as.character(vals)[!nzchar(labs)]
  unname(Map(function(v, l) .shad_native_option(v, l, selected),
             as.character(vals), labs))
}

# Grouped when `choices` is a named list whose elements are themselves vectors
# (i.e. at least one element has length > 1 or is a list) -> <optgroup>s.
.shad_native_grouped <- function(choices) {
  is.list(choices) && !is.null(names(choices)) && all(nzchar(names(choices))) &&
    any(vapply(choices, length, integer(1)) > 1 | vapply(choices, is.list, logical(1)))
}

#' Native select
#'
#' A styled native HTML `<select>`. Unlike [shad_select()] (a custom listbox),
#' this keeps full browser-native behaviour — mobile pickers, form
#' participation, typeahead — and only bridges the value to Shiny.
#' `input$<inputId>` is the selected option value (a string).
#'
#' @param inputId Input id.
#' @param choices A named/unnamed vector for flat options, or a named list of
#'   vectors to build `<optgroup>`s (names become group labels).
#' @param selected Initially selected value.
#' @param size One of `NULL` (default), `"sm"`, `"lg"`.
#' @param disabled If `TRUE`, disables the control.
#' @param invalid If `TRUE`, sets `aria-invalid` (destructive styling).
#' @param width CSS width.
#' @param label Accessible label applied as `aria-label` on the `<select>`.
#' @param class Extra CSS classes on the root.
#' @param ... Extra attributes on the root `<div>`.
#' @returns A native-select tag.
#' @family shadshiny tier-2 components
#' @seealso [update_shad_native_select()]
#' @examples
#' shad_native_select("tz", choices = list(
#'   Americas = c("America/New_York", "America/Sao_Paulo"),
#'   Europe   = c("Europe/London", "Europe/Berlin")
#' ))
#' @export
shad_native_select <- function(inputId, choices, selected = NULL, size = NULL,
                               disabled = FALSE, invalid = FALSE, width = NULL,
                               label = NULL, class = NULL, ...) {
  selected <- shiny::restoreInput(id = inputId, default = selected)
  if (!is.null(size)) arg_match_shad(size, c("sm", "lg"), "size")
  size_class <- if (is.null(size)) NULL else paste0("shad-native-select--", size)

  options <- if (.shad_native_grouped(choices)) {
    lapply(seq_along(choices), function(i) {
      htmltools::tags$optgroup(
        label = names(choices)[i],
        .shad_native_flat(choices[[i]], selected)
      )
    })
  } else {
    .shad_native_flat(choices, selected)
  }

  select <- do.call(htmltools::tags$select, c(
    list(
      class = "shad-native-select__select",
      `aria-label` = label,
      `aria-invalid` = if (isTRUE(invalid)) "true" else NULL,
      disabled = flag_attr(disabled)
    ),
    options
  ))

  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-native-select", size_class, extra = class),
      `data-shad` = "native-select",
      id = inputId,
      `data-invalid` = if (isTRUE(invalid)) NA else NULL,
      style = width_style(width),
      ...
    ),
    list(select, .shad_native_chevron)
  ))
  with_deps(root)
}
