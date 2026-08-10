# command ----------------------------------------------------------------------

.shad_command_search <- htmltools::HTML(paste0(
  '<svg class="shad-command__search-icon" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/>',
  '<path d="m21 21-4.3-4.3"/></svg>'
))

#' Command palette
#'
#' A searchable command menu. `input$<inputId>` is the value of the selected
#' item. Compose contents with [shad_command_group()], [shad_command_item()],
#' and [shad_command_separator()].
#'
#' @param inputId Input id.
#' @param ... Command content (groups, items, separators).
#' @param placeholder Search-input placeholder.
#' @param empty_text Text shown when no item matches.
#' @param dialog If `TRUE`, render the ⌘K/Ctrl+K dialog variant.
#' @param hotkey If `TRUE`, bind the `mod+k` open hotkey (defaults to `dialog`).
#' @param class Extra CSS classes.
#' @returns A command tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_command("cmd",
#'   shad_command_group("Suggestions",
#'     shad_command_item("calendar", "Calendar", keywords = "date schedule")))
#' @export
shad_command <- function(inputId, ...,
                         placeholder = "Type a command or search...",
                         empty_text = "No results found.", dialog = FALSE,
                         hotkey = dialog, class = NULL) {
  with_deps(htmltools::tags$div(
    class = shad_class("shad-command", extra = class),
    `data-shad` = "command", id = inputId,
    `data-hotkey` = if (isTRUE(hotkey)) "mod+k" else NULL,
    # The asset treats a hotkey as implying dialog mode, but `dialog = TRUE,
    # hotkey = FALSE` is a real combination (opened from a trigger or the
    # server), so mark it explicitly.
    `data-dialog` = flag_attr(dialog),
    `aria-label` = if (isTRUE(dialog)) "Command palette" else NULL,
    htmltools::tags$div(
      class = "shad-command__header",
      .shad_command_search,
      htmltools::tags$input(
        class = "shad-command__input", type = "text", placeholder = placeholder,
        `aria-label` = "Search commands"
      )
    ),
    do.call(htmltools::tags$div, c(
      list(class = "shad-command__list"),
      list(htmltools::tags$div(class = "shad-command__empty", empty_text)),
      list(...)
    ))
  ))
}

#' @rdname shad_command
#' @param label Group heading, or item text.
#' @export
shad_command_group <- function(label, ...) {
  htmltools::tags$div(
    class = "shad-command__group",
    htmltools::tags$div(class = "shad-command__group-heading", label),
    ...
  )
}

#' @rdname shad_command
#' @param value Item value reported on selection.
#' @param icon Optional leading icon.
#' @param shortcut Optional shortcut hint.
#' @param keywords Extra search terms (space-separated or a character vector).
#' @param disabled If `TRUE`, the item is not selectable.
#' @export
shad_command_item <- function(value, label = NULL, icon = NULL, shortcut = NULL,
                              keywords = NULL, disabled = FALSE) {
  htmltools::tags$button(
    type = "button", class = "shad-command__item", `data-value` = value,
    `data-keywords` = if (!is.null(keywords)) paste(keywords, collapse = " ") else NULL,
    `data-disabled` = flag_attr(disabled),
    resolve_icon(icon),
    if (is.null(label)) value else label,
    if (!is.null(shortcut)) {
      htmltools::tags$span(class = "shad-command__shortcut", shortcut)
    }
  )
}

#' @rdname shad_command
#' @export
shad_command_separator <- function() {
  htmltools::tags$div(class = "shad-command__separator")
}
