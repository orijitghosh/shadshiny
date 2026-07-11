# tabs -------------------------------------------------------------------------

.shad_accordion_chevron <- htmltools::HTML(paste0(
  '<svg class="shad-accordion__chevron" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>'
))

#' Tabs
#'
#' A tabbed panel set. `input$<inputId>` is the active tab value. Build tabs
#' with [shad_tab()], which supplies both the trigger and its content panel.
#'
#' @param inputId Input id.
#' @param ... One or more [shad_tab()].
#' @param selected Initially active tab value (defaults to the first tab).
#' @param orientation `"horizontal"` (default) or `"vertical"`.
#' @param class Extra CSS classes.
#' @returns A tabs tag.
#' @family shadshiny tier-3 components
#' @seealso [update_shad_tabs()]
#' @examples
#' shad_tabs("t",
#'   shad_tab("account", "Account", "Account panel"),
#'   shad_tab("password", "Password", "Password panel"))
#' @export
shad_tabs <- function(inputId, ..., selected = NULL,
                      orientation = c("horizontal", "vertical"), class = NULL) {
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"),
                                "orientation")
  tabs <- Filter(function(x) inherits(x, "shad_tab"), list(...))
  if (!length(tabs)) stop("`shad_tabs()` needs at least one `shad_tab()`.", call. = FALSE)
  if (is.null(selected)) selected <- tabs[[1]]$value

  triggers <- lapply(tabs, function(t) {
    htmltools::tags$button(
      type = "button", class = "shad-tabs__trigger", `data-value` = t$value,
      `data-disabled` = flag_attr(t$disabled),
      resolve_icon(t$icon), t$title
    )
  })
  contents <- lapply(tabs, function(t) {
    do.call(htmltools::tags$div, c(
      list(class = "shad-tabs__content", `data-value` = t$value), t$children
    ))
  })

  list_tag <- do.call(htmltools::tags$div, c(
    list(class = "shad-tabs__list",
         htmltools::tags$div(class = "shad-tabs__indicator", `aria-hidden` = "true")),
    triggers
  ))

  with_deps(do.call(htmltools::tags$div, c(
    list(
      class = if (!is.null(class)) class else NULL,
      `data-shad` = "tabs", id = inputId, `data-value` = selected,
      `data-orientation` = if (orientation == "vertical") "vertical" else NULL
    ),
    list(list_tag), contents
  )))
}

#' @rdname shad_tabs
#' @param value Tab value.
#' @param title Tab trigger label.
#' @param icon Optional trigger icon.
#' @param disabled If `TRUE`, the tab cannot be selected.
#' @export
shad_tab <- function(value, title, ..., icon = NULL, disabled = FALSE) {
  structure(
    list(value = value, title = title, icon = icon, disabled = disabled,
         children = list(...)),
    class = "shad_tab"
  )
}
