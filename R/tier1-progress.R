#' Progress bar
#'
#' A determinate or indeterminate progress indicator.
#'
#' @param value Current value (`0`..`max`), or `NULL` for indeterminate.
#' @param max Maximum value. Default `100`.
#' @param indeterminate If `TRUE`, renders the indeterminate animation.
#'   Defaults to `TRUE` when `value` is `NULL`.
#' @param inputId Optional id (enables [update_shad_progress()]).
#' @param label Accessible label (used for indeterminate bars).
#' @param class Extra CSS classes.
#' @param ... Extra attributes.
#' @returns A `<div class="shad-progress" role="progressbar">`.
#' @family shadshiny tier-1 components
#' @seealso [update_shad_progress()]
#' @examples
#' shad_progress(60)
#' shad_progress(indeterminate = TRUE)
#' @export
shad_progress <- function(value = NULL, max = 100, indeterminate = is.null(value),
                          inputId = NULL, label = "Loading", class = NULL, ...) {
  if (isTRUE(indeterminate)) {
    with_deps(htmltools::tags$div(
      id = inputId,
      class = shad_class("shad-progress", extra = class),
      role = "progressbar", `data-state` = "indeterminate", `aria-label` = label, ...,
      htmltools::tags$div(class = "shad-progress__indicator")
    ))
  } else {
    pct <- max(0, min(100, 100 * value / max))
    state <- if (pct >= 100) "complete" else "loading"
    with_deps(htmltools::tags$div(
      id = inputId,
      class = shad_class("shad-progress", extra = class),
      role = "progressbar", `aria-valuemin` = "0", `aria-valuemax` = as.character(max),
      `aria-valuenow` = as.character(value), `data-state` = state, ...,
      htmltools::tags$div(
        class = "shad-progress__indicator",
        style = sprintf("transform: translateX(-%s%%);", format(100 - pct, digits = 6))
      )
    ))
  }
}
