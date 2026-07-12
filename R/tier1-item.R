# item -------------------------------------------------------------------------

#' Item
#'
#' A flexible list-row primitive: media, title/description, and actions in one
#' flex row. Group with [shad_item_group()] and divide with
#' [shad_item_separator()]. Render as a link with `href` for a clickable row.
#'
#' @param title The item's title (or any content for the title slot).
#' @param description Optional secondary text (clamped to two lines).
#' @param media Optional [shad_icon()] name or a tag (icon, image, avatar).
#' @param actions Optional trailing controls (buttons, a switch, a chevron).
#' @param variant One of `"default"` (transparent), `"outline"`, `"muted"`.
#' @param size One of `"default"`, `"sm"`, `"xs"`.
#' @param media_variant `"icon"` (bordered muted tile) or `"image"` (rounded
#'   thumb). Ignored when `media` is `NULL` or free-form (e.g. an avatar).
#' @param header Optional full-width top row.
#' @param footer Optional full-width bottom row.
#' @param href Optional URL; renders the row as `<a class="shad-item">`.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns An item tag.
#' @family shadshiny tier-1 components
#' @examples
#' shad_item("Nightly backup", description = "Runs every day at 02:00 UTC.",
#'           media = "clock", variant = "outline",
#'           actions = shad_button("Configure", variant = "outline", size = "sm"))
#' @export
shad_item <- function(title, description = NULL, media = NULL, actions = NULL,
                      variant = c("default", "outline", "muted"),
                      size = c("default", "sm", "xs"),
                      media_variant = NULL, header = NULL, footer = NULL,
                      href = NULL, class = NULL, ...) {
  variant <- match.arg(variant)
  size <- match.arg(size)
  if (!is.null(media_variant)) arg_match_shad(media_variant, c("icon", "image"), "media_variant")

  variant_class <- if (variant == "default") NULL else paste0("shad-item--", variant)
  size_class <- if (size == "default") NULL else paste0("shad-item--", size)

  media_tag <- if (!is.null(media)) {
    mv <- media_variant %||% (if (is.character(media)) "icon" else NULL)
    htmltools::tags$div(
      class = shad_class("shad-item__media",
                         if (!is.null(mv)) paste0("shad-item__media--", mv)),
      `aria-hidden` = "true",
      resolve_icon(media)
    )
  }

  children <- drop_nulls(list(
    if (!is.null(header)) htmltools::tags$div(class = "shad-item__header", header),
    media_tag,
    htmltools::tags$div(
      class = "shad-item__content",
      htmltools::tags$div(class = "shad-item__title", title),
      if (!is.null(description)) {
        htmltools::tags$div(class = "shad-item__description", description)
      }
    ),
    if (!is.null(actions)) htmltools::tags$div(class = "shad-item__actions", actions),
    if (!is.null(footer)) htmltools::tags$div(class = "shad-item__footer", footer)
  ))

  tag_fn <- if (!is.null(href)) htmltools::tags$a else htmltools::tags$div
  common <- drop_nulls(list(
    class = shad_class("shad-item", variant_class, size_class, extra = class),
    href = href
  ))
  root <- do.call(tag_fn, c(common, list(...), children))
  with_deps(root)
}

#' @rdname shad_item
#' @param role ARIA role for the group container (default `"list"`); items keep
#'   `role="listitem"`.
#' @export
shad_item_group <- function(..., role = "list", class = NULL) {
  with_deps(htmltools::tags$div(
    class = shad_class("shad-item-group", extra = class), role = role, ...
  ))
}

#' @rdname shad_item
#' @export
shad_item_separator <- function() {
  with_deps(htmltools::tags$hr(class = "shad-item-separator", `aria-hidden` = "true"))
}
