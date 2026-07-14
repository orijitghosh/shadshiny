# select -----------------------------------------------------------------------

.shad_select_check <- htmltools::HTML(paste0(
  '<svg class="shad-select__item-check" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>'
))
.shad_select_chevron <- htmltools::HTML(paste0(
  '<svg class="shad-select__chevron" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>'
))
.shad_select_scroll_up <- htmltools::HTML(paste0(
  '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
  '<path d="m18 15-6-6-6 6"/></svg>'
))
.shad_select_scroll_down <- htmltools::HTML(paste0(
  '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
  '<path d="m6 9 6 6 6-6"/></svg>'
))

# Render one select item from an item spec.
.shad_render_select_item <- function(it, selected) {
  val <- as.character(it$value)
  it_disabled <- isTRUE(it$disabled)
  checked <- !is.null(selected) && identical(val, as.character(selected))
  htmltools::tags$div(
    class = "shad-select__item", role = "option",
    `data-value` = val,
    `data-state` = if (checked) "checked" else "unchecked",
    `data-disabled` = flag_attr(it_disabled),
    `aria-disabled` = if (it_disabled) "true" else NULL,
    .shad_select_check,
    if (is.null(it$label)) val else it$label
  )
}

# Dispatch a choices node (item / group / separator) to markup.
.shad_render_select_node <- function(node, selected) {
  type <- node$type %||% "item"
  if (type == "separator") {
    return(htmltools::tags$div(
      class = "shad-select__separator", role = "separator", `aria-hidden` = "true"
    ))
  }
  if (type == "group") {
    gid <- shad_uid("selgrp")
    return(htmltools::tags$div(
      role = "group", `aria-labelledby` = gid,
      htmltools::tags$div(class = "shad-select__group-label", id = gid, node$label),
      lapply(normalize_choices(node$items), .shad_render_select_item,
             selected = selected)
    ))
  }
  .shad_render_select_item(node, selected)
}

#' Select
#'
#' A shadcn select (listbox popup). `input$<inputId>` is the selected value or
#' `NULL`.
#'
#' @param inputId Input id.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param choices A named/unnamed vector, or a list mixing [shad_select_item()],
#'   [shad_select_group()], and [shad_select_separator()].
#' @param selected Initially selected value.
#' @param placeholder Trigger placeholder text.
#' @param disabled If `TRUE`, disables the control.
#' @param width CSS width.
#' @param description Optional help text (wraps in [shad_form_field()]).
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the select root.
#' @returns A select tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_select("fruit", choices = c("Apple" = "apple", "Banana" = "banana"),
#'             selected = "banana")
#' @export
shad_select <- function(inputId, label = NULL, choices, selected = NULL,
                        placeholder = "Select...", disabled = FALSE,
                        width = NULL, description = NULL, class = NULL, ...) {
  selected <- shiny::restoreInput(id = inputId, default = selected)
  nodes <- normalize_choices(choices)
  items_markup <- lapply(nodes, .shad_render_select_node, selected = selected)

  # Resolve the label shown in the trigger for the selected value.
  sel_label <- NULL
  if (!is.null(selected)) {
    flat <- .shad_flatten_choices(nodes)
    hit <- Filter(function(x) identical(as.character(x$value),
                                        as.character(selected)), flat)
    if (length(hit)) sel_label <- hit[[1]]$label %||% as.character(selected)
  }

  wrapped <- !is.null(label) || !is.null(description)
  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-select", extra = if (!wrapped) class),
      `data-shad` = "select",
      id = inputId,
      style = width_style(width),
      ...
    ),
    list(
      htmltools::tags$button(
        type = "button", class = "shad-select__trigger",
        `data-placeholder` = if (is.null(selected)) NA else NULL,
        disabled = flag_attr(disabled),
        htmltools::tags$span(
          class = "shad-select__value",
          if (!is.null(sel_label)) sel_label else placeholder
        ),
        .shad_select_chevron
      ),
      do.call(htmltools::tags$div, c(
        list(class = "shad-select__content shad-anim-pop", hidden = NA),
        list(
          htmltools::tags$button(
            type = "button", class = "shad-select__scroll-btn", `data-dir` = "up",
            hidden = NA, tabindex = "-1", `aria-hidden` = "true",
            .shad_select_scroll_up
          ),
          do.call(htmltools::tags$div,
                  c(list(class = "shad-select__viewport"), items_markup)),
          htmltools::tags$button(
            type = "button", class = "shad-select__scroll-btn", `data-dir` = "down",
            hidden = NA, tabindex = "-1", `aria-hidden` = "true",
            .shad_select_scroll_down
          )
        )
      ))
    )
  ))

  if (!wrapped) return(with_deps(root))
  shad_form_field(root, label = label, description = description, class = class)
}

# Flatten nodes (through groups) to a list of item specs for label lookup.
.shad_flatten_choices <- function(nodes) {
  out <- list()
  for (n in nodes) {
    type <- n$type %||% "item"
    if (type == "group") {
      out <- c(out, normalize_choices(n$items))
    } else if (type != "separator") {
      out <- c(out, list(n))
    }
  }
  out
}

#' @rdname shad_select
#' @param value The item's value.
#' @export
shad_select_item <- function(value, label = NULL, disabled = FALSE) {
  list(type = "item", value = value, label = label, disabled = disabled)
}

#' @rdname shad_select
#' @param ... For [shad_select_group()], the group's items.
#' @export
shad_select_group <- function(label, ...) {
  list(type = "group", label = label, items = list(...))
}

#' @rdname shad_select
#' @export
shad_select_separator <- function() {
  list(type = "separator")
}
