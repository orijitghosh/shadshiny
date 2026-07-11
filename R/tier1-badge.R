#' Badge
#'
#' A small status/label pill.
#'
#' @param label Badge text.
#' @param variant One of `"default"`, `"secondary"`, `"destructive"`,
#'   `"outline"`.
#' @param icon Optional leading icon (a [shad_icon()] name or a tag).
#' @param class Extra CSS classes.
#' @param ... Extra attributes or child tags.
#'
#' @returns A `<span>` tag.
#' @family shadshiny tier-1 components
#' @examples
#' shad_badge("New")
#' shad_badge("Verified", icon = "check")
#' @export
shad_badge <- function(label = NULL,
                       variant = c("default", "secondary", "destructive", "outline"),
                       icon = NULL, class = NULL, ...) {
  variant <- arg_match_shad(variant, c("default", "secondary", "destructive", "outline"),
                            "variant")
  icon_tag <- resolve_icon(icon)
  with_deps(htmltools::tags$span(
    class = shad_class("shad-badge", paste0("shad-badge--", variant), extra = class),
    icon_tag, label, ...
  ))
}
