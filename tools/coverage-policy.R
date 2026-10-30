SHADSHINY_COVERAGE_MIN <- 82

coverage_gate <- function(percent, minimum = SHADSHINY_COVERAGE_MIN) {
  if (length(percent) != 1L || !is.numeric(percent) || !is.finite(percent)) {
    stop("coverage must be one finite percentage", call. = FALSE)
  }
  if (percent < minimum) {
    stop(
      sprintf(
        "package coverage %.2f%% is below required %.2f%%",
        percent,
        minimum
      ),
      call. = FALSE
    )
  }
  invisible(percent)
}
