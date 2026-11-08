# ExtendedTask button integration ---------------------------------------------

.shad_task_button_states <- c("initial", "running", "success", "error")

.shad_task_button_registry <- new.env(parent = emptyenv())
.shad_task_button_registry$items <- list()

.shad_task_button_label <- function(value, name) {
  if (is.null(value)) return(NULL)
  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    stop(name, " must be NULL or one non-missing character value.", call. = FALSE)
  }
  value
}

.shad_task_button_patch <- function(status, label_busy = "Processing...",
                                    label_success = NULL, label_error = NULL) {
  if (!is.character(status) || length(status) != 1L || is.na(status) ||
      !status %in% .shad_task_button_states) {
    stop(
      "task$status() must return one of initial, running, success, or error.",
      call. = FALSE
    )
  }
  switch(status,
    initial = list(loading = FALSE, disabled = FALSE, label = NULL),
    running = list(loading = TRUE, disabled = TRUE, label = label_busy),
    success = list(loading = FALSE, disabled = FALSE, label = label_success),
    error = list(loading = FALSE, disabled = FALSE, label = label_error)
  )
}

.validate_extended_task <- function(task) {
  status <- tryCatch(task$status, error = function(error) NULL)
  if (!is.function(status)) {
    stop("`task` must provide a callable `$status()` member.", call. = FALSE)
  }
  invisible(task)
}

.shad_task_button_find <- function(task, id, session) {
  items <- .shad_task_button_registry$items
  which(vapply(items, function(item) {
    identical(item$task, task) && identical(item$id, id) &&
      identical(item$session, session)
  }, logical(1)))
}

.shad_task_button_remove <- function(observer) {
  items <- .shad_task_button_registry$items
  if (!length(items)) return(invisible(NULL))
  keep <- !vapply(items, function(item) identical(item$observer, observer), logical(1))
  .shad_task_button_registry$items <- items[keep]
  invisible(NULL)
}

#' Bind an ExtendedTask status to a shadshiny button
#'
#' Experimental.
#' Observes a compatible Shiny [shiny::ExtendedTask] status function and maps
#' its lifecycle to [update_shad_button()]. The task remains application-owned;
#' this helper does not invoke the task, inspect its result, or create an async
#' backend.
#'
#' @param task An object with a callable `$status()` member returning
#'   `"initial"`, `"running"`, `"success"`, or `"error"`.
#' @param id Button input id.
#' @param label_busy Label while the task is running.
#' @param label_success Optional label after success.
#' @param label_error Optional label after an error.
#' @param session The Shiny session.
#' @returns Invisibly, the observer driving the binding.
#' @family shadshiny server API
#' @examples
#' if (interactive()) {
#'   ui <- page_shad(
#'     shad_button("Run report", inputId = "run"),
#'     shad_button("Finish", inputId = "finish", variant = "outline")
#'   )
#'   server <- function(input, output, session) {
#'     # Usually a shiny::ExtendedTask; any object with a $status() works.
#'     state <- shiny::reactiveVal("initial")
#'     task <- list(status = function() state())
#'     bind_shad_task_button(task, "run", label_success = "Done")
#'     shiny::observeEvent(input$run, state("running"))
#'     shiny::observeEvent(input$finish, state("success"))
#'   }
#'   shiny::shinyApp(ui, server)
#' }
#' @export
bind_shad_task_button <- function(
    task, id, label_busy = "Processing...", label_success = NULL,
    label_error = NULL, session = shiny::getDefaultReactiveDomain()) {
  .validate_extended_task(task)
  if (!is.character(id) || length(id) != 1L || is.na(id)) {
    stop("`id` must be one non-missing character value.", call. = FALSE)
  }
  label_busy <- .shad_task_button_label(label_busy, "label_busy")
  label_success <- .shad_task_button_label(label_success, "label_success")
  label_error <- .shad_task_button_label(label_error, "label_error")

  previous <- .shad_task_button_find(task, id, session)
  if (length(previous)) {
    .shad_task_button_registry$items[[previous[[1L]]]]$observer$destroy()
    .shad_task_button_registry$items <-
      .shad_task_button_registry$items[-previous[[1L]]]
  }

  observer <- shiny::observe({
    patch <- .shad_task_button_patch(
      task$status(), label_busy, label_success, label_error
    )
    do.call(update_shad_button, c(list(id = id, session = session), patch))
  })

  .shad_task_button_registry$items <- c(
    .shad_task_button_registry$items,
    list(list(task = task, id = id, session = session, observer = observer))
  )
  session$onSessionEnded(function() {
    observer$destroy()
    .shad_task_button_remove(observer)
  })
  invisible(observer)
}
