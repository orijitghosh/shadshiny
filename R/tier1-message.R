# message ----------------------------------------------------------------------

.shad_message_typing <- htmltools::tags$span(
  class = "shad-message__typing", `aria-hidden` = "true",
  htmltools::tags$span(), htmltools::tags$span(), htmltools::tags$span()
)

#' Chat message
#'
#' A full conversation row: avatar, header (sender + meta), a [shad_bubble()]
#' surface, and a footer (status, actions). Part of the chat/AI kit. Group
#' consecutive same-sender rows with [shad_message_group()].
#'
#' @param ... The message body – placed inside the bubble content. For
#'   `state = "typing"` the body is replaced by an animated typing indicator.
#' @param align `"start"` (received) or `"end"` (sent).
#' @param avatar Optional avatar: a tag (e.g. [shad_avatar()] or an `<img>`) or
#'   a short string of initials.
#' @param sender Optional sender name (shown in the header).
#' @param meta Optional header meta (time, badge) shown after the sender.
#' @param footer Optional footer content (status text, a retry button). Pair
#'   with `state = "in-progress"` to show a spinner.
#' @param state Optional `"typing"`, `"in-progress"`, or `"failed"`.
#' @param bubble_variant [shad_bubble()] variant for the surface (default
#'   `"muted"`).
#' @param class Extra CSS classes.
#' @returns A message tag.
#' @family shadshiny chat components
#' @examples
#' shad_message("Did the model finish training?", sender = "Ada K.",
#'              meta = "9:41 AM", avatar = "AK")
#' shad_message(align = "end", avatar = "ME", state = "typing")
#' @export
shad_message <- function(..., align = c("start", "end"), avatar = NULL,
                         sender = NULL, meta = NULL, footer = NULL, state = NULL,
                         bubble_variant = "muted", class = NULL) {
  align <- match.arg(align)
  if (!is.null(state)) {
    arg_match_shad(state, c("typing", "in-progress", "failed"), "state")
  }
  variant <- arg_match_shad(bubble_variant, .shad_bubble_variants, "bubble_variant")

  avatar_tag <- if (!is.null(avatar)) {
    htmltools::tags$div(
      class = "shad-message__avatar", `aria-hidden` = "true",
      avatar
    )
  }

  header <- if (!is.null(sender) || !is.null(meta)) {
    htmltools::tags$div(
      class = "shad-message__header",
      if (!is.null(sender)) htmltools::tags$span(class = "shad-message__sender", sender),
      if (!is.null(meta)) htmltools::tags$span(meta)
    )
  }

  bubble_body <- if (identical(state, "typing")) .shad_message_typing else list(...)
  bubble <- htmltools::tags$div(
    class = paste0("shad-bubble shad-bubble--", variant),
    role = if (identical(state, "typing")) "status" else NULL,
    htmltools::tags$div(class = "shad-bubble__content", bubble_body)
  )

  footer_tag <- if (!is.null(footer)) {
    htmltools::tags$div(class = "shad-message__footer", footer)
  }

  root <- htmltools::tags$div(
    class = shad_class("shad-message", paste0("shad-message--", align), extra = class),
    `data-state` = state,
    avatar_tag,
    htmltools::tags$div(
      class = "shad-message__content",
      header, bubble, footer_tag
    )
  )
  with_deps(root)
}

#' @rdname shad_message
#' @export
shad_message_group <- function(..., class = NULL) {
  with_deps(htmltools::tags$div(
    class = shad_class("shad-message-group", extra = class), ...
  ))
}

#' A spinner glyph for a message footer (in-progress state)
#'
#' @returns A spinner span for use in [shad_message()]'s `footer`.
#' @family shadshiny chat components
#' @examples
#' shad_message(shad_message_spinner(), sender = "Assistant")
#' @export
shad_message_spinner <- function() {
  htmltools::tags$span(
    class = "shad-message__spinner", `aria-hidden` = "true",
    shad_icon("loader")
  )
}
