# carousel ---------------------------------------------------------------------

.shad_carousel_prev <- htmltools::HTML(paste0(
  '<svg class="shad-icon shad-icon--directional" data-direction="back" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ',
  'aria-hidden="true"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>'
))
.shad_carousel_next <- htmltools::HTML(paste0(
  '<svg class="shad-icon shad-icon--directional" data-direction="forward" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ',
  'aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>'
))

#' Carousel
#'
#' A scroll-snap carousel. When `inputId` is set, `input$<inputId>` is the
#' current slide index (1-based).
#'
#' @param inputId Optional input id (binds the current slide when set).
#' @param ... One or more [shad_carousel_item()].
#' @param show_dots If `TRUE` (default), render the dot indicators.
#' @param show_arrows If `TRUE` (default), render the prev/next arrows.
#' @param class Extra CSS classes.
#' @returns A carousel tag.
#' @family shadshiny tier-3 components
#' @seealso [update_shad_carousel()]
#' @examples
#' shad_carousel("c",
#'   shad_carousel_item("Slide 1"), shad_carousel_item("Slide 2"))
#' @export
shad_carousel <- function(inputId = NULL, ..., show_dots = TRUE,
                          show_arrows = TRUE, class = NULL) {
  slides <- list(...)
  track <- do.call(htmltools::tags$div,
                   c(list(class = "shad-carousel__track"), slides))

  with_deps(htmltools::tags$div(
    class = shad_class("shad-carousel", extra = class),
    `data-shad` = "carousel", id = inputId, `aria-label` = "Carousel",
    htmltools::tags$div(class = "shad-carousel__viewport", track),
    if (isTRUE(show_arrows)) {
      htmltools::tagList(
        htmltools::tags$button(type = "button", class = "shad-carousel__prev",
                               `aria-label` = "Previous slide", .shad_carousel_prev),
        htmltools::tags$button(type = "button", class = "shad-carousel__next",
                               `aria-label` = "Next slide", .shad_carousel_next)
      )
    },
    if (isTRUE(show_dots)) htmltools::tags$div(class = "shad-carousel__dots")
  ))
}

#' @rdname shad_carousel
#' @export
shad_carousel_item <- function(...) {
  htmltools::tags$div(class = "shad-carousel__slide", ...)
}
