# message-scroller -------------------------------------------------------------

.shad_scroller_jump_icon <- htmltools::HTML(paste0(
  '<svg class="shad-icon shad-icon--sm" viewBox="0 0 24 24" fill="none" ',
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" ',
  'stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14"/>',
  '<path d="m19 12-7 7-7-7"/></svg>'
))

#' Message scroller
#'
#' A stick-to-bottom transcript viewport for streaming chat. Follows the live
#' edge only while the reader is at the bottom; scrolling up detaches and
#' surfaces a jump-to-latest button. Prepended history preserves the visible
#' anchor. Part of the chat/AI kit.
#'
#' Position is not a form value, so there is no `input$<id>`. Drive it from the
#' server with [shad_message_scroller_to_bottom()].
#'
#' @param id Element id (namespaced automatically in modules).
#' @param ... Rows – typically [shad_message_scroller_item()] wrapping a
#'   [shad_message()], [shad_bubble()], or [shad_marker()].
#' @param auto_scroll If `TRUE` (default), follow new content while at the
#'   bottom. `FALSE` never auto-follows.
#' @param default_position Initial scroll position: `"end"` (default),
#'   `"start"`, or `"last-anchor"` (scroll the last `data-anchor` item to top).
#' @param jump_label Label for the jump-to-latest button.
#' @param height CSS height of the scroller (e.g. `400`, `"60vh"`).
#' @param class Extra CSS classes.
#' @returns A message-scroller tag.
#' @family shadshiny tier-3 components
#' @seealso [shad_message_scroller_item()], [shad_message_scroller_to_bottom()]
#' @examples
#' shad_message_scroller(
#'   "chat", height = 400,
#'   shad_message_scroller_item(shad_marker("Today", variant = "separator"),
#'                              anchor = TRUE),
#'   shad_message_scroller_item(shad_bubble("Hi!", align = "start"))
#' )
#' @export
shad_message_scroller <- function(id, ..., auto_scroll = TRUE,
                                  default_position = c("end", "start", "last-anchor"),
                                  jump_label = "Jump to latest",
                                  height = NULL, class = NULL) {
  default_position <- match.arg(default_position)

  with_deps(htmltools::tags$div(
    class = shad_class("shad-message-scroller", extra = class),
    `data-shad` = "message-scroller",
    id = id,
    `data-auto-scroll` = if (isTRUE(auto_scroll)) NA else "false",
    `data-default-position` = default_position,
    style = if (is.null(height)) NULL else paste0("height:", htmltools::validateCssUnit(height), ";"),
    htmltools::tags$div(
      class = "shad-message-scroller__viewport", `aria-live` = "polite", tabindex = "0",
      htmltools::tags$div(class = "shad-message-scroller__content", ...)
    ),
    htmltools::tags$button(
      type = "button", class = "shad-message-scroller__button",
      `aria-label` = jump_label,
      .shad_scroller_jump_icon,
      jump_label
    )
  ))
}

#' @rdname shad_message_scroller
#' @param anchor If `TRUE`, marks this row as a turn boundary (`data-anchor`)
#'   for `default_position = "last-anchor"`.
#' @export
shad_message_scroller_item <- function(..., anchor = FALSE, class = NULL) {
  htmltools::tags$div(
    class = shad_class("shad-message-scroller__item", extra = class),
    `data-anchor` = flag_attr(anchor),
    ...
  )
}

#' Scroll a message-scroller to the latest message
#'
#' Re-attaches to the live edge and scrolls to the bottom. Call after appending
#' rows (e.g. via [shiny::insertUI()]) to follow a streaming reply.
#'
#' @param id The [shad_message_scroller()] id (namespaced automatically).
#' @param smooth If `TRUE` (default), animate the scroll.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`; called for its side effect.
#' @family shadshiny server API
#' @examples
#' if (interactive()) {
#'   ui <- page_shad(
#'     shad_message_scroller(
#'       "log", height = 300,
#'       shad_message_scroller_item(shad_bubble("First message"))
#'     ),
#'     shad_button("Jump to latest", inputId = "jump")
#'   )
#'   server <- function(input, output, session) {
#'     shiny::observeEvent(input$jump, shad_message_scroller_to_bottom("log"))
#'   }
#'   shiny::shinyApp(ui, server)
#' }
#' @export
shad_message_scroller_to_bottom <- function(id, smooth = TRUE,
                                            session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "scrollToBottom", list(isTRUE(smooth)), session)
  invisible(NULL)
}
