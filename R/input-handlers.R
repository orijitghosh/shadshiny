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

  invisible(NULL)
}
