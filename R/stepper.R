# stepper ----------------------------------------------------------------------

.stepper_indicator <- function(n) {
  htmltools::tags$span(
    class = "shad-stepper__indicator",
    htmltools::tags$span(class = "shad-stepper__number", n),
    .svg("check", "shad-stepper__check"),
    .svg("x", "shad-stepper__x")
  )
}

#' Stepper
#'
#' A multi-step progress indicator with optional content panels. A bound Shiny
#' input: `input$<inputId>` is the active step index (1-based). Compose from
#' [shad_step()] children.
#'
#' @param inputId Input id.
#' @param ... [shad_step()] entries.
#' @param active Initial active step (1-based).
#' @param orientation `"horizontal"` (default) or `"vertical"`.
#' @param linear If `TRUE`, steps beyond the first incomplete one are gated
#'   (not clickable).
#' @param clickable If `TRUE`, step triggers are interactive.
#' @param class Extra CSS classes.
#' @returns A stepper tag, bound as a Shiny input.
#' @family shadshiny flow
#' @examples
#' shad_stepper(
#'   "wizard",
#'   shad_step("Account", description = "Email + password"),
#'   shad_step("Profile"),
#'   shad_step("Review"),
#'   active = 1
#' )
#' @export
shad_stepper <- function(inputId, ..., active = 1,
                         orientation = c("horizontal", "vertical"),
                         linear = FALSE, clickable = TRUE, class = NULL) {
  orientation <- arg_match_shad(orientation, c("horizontal", "vertical"), "orientation")
  active <- shiny::restoreInput(id = inputId, default = active)
  active <- as.integer(active)[[1]]

  steps <- list(...)
  steps <- steps[vapply(steps, function(s) inherits(s, "shad_step"), logical(1))]
  n <- length(steps)

  items <- lapply(seq_along(steps), function(i) {
    s <- steps[[i]]
    trigger <- htmltools::tags$button(
      type = "button", class = "shad-stepper__trigger",
      .stepper_indicator(i),
      htmltools::tags$span(
        class = "shad-stepper__meta",
        htmltools::tags$span(class = "shad-stepper__label", s$title),
        if (!is.null(s$description)) {
          htmltools::tags$span(class = "shad-stepper__description", s$description)
        }
      )
    )
    connector <- if (i < n) {
      htmltools::tags$span(class = "shad-stepper__connector", `aria-hidden` = "true")
    }
    htmltools::tags$li(
      class = "shad-stepper__item",
      `data-state` = if (isTRUE(s$error)) "error" else NULL,
      trigger, connector
    )
  })

  panels <- lapply(steps, function(s) s$content)
  has_panels <- any(!vapply(panels, is.null, logical(1)))
  panels_tag <- if (has_panels) {
    do.call(htmltools::tags$div, c(
      list(class = "shad-stepper__panels"),
      lapply(panels, function(p) htmltools::tags$div(class = "shad-stepper__panel", p))
    ))
  }

  root <- htmltools::tags$div(
    class = shad_class("shad-stepper", extra = class),
    id = inputId,
    `data-shad` = "stepper",
    `data-orientation` = orientation,
    `data-active` = active - 1L,
    `data-linear` = flag_attr(linear),
    `data-clickable` = flag_attr(clickable),
    do.call(htmltools::tags$ol, c(list(class = "shad-stepper__list"), items)),
    panels_tag
  )
  with_deps(root)
}

#' A stepper step
#'
#' @param title Step label.
#' @param description Optional secondary line.
#' @param content Optional panel content shown when the step is active.
#' @param error If `TRUE`, seed the step in an error state.
#' @returns A `shad_step` object consumed by [shad_stepper()].
#' @family shadshiny flow
#' @export
shad_step <- function(title, description = NULL, content = NULL, error = FALSE) {
  structure(
    list(title = title, description = description, content = content,
         error = isTRUE(error)),
    class = "shad_step"
  )
}

#' Update a stepper from the server
#'
#' @param id Input id (namespaced automatically).
#' @param active Optional new active step (1-based).
#' @param error Optional named list mapping step index (1-based) to a logical:
#'   `TRUE` marks that step as an error, `FALSE` clears it.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny flow
#' @export
update_shad_stepper <- function(id, active = NULL, error = NULL,
                                session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(active)) {
    shad_invoke(id, "goTo", list(as.integer(active) - 1L), session)
  }
  if (!is.null(error)) {
    for (k in names(error)) {
      shad_invoke(id, "setError", list(as.integer(k) - 1L, isTRUE(error[[k]])), session)
    }
  }
  invisible(NULL)
}
