# empty ------------------------------------------------------------------------

#' Empty state
#'
#' A centred empty-state panel for "no data", search-miss, or 404 screens.
#' Compose a media slot (icon or illustration), a title, a description, and an
#' optional actions area.
#'
#' @param title The empty-state title.
#' @param description Optional supporting text (may contain links/tags).
#' @param media Optional [shad_icon()] name or a tag (icon, image, avatar)
#'   shown above the title.
#' @param media_variant `"icon"` (rounded muted tile) or `"default"`
#'   (free-form illustration). Ignored when `media` is `NULL`.
#' @param content Optional actions area – buttons, an input, links.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns An empty-state tag.
#' @family shadshiny tier-1 components
#' @examples
#' shad_empty(
#'   "No projects yet",
#'   description = "Create your first project to get started.",
#'   media = "folder", media_variant = "icon",
#'   content = shad_button("New project")
#' )
#' @export
shad_empty <- function(title, description = NULL, media = NULL,
                       media_variant = c("default", "icon"), content = NULL,
                       class = NULL, ...) {
  media_variant <- match.arg(media_variant)
  media_tag <- if (!is.null(media)) {
    htmltools::tags$div(
      class = shad_class("shad-empty__media", paste0("shad-empty__media--", media_variant)),
      `aria-hidden` = "true",
      resolve_icon(media)
    )
  }

  htmltools::tags$div(
    class = shad_class("shad-empty", extra = class),
    ...,
    htmltools::tags$div(
      class = "shad-empty__header",
      media_tag,
      htmltools::tags$div(class = "shad-empty__title", title),
      if (!is.null(description)) {
        htmltools::tags$div(class = "shad-empty__description", description)
      }
    ),
    if (!is.null(content)) htmltools::tags$div(class = "shad-empty__content", content)
  ) |> with_deps()
}
