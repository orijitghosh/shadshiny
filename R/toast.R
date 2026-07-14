# Toast API --------------------------------------------------------------------
# Imperative, server-driven (no UI constructor). Mirrors the JS shad.toast()
# family via the `shadshiny:toast` message. R can't read shad.toast()'s return
# id synchronously, so we generate a caller id here and the JS handler maps it
# to the internal toast id for later update/dismiss.

.shad_toast_variants <- c("default", "success", "error", "warning", "loading")

# Build the `opts` payload shared by toast() and toast_update().
.shad_toast_opts <- function(message, title, description, variant, duration,
                             action_label, action_input) {
  action <- if (!is.null(action_label)) {
    list(label = action_label, input = action_input)
  }
  drop_nulls(list(
    message = message,
    title = title %||% message,
    description = description,
    variant = if (!is.null(variant) && variant != "default") variant else NULL,
    duration = duration,
    action = action
  ))
}

#' Show a toast notification
#'
#' Sonner-style imperative toasts, driven from the server. Returns the toast id
#' so you can later [shad_toast_update()] or [shad_toast_dismiss()] it (e.g. a
#' loading toast that resolves to success).
#'
#' Text is injected client-side via `textContent`; pass plain strings, not HTML.
#' There is no R analogue of `shad.toast.promise()` — use the loading →
#' [shad_toast_update()] flow instead.
#'
#' @param message Main message text (used as the title if `title` is `NULL`).
#' @param title,description Optional title / secondary line.
#' @param variant One of `"default"`, `"success"`, `"error"`, `"warning"`,
#'   `"loading"`. `"loading"` toasts never auto-dismiss until updated.
#' @param duration Auto-dismiss delay in ms (default 5000).
#' @param id Toast id. Generated if `NULL`.
#' @param action_label Optional action-button label.
#' @param action_input Input id set (to `Date.now()`) when the action is
#'   clicked, giving the server a reactive hook. Defaults to `<id>_action`.
#' @param session The Shiny session.
#' @returns The toast id (character), invisibly.
#' @family shadshiny server API
#' @examples
#' \dontrun{
#' shad_toast("Saved", variant = "success")
#' id <- shad_toast_loading("Uploading...")
#' shad_toast_update(id, message = "Uploaded", variant = "success")
#' }
#' @export
shad_toast <- function(message = NULL, title = NULL, description = NULL,
                       variant = c("default", "success", "error", "warning",
                                   "loading"),
                       duration = 5000, id = NULL, action_label = NULL,
                       action_input = NULL,
                       session = shiny::getDefaultReactiveDomain()) {
  variant <- arg_match_shad(variant, .shad_toast_variants, "variant")
  if (is.null(id)) id <- shad_uid("toast")
  if (!is.null(action_label) && is.null(action_input)) {
    action_input <- session$ns(paste0(id, "_action"))
  }
  opts <- .shad_toast_opts(message, title, description, variant, duration,
                           action_label, action_input)
  session$sendCustomMessage("shadshiny:toast", list(
    kind = variant, id = id, opts = opts
  ))
  invisible(id)
}

#' @rdname shad_toast
#' @param ... Passed to [shad_toast()].
#' @export
shad_toast_success <- function(message, ...) {
  shad_toast(message, variant = "success", ...)
}
#' @rdname shad_toast
#' @export
shad_toast_error <- function(message, ...) {
  shad_toast(message, variant = "error", ...)
}
#' @rdname shad_toast
#' @export
shad_toast_warning <- function(message, ...) {
  shad_toast(message, variant = "warning", ...)
}
#' @rdname shad_toast
#' @export
shad_toast_loading <- function(message, ...) {
  # loading toasts never auto-dismiss; omit duration entirely.
  shad_toast(message, variant = "loading", duration = NULL, ...)
}

#' @rdname shad_toast
#' @export
shad_toast_update <- function(id, message = NULL, title = NULL,
                              description = NULL, variant = NULL, duration = NULL,
                              action_label = NULL, action_input = NULL,
                              session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(variant)) {
    variant <- arg_match_shad(variant, .shad_toast_variants, "variant")
  }
  if (!is.null(action_label) && is.null(action_input)) {
    action_input <- session$ns(paste0(id, "_action"))
  }
  opts <- .shad_toast_opts(message, title, description, variant, duration,
                           action_label, action_input)
  session$sendCustomMessage("shadshiny:toast", list(
    kind = "update", id = id, opts = opts
  ))
  invisible(id)
}

#' @rdname shad_toast
#' @export
shad_toast_dismiss <- function(id = NULL,
                               session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("shadshiny:toast", list(
    kind = "dismiss", id = id, opts = list()
  ))
  invisible(NULL)
}
