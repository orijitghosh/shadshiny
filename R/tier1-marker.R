# marker -----------------------------------------------------------------------

#' Conversation marker
#'
#' An inline marker row for chat transcripts: status notes, date dividers, and
#' streaming ("thinking") labels. Part of the chat/AI kit.
#'
#' @param label The marker text.
#' @param icon Optional [shad_icon()] name or a tag, shown before the label
#'   (omitted for `variant = "separator"` unless supplied).
#' @param variant One of `"default"` (inline row), `"border"` (adds a bottom
#'   rule), `"separator"` (centred label with divider lines on both sides).
#' @param streaming If `TRUE`, adds a shimmer sweep over the text and
#'   `role="status"` so updates are announced politely.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns A marker tag.
#' @family shadshiny chat components
#' @examples
#' shad_marker("Conversation started at 9:41 AM", icon = "clock")
#' shad_marker("Today", variant = "separator")
#' shad_marker("Thinking...", streaming = TRUE)
#' @export
shad_marker <- function(label, icon = NULL,
                        variant = c("default", "border", "separator"),
                        streaming = FALSE, class = NULL, ...) {
  variant <- arg_match_shad(variant, c("default", "border", "separator"), "variant")
  icon_tag <- resolve_icon(icon)

  htmltools::tags$div(
    class = shad_class("shad-marker", paste0("shad-marker--", variant),
                       if (isTRUE(streaming)) "shad-marker--shimmer", extra = class),
    role = if (isTRUE(streaming)) "status" else NULL,
    ...,
    if (!is.null(icon_tag)) {
      htmltools::tags$span(class = "shad-marker__icon", `aria-hidden` = "true", icon_tag)
    },
    htmltools::tags$span(class = "shad-marker__content", label)
  ) |> with_deps()
}
