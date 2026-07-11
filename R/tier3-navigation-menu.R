# navigation-menu --------------------------------------------------------------

.shad_nav_chevron <- htmltools::HTML(paste0(
  '<svg class="shad-nav-menu__chevron" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>'
))

#' Navigation menu
#'
#' A horizontal navigation bar with animated dropdown panels. Not a Shiny input
#' by default.
#'
#' @param inputId Optional input id.
#' @param ... One or more [shad_navigation_menu_item()].
#' @param class Extra CSS classes.
#' @returns A navigation-menu tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_navigation_menu("nav",
#'   shad_navigation_menu_item("Docs", href = "#"),
#'   shad_navigation_menu_item("Components", htmltools::a(href = "#", "Dialog")))
#' @export
shad_navigation_menu <- function(inputId = NULL, ..., class = NULL) {
  items <- list(...)
  with_deps(htmltools::tags$nav(
    class = shad_class("shad-nav-menu", extra = class),
    `data-shad` = "navigation-menu", id = inputId, `aria-label` = "Main",
    do.call(htmltools::tags$ul, c(list(class = "shad-nav-menu__list"), items)),
    htmltools::tags$div(class = "shad-nav-menu__viewport", hidden = NA)
  ))
}

#' @rdname shad_navigation_menu
#' @param label Item label.
#' @param href If supplied (and no `...` panel content), renders a plain link.
#' @export
shad_navigation_menu_item <- function(label, ..., href = NULL) {
  panel <- list(...)
  if (!length(panel) && !is.null(href)) {
    return(htmltools::tags$li(
      htmltools::tags$a(class = "shad-nav-menu__link", href = href, label)
    ))
  }
  htmltools::tags$li(
    `data-shad-nav-item` = NA,
    htmltools::tags$button(
      type = "button", class = "shad-nav-menu__trigger", `data-state` = "closed",
      label, .shad_nav_chevron
    ),
    htmltools::tags$div(
      class = "shad-nav-menu__panel", hidden = NA,
      do.call(htmltools::tags$div, c(list(class = "shad-nav-menu__grid"), panel))
    )
  )
}
