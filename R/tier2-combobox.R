# combobox ---------------------------------------------------------------------

.shad_combobox_check <- htmltools::HTML(paste0(
  '<svg class="shad-combobox__item-check" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>'
))
.shad_combobox_chevrons <- htmltools::HTML(paste0(
  '<svg class="shad-combobox__chevrons" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="m7 15 5 5 5-5"/>',
  '<path d="m7 9 5-5 5 5"/></svg>'
))
.shad_combobox_search_icon <- htmltools::HTML(paste0(
  '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ',
  'aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
  '</svg>'
))

#' Combobox
#'
#' A shadcn combobox (searchable select). `input$<inputId>` is a string/`NULL`
#' (single) or a character vector (multiple, chips rendered client-side).
#'
#' @param inputId Input id.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param choices A named/unnamed vector or a list of [shad_select_item()]-style
#'   specs (`list(value=, label=, disabled=)`).
#' @param selected Initially selected value(s).
#' @param multiple If `TRUE`, allow multiple selection.
#' @param placeholder Trigger placeholder text.
#' @param search_placeholder Search-input placeholder.
#' @param empty_text Text shown when no item matches the search.
#' @param disabled If `TRUE`, disables the control.
#' @param width CSS width.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the combobox root.
#' @returns A combobox tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_combobox("fw", choices = c("Next.js" = "next", "Astro" = "astro"))
#' @export
shad_combobox <- function(inputId, label = NULL, choices, selected = NULL,
                          multiple = FALSE, placeholder = "Select2026",
                          search_placeholder = "Search2026",
                          empty_text = "No results.", disabled = FALSE,
                          width = NULL, class = NULL, ...) {
  selected <- shiny::restoreInput(id = inputId, default = selected)
  items <- normalize_choices(choices)
  sel <- as.character(selected)

  item_markup <- lapply(items, function(it) {
    val <- as.character(it$value)
    it_disabled <- isTRUE(it$disabled)
    htmltools::tags$div(
      class = "shad-combobox__item",
      `data-value` = val,
      `data-state` = if (val %in% sel) "checked" else "unchecked",
      `data-disabled` = flag_attr(it_disabled),
      `aria-disabled` = if (it_disabled) "true" else NULL,
      .shad_combobox_check,
      if (is.null(it$label)) val else it$label
    )
  })

  # Single-select trigger shows the chosen label; multi lets the JS build chips.
  trigger_text <- placeholder
  if (!isTRUE(multiple) && length(sel)) {
    hit <- Filter(function(x) identical(as.character(x$value), sel[[1]]), items)
    if (length(hit)) trigger_text <- hit[[1]]$label %||% sel[[1]]
  }

  wrapped <- !is.null(label)
  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-combobox", extra = if (!wrapped) class),
      `data-shad` = "combobox",
      id = inputId,
      `data-multiple` = flag_attr(multiple),
      `data-state` = "closed",
      style = width_style(width),
      ...
    ),
    list(
      htmltools::tags$button(
        type = "button", class = "shad-combobox__trigger",
        `data-placeholder` = if (length(sel) == 0) NA else NULL,
        disabled = flag_attr(disabled),
        htmltools::tags$span(class = "shad-combobox__value", trigger_text),
        .shad_combobox_chevrons
      ),
      htmltools::tags$div(
        class = "shad-combobox__content shad-anim-pop", hidden = NA,
        htmltools::tags$div(
          class = "shad-combobox__search",
          .shad_combobox_search_icon,
          htmltools::tags$input(
            class = "shad-combobox__input", type = "text",
            placeholder = search_placeholder, autocomplete = "off",
            autocorrect = "off", spellcheck = "false"
          )
        ),
        do.call(htmltools::tags$div,
                c(list(class = "shad-combobox__list"), item_markup)),
        htmltools::tags$div(class = "shad-combobox__empty", hidden = NA, empty_text)
      )
    )
  ))

  if (!wrapped) return(with_deps(root))
  shad_form_field(root, label = label, class = class)
}
