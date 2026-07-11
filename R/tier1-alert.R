#' Alert
#'
#' A callout banner with an optional icon.
#'
#' @param title Alert title. Optional.
#' @param ... Description content (and optional named attributes).
#' @param variant One of `"default"`, `"destructive"`.
#' @param icon Optional icon (a [shad_icon()] name or tag). Rendered with the
#'   `shad-alert__icon` class.
#' @param class Extra CSS classes.
#' @returns A `<div role="alert">`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_alert("Heads up!", "You can add components via the CLI.", icon = "terminal")
#' shad_alert("Error", "Session expired.", variant = "destructive",
#'            icon = "circle-alert")
#' @export
shad_alert <- function(title = NULL, ..., variant = c("default", "destructive"),
                       icon = NULL, class = NULL) {
  variant <- arg_match_shad(variant, c("default", "destructive"), "variant")
  variant_class <- if (variant == "destructive") "shad-alert--destructive" else NULL
  icon_tag <- resolve_icon(icon, class = "shad-alert__icon")

  dots <- split_dots(...)
  description <- if (length(dots$children)) {
    htmltools::tags$div(class = "shad-alert__description", dots$children)
  }
  title_tag <- if (!is.null(title)) {
    htmltools::tags$div(class = "shad-alert__title", title)
  }

  with_deps(do.call(htmltools::tags$div, c(
    list(class = shad_class("shad-alert", variant_class, extra = class), role = "alert"),
    dots$attribs,
    drop_nulls(list(icon_tag, title_tag, description))
  )))
}
