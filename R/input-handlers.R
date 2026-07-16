# Shiny input handlers --------------------------------------------------------

# Registered in .onLoad. Deserializes the wire values that need R-side coercion.
# Everything else arrives as the natural JSON->R type (logical, numeric, chr,
# named list) and needs no handler.
#' @noRd
register_shad_input_handlers <- function() {
  # calendar / date-picker: ISO date string, or length-2 vector for ranges.
  shiny::registerInputHandler("shadshiny.date", function(value, session, name) {
    if (is.null(value) || length(value) == 0) return(NULL)
    parts <- unlist(value, use.names = FALSE)
    parts[parts == ""] <- NA
    as.Date(parts)
  }, force = TRUE)

  # stepper: JS reports a 0-based active index; expose it 1-based in R.
  shiny::registerInputHandler("shadshiny.step1", function(value, session, name) {
    if (is.null(value) || length(value) == 0) return(NULL)
    as.integer(value[[1]]) + 1L
  }, force = TRUE)

  # data-table: compound interaction state {selected, sort, filter, page,
  # pageSize}. Normalise `selected` to a plain character vector (JSON delivers
  # an empty array as list()) and spell out the sort keys; leave the rest as the
  # natural nested list so `input$tbl$filter`, `input$tbl$page`, etc. read
  # cleanly.
  shiny::registerInputHandler("shadshiny.dataTable", function(value, session, name) {
    if (is.null(value)) return(NULL)
    sel <- value$selected
    value$selected <- if (is.null(sel) || length(sel) == 0) {
      character(0)
    } else {
      as.character(unlist(sel, use.names = FALSE))
    }
    # The client emits sort keys as {col, dir}; spell them out for R users.
    value$sort <- lapply(value$sort, function(k) {
      list(column = k$col, direction = k$dir)
    })
    value
  }, force = TRUE)

  invisible(NULL)
}
