# rating -----------------------------------------------------------------------

#' Star rating
#'
#' A star-rating input. A bound Shiny input: `input$<inputId>` is the numeric
#' rating (0 = unset). Stars are built client-side; half steps are supported.
#'
#' @param inputId Input id.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param value Initial rating (0 = unset).
#' @param max Number of stars.
#' @param half If `TRUE`, allow half-star (0.5) steps.
#' @param readonly If `TRUE`, render display-only (no tab stops; `role="img"`).
#' @param size `"md"` (default), `"sm"`, or `"lg"`.
#' @param disabled If `TRUE`, disable the control.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns A rating tag, bound as a Shiny input.
#' @family shadshiny flow
#' @examples
#' shad_rating("score", value = 3)
#' shad_rating("precise", value = 4.5, half = TRUE)
#' @export
shad_rating <- function(inputId, label = NULL, value = 0, max = 5, half = FALSE,
                        readonly = FALSE, size = c("md", "sm", "lg"),
                        disabled = FALSE, class = NULL, ...) {
  size <- arg_match_shad(size, c("md", "sm", "lg"), "size")
  value <- shiny::restoreInput(id = inputId, default = value)

  root <- htmltools::tags$div(
    class = shad_class("shad-rating", extra = if (is.null(label)) class),
    id = inputId,
    `data-shad` = "rating",
    role = if (isTRUE(readonly)) "img" else "radiogroup",
    `data-value` = as.numeric(value),
    `data-max` = as.integer(max),
    `data-half` = flag_attr(half),
    `data-readonly` = flag_attr(readonly),
    `data-size` = if (size != "md") size else NULL,
    `data-disabled` = flag_attr(disabled),
    ...
  )

  if (is.null(label)) return(with_deps(root))
  shad_form_field(root, label = label, class = class)
}

#' Update a rating from the server
#'
#' @param id Input id (namespaced automatically).
#' @param value Optional new rating.
#' @param readonly Optional logical toggling display-only mode.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny flow
#' @examples
#' if (interactive()) {
#'   ui <- page_shad(
#'     shad_rating("stars", "Your rating", value = 3),
#'     shad_button("Lock rating", inputId = "lock")
#'   )
#'   server <- function(input, output, session) {
#'     shiny::observeEvent(input$lock, update_shad_rating("stars", readonly = TRUE))
#'   }
#'   shiny::shinyApp(ui, server)
#' }
#' @export
update_shad_rating <- function(id, value = NULL, readonly = NULL,
                               session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(value)) shad_set_value(id, as.numeric(value), session)
  if (!is.null(readonly)) shad_set_attr(id, "data-readonly", isTRUE(readonly), session)
  invisible(NULL)
}
