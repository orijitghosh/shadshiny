# A minimal fake Shiny session that records custom messages, letting the
# server-side API be tested offline (no browser, no reactive domain).
new_fake_session <- function(ns_prefix = NULL) {
  self <- new.env(parent = emptyenv())
  self$messages <- list()
  self$ns <- function(id) if (is.null(ns_prefix)) id else paste0(ns_prefix, "-", id)
  self$sendCustomMessage <- function(type, message) {
    self$messages[[length(self$messages) + 1L]] <- list(type = type, message = message)
    invisible(TRUE)
  }
  self
}

# Convenience: the single message sent by `expr`, erroring if not exactly one.
one_message <- function(session) {
  testthat::expect_length(session$messages, 1L)
  session$messages[[1L]]
}

# Render a tag to a parsed xml2 node for structural assertions.
render_xml <- function(tag) {
  xml2::read_html(paste0("<!DOCTYPE html><html><body>",
                         as.character(tag), "</body></html>"))
}
