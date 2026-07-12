# Menu components: dropdown-menu, context-menu, menubar ------------------------
# All share the menu part constructors in R/tier3-menu-parts.R. `input$<id>` is
# the value of the last activated item.

#' Dropdown menu
#'
#' A button-triggered menu. `input$<inputId>` is the value of the last activated
#' item. Compose contents from the [shad_menu_parts].
#'
#' @param inputId Input id.
#' @param trigger The tag that opens the menu.
#' @param ... Menu parts (items, separators, labels, submenus).
#' @param side `"bottom"` (default), `"top"`, `"right"`, `"left"`.
#' @param align `"start"` (default), `"center"`, `"end"`.
#' @param class Extra CSS classes.
#' @returns A dropdown-menu tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_dropdown_menu("m", trigger = shad_button("Open"),
#'   shad_menu_label("My Account"), shad_menu_separator(),
#'   shad_menu_item("profile", "Profile", shortcut = "⇧⌘P"))
#' @export
shad_dropdown_menu <- function(inputId, trigger, ...,
                               side = c("bottom", "top", "right", "left"),
                               align = c("start", "center", "end"),
                               class = NULL) {
  side <- arg_match_shad(side, c("bottom", "top", "right", "left"), "side")
  align <- arg_match_shad(align, c("start", "center", "end"), "align")
  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "dropdown-menu",
    `data-side` = if (side != "bottom") side else NULL,
    `data-align` = align,
    id = inputId, style = "display:inline-block",
    .shad_as_trigger(trigger, "shad-menu__trigger"),
    htmltools::tags$div(class = "shad-menu__content shad-anim-pop", hidden = NA, ...)
  ))
}

#' Context menu
#'
#' A right-click menu over a target area. `input$<inputId>` is the value of the
#' last activated item.
#'
#' @param inputId Input id.
#' @param target The right-clickable content.
#' @param ... Menu parts.
#' @param class Extra CSS classes.
#' @returns A context-menu tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_context_menu("cm", target = htmltools::div("Right click here"),
#'   shad_menu_item("back", "Back"), shad_menu_item("reload", "Reload"))
#' @export
shad_context_menu <- function(inputId, target, ..., class = NULL) {
  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "context-menu", id = inputId,
    htmltools::tags$div(class = "shad-context-menu__zone", target),
    htmltools::tags$div(class = "shad-menu__content shad-anim-pop", hidden = NA, ...)
  ))
}

#' Menubar
#'
#' A horizontal application menubar. `input$<inputId>` is the value of the last
#' activated item across all menus.
#'
#' @param inputId Input id.
#' @param ... One or more [shad_menubar_menu()].
#' @param class Extra CSS classes.
#' @returns A menubar tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_menubar("mb",
#'   shad_menubar_menu("File", shad_menu_item("new-tab", "New tab")),
#'   shad_menubar_menu("Edit", shad_menu_item("undo", "Undo")))
#' @export
shad_menubar <- function(inputId, ..., class = NULL) {
  with_deps(htmltools::tags$div(
    class = shad_class("shad-menubar", extra = class),
    `data-shad` = "menubar", id = inputId, ...
  ))
}

#' @rdname shad_menubar
#' @param label Top-level menu label.
#' @export
shad_menubar_menu <- function(label, ...) {
  htmltools::tags$div(
    `data-shad-menubar-menu` = NA,
    htmltools::tags$button(type = "button", class = "shad-menubar__trigger", label),
    htmltools::tags$div(class = "shad-menu__content shad-anim-pop", hidden = NA, ...)
  )
}
