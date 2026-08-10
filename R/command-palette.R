# Command palette --------------------------------------------------------------
# shad_command() is the raw component; this is the app-navigation shape of it:
# a mod+K dialog whose items come from data rather than from a pile of
# constructor calls, with a trigger, server-side item refresh, and an event
# input that fires on every activation.

# choices -> command items. Accepts:
#   c(Home = "home", Settings = "settings")        one flat group
#   list(Go = c(Home = "home"), Act = c(...))      named groups, separated
#   list(shad_command_item(...), ...)              passed through untouched
#' @noRd
.shad_command_items <- function(items) {
  if (is.null(items)) return(list())
  if (is.list(items) && length(items) && all(vapply(items, is_tag_like, logical(1)))) {
    return(items)
  }
  if (!is.list(items)) return(lapply(normalize_choices(items), .shad_command_one))

  groups <- Filter(Negate(is.null), lapply(seq_along(items), function(i) {
    entry <- items[[i]]
    label <- names(items)[[i]]
    kids <- if (is_tag_like(entry)) list(entry) else {
      lapply(normalize_choices(entry), .shad_command_one)
    }
    if (!length(kids)) return(NULL)
    if (is.null(label) || !nzchar(label)) kids else
      do.call(shad_command_group, c(list(label), kids))
  }))
  # Named groups read as sections; unnamed entries stay inline between them.
  Reduce(function(acc, g) {
    if (length(acc)) c(acc, list(shad_command_separator()), list(g)) else list(g)
  }, groups, list())
}

# One normalize_choices() entry -> an item. A list entry may carry the extra
# fields shad_command_item() understands.
#' @noRd
.shad_command_one <- function(x) {
  shad_command_item(
    value = x$value, label = x$label, icon = x$icon, shortcut = x$shortcut,
    keywords = x$keywords, disabled = isTRUE(x$disabled)
  )
}

#' Command palette for app navigation
#'
#' The ⌘K / Ctrl+K pattern: a modal, searchable list of everything the app can
#' do. A thin shape over [shad_command()] that takes its items as data, opens on
#' the hotkey (or from [shad_command_trigger()], or from the server), and reports
#' every activation.
#'
#' Read selections from `input$<inputId>_event`, a list of `value` and `nonce`.
#' `input$<inputId>` also holds the last value, but Shiny drops a repeat of the
#' same value — which is wrong for navigation, where choosing "Settings" twice
#' has to work twice. The `_event` input fires every time.
#'
#' Refresh the items from the server with [update_shad_command()] — a recent-docs
#' list, search results, whatever the session knows.
#'
#' @param inputId Input id.
#' @param items The commands. Either a named character vector
#'   (`c(Home = "home")` — names are labels, values are what you observe), a
#'   named list of such vectors (each name becomes a group heading, separated),
#'   or a list of [shad_command_item()] / [shad_command_group()] tags for full
#'   control. List entries may also be lists carrying `value`, `label`, `icon`,
#'   `shortcut`, `keywords`, `disabled`.
#' @param ... Extra content appended after `items`.
#' @param hotkey Key that opens the palette, e.g. `"mod+k"` (default; ⌘K on
#'   macOS, Ctrl+K elsewhere). `NULL` for no hotkey — open it from a trigger or
#'   the server instead.
#' @param placeholder Search-input placeholder.
#' @param empty_text Text shown when nothing matches.
#' @param class Extra CSS classes.
#' @returns A command tag, hidden until opened.
#' @family shadshiny tier-3 components
#' @seealso [shad_command()], [shad_command_trigger()], [update_shad_command()]
#' @examples
#' shad_command_palette("palette", items = list(
#'   "Go to" = c(Dashboard = "dashboard", Reports = "reports"),
#'   "Actions" = c("New report" = "new")
#' ))
#' @export
shad_command_palette <- function(inputId, items = NULL, ..., hotkey = "mod+k",
                                 placeholder = "Type a command or search...",
                                 empty_text = "No results found.",
                                 class = NULL) {
  if (!is.null(hotkey) && (!is.character(hotkey) || length(hotkey) != 1)) {
    stop("`hotkey` must be a single string like \"mod+k\", or NULL.", call. = FALSE)
  }
  palette <- do.call(shad_command, c(
    list(inputId), .shad_command_items(items), list(...),
    list(placeholder = placeholder, empty_text = empty_text, dialog = TRUE,
         hotkey = FALSE, class = class)
  ))
  # shad_command(hotkey=) only offers mod+k; set the attribute directly so any
  # binding the component understands can be passed through.
  if (!is.null(hotkey)) {
    palette <- htmltools::tagAppendAttributes(palette, `data-hotkey` = hotkey)
  }
  palette
}

#' @rdname shad_command_palette
#' @param id The palette's input id. In a module, namespace it yourself with
#'   `ns()` — this is a UI-side attribute, not a server message.
#' @param label Trigger text.
#' @param icon Leading icon name or tag.
#' @param shortcut Hint shown at the end of the trigger, e.g. `"⌘K"`.
#'   `NULL` for none.
#' @param variant,size Passed to [shad_button()].
#' @export
shad_command_trigger <- function(id, label = "Search...", icon = "search",
                                 shortcut = "\u2318K", variant = "outline",
                                 size = "sm", class = NULL, ...) {
  # The shortcut hint goes through `label`, not `...`: shad_button() renders
  # extra children before the label, and the hint belongs at the end.
  shad_button(
    label = htmltools::tagList(label, if (!is.null(shortcut)) shad_kbd(shortcut)),
    icon = icon, variant = variant, size = size,
    class = shad_class("shad-command__opener", extra = class),
    `data-shad-command-open` = id, ...
  )
}

#' Replace a command palette's items from the server
#'
#' Swaps the palette's list contents for freshly rendered items and re-runs its
#' filter. Use it for anything the session knows and the UI could not: recent
#' documents, search hits, commands gated on the signed-in user.
#'
#' @param id The palette's input id (namespaced automatically).
#' @param items New items, in any form [shad_command_palette()] accepts.
#' @param empty_text Text shown when nothing matches. It lives inside the list
#'   that is being replaced, so it has to be supplied again here.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`; called for its side effect.
#' @family shadshiny server API
#' @seealso [shad_command_palette()]
#' @export
update_shad_command <- function(id, items, empty_text = "No results found.",
                                session = shiny::getDefaultReactiveDomain()) {
  ui <- htmltools::tagList(
    htmltools::tags$div(class = "shad-command__empty", hidden = NA, empty_text),
    .shad_command_items(items)
  )
  shad_set_html(id, ui, selector = ".shad-command__list", session = session)
}

#' @rdname shad_command_palette
#' @param session The Shiny session.
#' @export
shad_command_open <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "open", session = session)
}

#' @rdname shad_command_palette
#' @export
shad_command_close <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}
