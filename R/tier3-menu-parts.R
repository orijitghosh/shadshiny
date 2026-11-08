# Shared menu part constructors ------------------------------------------------
# Used by dropdown-menu, context-menu, and menubar (identical .shad-menu*
# classes). Implemented once here.

.shad_menu_check <- htmltools::HTML(paste0(
  '<span class="shad-menu__indicator"><svg class="shad-icon shad-icon--sm" ',
  'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ',
  'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">',
  '<path d="M20 6 9 17l-5-5"/></svg></span>'
))
.shad_menu_dot <- htmltools::HTML(paste0(
  '<span class="shad-menu__indicator"><svg class="shad-icon shad-icon--sm" ',
  'viewBox="0 0 24 24" fill="currentColor" stroke="none" aria-hidden="true">',
  '<circle cx="12" cy="12" r="4"/></svg></span>'
))
.shad_menu_chevron <- htmltools::HTML(paste0(
  '<svg class="shad-menu__chevron" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>'
))

#' Menu part constructors
#'
#' Building blocks for [shad_dropdown_menu()], [shad_context_menu()], and
#' [shad_menubar()] menus. Activating an item reports its `value` as the menu's
#' input value.
#'
#' @param value Item value reported on activation.
#' @param label Item text.
#' @param icon Optional leading icon.
#' @param shortcut Optional keyboard-shortcut hint (right-aligned).
#' @param disabled If `TRUE`, the item is not selectable.
#' @param destructive If `TRUE`, styles the item as destructive.
#' @returns An htmltools tag (or tagList) for use inside a menu.
#' @name shad_menu_parts
#' @family shadshiny tier-3 components
NULL

#' @rdname shad_menu_parts
#' @examples
#' shad_dropdown_menu(
#'   "view", trigger = shad_button("View", variant = "outline"),
#'   shad_menu_label("Panels"),
#'   shad_menu_checkbox_item("sidebar", "Sidebar", checked = TRUE),
#'   shad_menu_separator(),
#'   shad_menu_radio_group(
#'     "comfortable",
#'     shad_menu_radio_item("compact", "Compact"),
#'     shad_menu_radio_item("comfortable", "Comfortable")
#'   ),
#'   shad_menu_separator(),
#'   shad_menu_sub("More", shad_menu_item("reset", "Reset layout")),
#'   shad_menu_item("close", "Close window", destructive = TRUE)
#' )
#' @export
shad_menu_item <- function(value, label = NULL, icon = NULL, shortcut = NULL,
                           disabled = FALSE, destructive = FALSE) {
  htmltools::tags$button(
    type = "button",
    class = shad_class("shad-menu__item",
                       if (isTRUE(destructive)) "shad-menu__item--destructive"),
    `data-value` = value,
    `data-disabled` = flag_attr(disabled),
    resolve_icon(icon),
    if (is.null(label)) value else label,
    if (!is.null(shortcut)) {
      htmltools::tags$span(class = "shad-menu__shortcut", shortcut)
    }
  )
}

#' @rdname shad_menu_parts
#' @param checked Initial checked state.
#' @export
shad_menu_checkbox_item <- function(value, label, checked = FALSE,
                                    disabled = FALSE) {
  htmltools::tags$button(
    type = "button", class = "shad-menu__item",
    `data-type` = "checkbox",
    `data-state` = if (isTRUE(checked)) "checked" else "unchecked",
    `data-value` = value,
    `data-disabled` = flag_attr(disabled),
    .shad_menu_check, label
  )
}

#' @rdname shad_menu_parts
#' @param ... For [shad_menu_radio_group()], [shad_menu_radio_item()] specs; for
#'   [shad_menu_sub()], the submenu contents.
#' @export
shad_menu_radio_group <- function(value = NULL, ...) {
  items <- list(...)
  gid <- shad_uid("menuradio")
  htmltools::tagList(lapply(items, function(it) {
    htmltools::tags$button(
      type = "button", class = "shad-menu__item",
      `data-type` = "radio", `data-group` = gid,
      `data-state` = if (!is.null(value) &&
                         identical(as.character(it$value), as.character(value))) {
        "checked"
      } else {
        "unchecked"
      },
      `data-value` = it$value,
      `data-disabled` = flag_attr(isTRUE(it$disabled)),
      .shad_menu_dot,
      if (is.null(it$label)) it$value else it$label
    )
  }))
}

#' @rdname shad_menu_parts
#' @export
shad_menu_radio_item <- function(value, label = NULL, disabled = FALSE) {
  list(value = value, label = label, disabled = disabled)
}

#' @rdname shad_menu_parts
#' @export
shad_menu_label <- function(...) {
  htmltools::tags$div(class = "shad-menu__label", ...)
}

#' @rdname shad_menu_parts
#' @export
shad_menu_separator <- function() {
  htmltools::tags$div(class = "shad-menu__separator")
}

#' @rdname shad_menu_parts
#' @param trigger_label Submenu trigger text.
#' @export
shad_menu_sub <- function(trigger_label, ..., icon = NULL) {
  htmltools::tags$div(
    `data-shad-submenu` = NA,
    htmltools::tags$button(
      type = "button", class = "shad-menu__item",
      `data-shad-submenu-trigger` = NA, `aria-haspopup` = "menu",
      `aria-expanded` = "false", `data-state` = "closed",
      resolve_icon(icon),
      trigger_label,
      .shad_menu_chevron
    ),
    htmltools::tags$div(class = "shad-menu__content shad-anim-pop", hidden = NA, ...)
  )
}
