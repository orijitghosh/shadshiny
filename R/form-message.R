# form-message -----------------------------------------------------------------

#' Form validation message
#'
#' A field-level validation line (error / success / warning / info) or a
#' right-aligned character counter, matching shadcn's form messaging. Place
#' inside a [shad_form_field()] after the control. For server-driven errors,
#' prefer [update_shad_form_field()] / the [shad_validator()] framework, which
#' create and remove these for you.
#'
#' @param message The message text (or tags).
#' @param type `"info"` (default, muted), `"error"`, `"success"`, or
#'   `"warning"`.
#' @param icon If `TRUE` (default), show the type's leading icon.
#' @param id Optional id (point the control's `aria-describedby` at it).
#' @param class Extra CSS classes.
#' @returns A form-message tag.
#' @family shadshiny forms
#' @examples
#' shad_form_message("Enter a valid email address.", type = "error")
#' shad_form_message("Username is available.", type = "success")
#' @export
shad_form_message <- function(message, type = c("info", "error", "success", "warning"),
                              icon = TRUE, id = NULL, class = NULL) {
  type <- arg_match_shad(type, c("info", "error", "success", "warning"), "type")
  mod <- switch(type,
    error = "shad-form-message--error",
    success = "shad-form-message--success",
    warning = "shad-form-message--warning",
    NULL)
  glyph <- if (isTRUE(icon)) {
    switch(type,
      error = .svg("alert_circle"),
      success = .svg("check_plain"),
      warning = .svg("triangle"),
      info = .svg("alert_circle"))
  }
  with_deps(htmltools::tags$div(
    class = shad_class("shad-form-message", mod, extra = class),
    id = id, glyph, message
  ))
}

#' Character counter message
#'
#' @param current Current character count.
#' @param max Maximum allowed.
#' @param id Optional id.
#' @returns A counter form-message tag.
#' @family shadshiny forms
#' @examples
#' shad_form_counter(42, 280)
#' @export
shad_form_counter <- function(current, max, id = NULL) {
  with_deps(htmltools::tags$div(
    class = "shad-form-message shad-form-message--counter",
    id = id,
    `data-state` = if (current > max) "over" else NULL,
    paste0(current, "/", max)
  ))
}

#' Form error summary
#'
#' A `role="alert"` box listing field errors with anchor links to each field.
#' Place it above the form and move focus to it on a failed submit. Populated by
#' hand, or via [shad_validator()]'s `bind_summary()`.
#'
#' @param id Element id (targeted by the validator).
#' @param title Summary heading (e.g. `"2 fields need attention"`).
#' @param errors Optional named character vector `c(field_id = "message")`; each
#'   becomes a link to `#field_id`.
#' @param class Extra CSS classes.
#' @returns A form-summary tag.
#' @family shadshiny forms
#' @examples
#' shad_form_summary(
#'   "errs", "2 fields need attention",
#'   errors = c(email = "Email is not valid", pw = "Password too short")
#' )
#' @export
shad_form_summary <- function(id, title = "Please fix the errors below",
                              errors = NULL, class = NULL) {
  items <- if (!is.null(errors)) {
    lapply(seq_along(errors), function(i) {
      htmltools::tags$li(
        htmltools::tags$a(href = paste0("#", names(errors)[i]), errors[[i]])
      )
    })
  }
  with_deps(htmltools::tags$div(
    class = shad_class("shad-form-summary", extra = class),
    id = id, role = "alert",
    htmltools::tags$div(
      class = "shad-form-summary__title",
      .svg("alert_circle"), title
    ),
    if (length(items)) do.call(htmltools::tags$ul, c(list(class = "shad-form-summary__list"), items))
  ))
}

#' Set or clear a field's error state from the server
#'
#' Pushes a shadcn error message into the [shad_form_field()] wrapping a control,
#' toggling `data-invalid`, `aria-invalid`, and `aria-describedby` and
#' creating/removing the message element. This is the primitive that
#' [shad_validator()] and shinyvalidate bridges build on.
#'
#' @param inputId The bound control's id (namespaced automatically).
#' @param error Error text to show, or `NULL` to clear.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny forms
#' @examples
#' if (interactive()) {
#'   ui <- page_shad(
#'     shad_form_field(shad_input("email"), label = "Email", inputId = "email"),
#'     shad_button("Check", inputId = "check")
#'   )
#'   server <- function(input, output, session) {
#'     shiny::observeEvent(input$check, {
#'       ok <- grepl("@", input$email, fixed = TRUE)
#'       update_shad_form_field("email", if (!ok) "Enter a valid email address.")
#'     })
#'   }
#'   shiny::shinyApp(ui, server)
#' }
#' @export
update_shad_form_field <- function(inputId, error = NULL,
                                   session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("shadshiny:formField", list(
    id = session$ns(inputId),
    error = if (is.null(error)) NULL else as.character(error)
  ))
  invisible(NULL)
}
