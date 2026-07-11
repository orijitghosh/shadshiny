#' Card
#'
#' A content container. Compose with [shad_card_header()],
#' [shad_card_title()], [shad_card_description()], [shad_card_action()],
#' [shad_card_content()] and [shad_card_footer()].
#'
#' @param ... Card sections (and optional named attributes).
#' @param class Extra CSS classes.
#' @returns A `<div class="shad-card">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_card(
#'   shad_card_header(
#'     shad_card_title("Create project"),
#'     shad_card_description("Deploy in one click.")
#'   ),
#'   shad_card_content("Body"),
#'   shad_card_footer(shad_button("Deploy"))
#' )
#' @export
shad_card <- function(..., class = NULL) {
  with_deps(htmltools::tags$div(class = shad_class("shad-card", extra = class), ...))
}

#' @rdname shad_card
#' @export
shad_card_header <- function(..., class = NULL) {
  htmltools::tags$div(class = shad_class("shad-card__header", extra = class), ...)
}

#' @rdname shad_card
#' @export
shad_card_title <- function(..., class = NULL) {
  htmltools::tags$div(class = shad_class("shad-card__title", extra = class), ...)
}

#' @rdname shad_card
#' @export
shad_card_description <- function(..., class = NULL) {
  htmltools::tags$div(class = shad_class("shad-card__description", extra = class), ...)
}

#' @rdname shad_card
#' @export
shad_card_action <- function(..., class = NULL) {
  htmltools::tags$div(class = shad_class("shad-card__action", extra = class), ...)
}

#' @rdname shad_card
#' @export
shad_card_content <- function(..., class = NULL) {
  htmltools::tags$div(class = shad_class("shad-card__content", extra = class), ...)
}

#' @rdname shad_card
#' @export
shad_card_footer <- function(..., class = NULL) {
  htmltools::tags$div(class = shad_class("shad-card__footer", extra = class), ...)
}
