# attachment -------------------------------------------------------------------

.shad_attachment_states <- c("idle", "uploading", "processing", "error", "done")

#' Attachment
#'
#' A file/image attachment chip with media, metadata, an upload-lifecycle
#' state, and action buttons. Part of the chat/AI kit — for composers, message
#' threads, and upload lists. Row up with [shad_attachment_group()].
#'
#' @param title The file name (truncated when long).
#' @param description Optional metadata (type, size, status).
#' @param media Optional [shad_icon()] name or a tag (icon or image thumb).
#' @param actions Optional action buttons — see [shad_attachment_action()].
#' @param orientation `"horizontal"` (default) or `"vertical"` (media on top).
#' @param size One of `NULL` (default), `"sm"`, `"xs"`.
#' @param state Upload lifecycle: `"idle"`, `"uploading"`, `"processing"`,
#'   `"error"`, `"done"`. The server flips this to animate progress.
#' @param media_variant `"icon"` (muted tile) or `"image"` (cover thumb).
#'   Defaults to `"icon"` when `media` is an icon name.
#' @param href Optional URL; adds a full-card `<a>` trigger overlay
#'   (labelled from `title`).
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns An attachment tag.
#' @family shadshiny chat components
#' @examples
#' shad_attachment("q3-report.pdf", description = "PDF · 2.4 MB",
#'                 media = "file",
#'                 actions = shad_attachment_action("x", "Remove attachment"))
#' @export
shad_attachment <- function(title, description = NULL, media = NULL,
                            actions = NULL,
                            orientation = c("horizontal", "vertical"),
                            size = NULL, state = "idle", media_variant = NULL,
                            href = NULL, class = NULL, ...) {
  orientation <- match.arg(orientation)
  if (!is.null(size)) arg_match_shad(size, c("sm", "xs"), "size")
  arg_match_shad(state, .shad_attachment_states, "state")
  if (!is.null(media_variant)) arg_match_shad(media_variant, c("icon", "image"), "media_variant")

  orient_class <- if (orientation == "vertical") "shad-attachment--vertical" else NULL
  size_class <- if (is.null(size)) NULL else paste0("shad-attachment--", size)

  trigger <- if (!is.null(href)) {
    htmltools::tags$a(
      class = "shad-attachment__trigger", href = href,
      `aria-label` = paste("Open", title)
    )
  }

  media_tag <- if (!is.null(media)) {
    mv <- media_variant %||% (if (is.character(media)) "icon" else "image")
    htmltools::tags$div(
      class = paste0("shad-attachment__media shad-attachment__media--", mv),
      `aria-hidden` = "true",
      resolve_icon(media)
    )
  }

  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-attachment", orient_class, size_class, extra = class),
      `data-state` = if (identical(state, "idle")) NULL else state
    ),
    list(...),
    drop_nulls(list(
      trigger,
      media_tag,
      htmltools::tags$div(
        class = "shad-attachment__content",
        htmltools::tags$div(class = "shad-attachment__title", title),
        if (!is.null(description)) {
          htmltools::tags$div(class = "shad-attachment__description", description)
        }
      ),
      if (!is.null(actions)) {
        htmltools::tags$div(class = "shad-attachment__actions", actions)
      }
    ))
  ))
  with_deps(root)
}

#' @rdname shad_attachment
#' @param icon A [shad_icon()] name or a tag for the action button.
#' @param aria_label Accessible label (required — the button is icon-only).
#' @param ... For `shad_attachment_action()`, extra attributes on the button.
#' @export
shad_attachment_action <- function(icon, aria_label, ...) {
  htmltools::tags$button(
    type = "button", class = "shad-attachment__action",
    `aria-label` = aria_label, ...,
    resolve_icon(icon, class = "shad-icon shad-icon--sm")
  )
}

#' @rdname shad_attachment
#' @export
shad_attachment_group <- function(..., class = NULL) {
  with_deps(htmltools::tags$div(
    class = shad_class("shad-attachment-group", extra = class), ...
  ))
}
