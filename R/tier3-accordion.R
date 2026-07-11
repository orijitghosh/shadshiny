# accordion & collapsible ------------------------------------------------------

#' Accordion
#'
#' A vertically stacked set of expandable items. `input$<inputId>` is the open
#' value(s): a string/`NULL` (single) or a character vector (multiple).
#'
#' @param inputId Input id.
#' @param ... One or more [shad_accordion_item()].
#' @param type `"single"` (default) or `"multiple"`.
#' @param collapsible For `type = "single"`, allow closing the open item.
#' @param value Initially open value(s).
#' @param class Extra CSS classes.
#' @returns An accordion tag.
#' @family shadshiny tier-3 components
#' @seealso [update_shad_accordion()]
#' @examples
#' shad_accordion("a",
#'   shad_accordion_item("item-1", "Is it accessible?", "Yes."),
#'   shad_accordion_item("item-2", "Is it styled?", "Yes."),
#'   value = "item-1")
#' @export
shad_accordion <- function(inputId, ..., type = c("single", "multiple"),
                           collapsible = TRUE, value = NULL, class = NULL) {
  type <- arg_match_shad(type, c("single", "multiple"), "type")
  items <- Filter(function(x) inherits(x, "shad_accordion_item"), list(...))
  open <- as.character(value)

  item_tags <- lapply(items, function(it) {
    do.call(htmltools::tags$div, c(
      list(
        class = "shad-accordion__item", `data-value` = it$value,
        `data-open` = flag_attr(it$value %in% open)
      ),
      list(
        htmltools::tags$button(
          type = "button", class = "shad-accordion__trigger",
          it$title, .shad_accordion_chevron
        ),
        htmltools::tags$div(
          class = "shad-accordion__content",
          do.call(htmltools::tags$div,
                  c(list(class = "shad-accordion__content-inner"), it$children))
        )
      )
    ))
  })

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = if (!is.null(class)) class else NULL,
      `data-shad` = "accordion", id = inputId, `data-type` = type,
      `data-collapsible` = flag_attr(collapsible && type == "single")
    ),
    item_tags
  )))
}

#' @rdname shad_accordion
#' @param value Item value.
#' @param title Trigger text.
#' @export
shad_accordion_item <- function(value, title, ...) {
  structure(
    list(value = value, title = title, children = list(...)),
    class = "shad_accordion_item"
  )
}

#' Collapsible
#'
#' A single show/hide region toggled by a trigger. `input$<inputId>` is the open
#' state (logical).
#'
#' @param inputId Input id.
#' @param trigger The tag that toggles the region.
#' @param ... Collapsible content.
#' @param open Initial open state.
#' @param class Extra CSS classes.
#' @returns A collapsible tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_collapsible("c", trigger = shad_button("Toggle"), "Hidden content",
#'                  open = TRUE)
#' @export
shad_collapsible <- function(inputId, trigger, ..., open = FALSE, class = NULL) {
  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "collapsible", id = inputId, `data-open` = flag_attr(open),
    .shad_as_trigger(trigger, "shad-collapsible__trigger"),
    htmltools::tags$div(class = "shad-collapsible__content", ...)
  ))
}
