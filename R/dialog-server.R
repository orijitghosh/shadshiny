# Server-created overlays ------------------------------------------------------
# shiny::showModal() has no equivalent here: shad_dialog_open() only works on a
# dialog already present in the UI. These helpers close that gap by inserting
# the overlay's markup into the document and letting it open itself.
#
# The open and the teardown are both client-side, driven by two attributes the
# runtime reads at init (data-shad-open / data-shad-transient). That avoids the
# race an R-side "insert, then send open" would have: insertUI() renders on the
# next flush, so an open message chasing it can arrive before the element (and
# its instance) exists.

# Popover is deliberately absent: it positions against a trigger, and a
# server-created one has no anchor to position against.
.shad_overlay_kinds <- c("dialog", "alert-dialog", "sheet", "drawer")

# Mark an overlay tag as self-opening, and optionally self-removing. Returns
# the tag plus the id we will need for shad_remove_dialog().
#' @noRd
.shad_transient_overlay <- function(overlay, transient = TRUE) {
  if (!is_tag_like(overlay)) {
    stop("`overlay` must be a shadshiny overlay tag, e.g. shad_dialog().",
         call. = FALSE)
  }
  kind <- overlay$attribs[["data-shad"]]
  if (is.null(kind) || !kind %in% .shad_overlay_kinds) {
    stop(sprintf(
      "`overlay` must be one of %s; got %s.",
      paste(sprintf("shad_%s()", gsub("-", "_", .shad_overlay_kinds)), collapse = ", "),
      if (is.null(kind)) "a non-overlay tag" else sprintf("a %s", kind)
    ), call. = FALSE)
  }
  overlay <- htmltools::tagAppendAttributes(
    overlay,
    `data-shad-open` = NA,
    `data-shad-transient` = flag_attr(transient)
  )
  list(tag = overlay, id = overlay$attribs$id, kind = kind)
}

#' Show an overlay created on the server
#'
#' Build a [shad_dialog()] (or alert dialog, sheet, drawer) in the server
#' function and show it, the way [shiny::showModal()] works – no need to place
#' it in the UI up front and no `trigger`.
#'
#' The overlay is inserted at the end of `<body>`, opens itself once its
#' JavaScript instance exists, and by default removes itself from the document
#' after it closes (`transient = TRUE`). Its inputs are live while it is open –
#' read `input$<id>` inside it as usual – so `transient = FALSE` is the right
#' call when you need those values to survive the close.
#'
#' Because the tag is built in the server, its ids are namespaced by the module
#' that built it exactly like any other UI; `shad_remove_dialog()` takes the
#' unnamespaced id.
#'
#' @param overlay A [shad_dialog()], [shad_alert_dialog()], [shad_sheet()], or
#'   [shad_drawer()] tag.
#' @param transient If `TRUE` (default), the overlay is destroyed and removed
#'   from the document once it closes. If `FALSE`, it stays in the document and
#'   can be reopened with [shad_dialog_open()].
#' @param session The Shiny session.
#' @returns Invisibly the overlay's input id.
#' @family shadshiny server API
#' @seealso [shad_dialog_open()], [shad_remove_dialog()]
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     shiny::observeEvent(input$open, {
#'       shad_show_dialog(shad_dialog(
#'         "confirm", title = "Delete project?",
#'         description = "This cannot be undone.",
#'         footer = shad_dialog_close_button()
#'       ))
#'     })
#'   }
#' }
#' @export
shad_show_dialog <- function(overlay, transient = TRUE,
                             session = shiny::getDefaultReactiveDomain()) {
  spec <- .shad_transient_overlay(overlay, transient)
  shiny::insertUI(
    selector = "body", where = "beforeEnd", ui = spec$tag,
    immediate = TRUE, session = session
  )
  invisible(spec$id)
}

#' Close and remove a server-created overlay
#'
#' Closes the overlay; if it was shown with `transient = TRUE` (the default),
#' closing is also what removes it from the document, so this is all you need.
#' For a `transient = FALSE` overlay this only closes it – it stays available
#' for [shad_dialog_open()].
#'
#' Overlays close themselves on Esc, on a backdrop press, and via
#' [shad_dialog_close_button()], so calling this is only necessary when the
#' server decides to dismiss one (a completed job, a timeout, a successful
#' save).
#'
#' @param id The overlay's input id (namespaced automatically).
#' @param session The Shiny session.
#' @returns Invisibly `NULL`; called for its side effect.
#' @family shadshiny server API
#' @seealso [shad_show_dialog()]
#' @examples
#' if (interactive()) {
#'   ui <- page_shad(shad_button("Save", inputId = "save"))
#'   server <- function(input, output, session) {
#'     shiny::observeEvent(input$save, {
#'       shad_show_dialog(shad_dialog(
#'         "saved", title = "Saved", "Your changes were saved.",
#'         footer = shad_button("Done", inputId = "done")
#'       ))
#'     })
#'     shiny::observeEvent(input$done, shad_remove_dialog("saved"))
#'   }
#'   shiny::shinyApp(ui, server)
#' }
#' @export
shad_remove_dialog <- function(id, session = shiny::getDefaultReactiveDomain()) {
  shad_invoke(id, "close", session = session)
}
