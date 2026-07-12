# Tier 3 overlays: dialog, alert-dialog, sheet, drawer, popover, tooltip,
# hover-card. Open state (where bound) is logical via input$<id>.

.shad_x_icon <- htmltools::HTML(paste0(
  '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ',
  'aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>'
))

# Append a component trigger class onto a user-provided trigger tag.
.shad_as_trigger <- function(trigger, cls) {
  if (is.null(trigger)) return(NULL)
  htmltools::tagAppendAttributes(trigger, class = cls)
}

#' Dialog (modal)
#'
#' A modal dialog. `input$<inputId>` is the open state (logical). Open/close
#' from the server with [shad_dialog_open()] / [shad_dialog_close()], or supply
#' a `trigger` to open client-side with no round trip.
#'
#' @param inputId Input id.
#' @param ... Body content of the dialog.
#' @param title,description Optional header text (auto-wired for a11y).
#' @param footer Optional footer content (e.g. buttons); often includes
#'   [shad_dialog_close_button()].
#' @param trigger Optional tag whose click opens the dialog.
#' @param size Optional CSS max-width for the content (e.g. `"40rem"`).
#' @param show_close If `TRUE` (default), render the top-right close button.
#' @param class Extra CSS classes.
#' @returns A dialog tag.
#' @family shadshiny tier-3 components
#' @seealso [shad_dialog_open()], [shad_dialog_close()]
#' @examples
#' shad_dialog("edit", trigger = shad_button("Edit"),
#'             title = "Edit profile", "Body here")
#' @export
shad_dialog <- function(inputId, ..., title = NULL, description = NULL,
                        footer = NULL, trigger = NULL, size = NULL,
                        show_close = TRUE, class = NULL) {
  header <- if (!is.null(title) || !is.null(description)) {
    htmltools::tags$div(
      class = "shad-dialog__header",
      if (!is.null(title)) htmltools::tags$div(class = "shad-dialog__title", title),
      if (!is.null(description)) {
        htmltools::tags$div(class = "shad-dialog__description", description)
      }
    )
  }
  close_btn <- if (isTRUE(show_close)) {
    htmltools::tags$button(
      type = "button", class = "shad-dialog__close",
      `data-shad-dialog-close` = NA, `aria-label` = "Close", .shad_x_icon
    )
  }
  content <- do.call(htmltools::tags$div, drop_nulls(c(
    list(class = "shad-dialog__content shad-anim-dialog", hidden = NA,
         style = if (!is.null(size)) paste0("max-width:", htmltools::validateCssUnit(size), ";")),
    list(close_btn, header), list(...),
    list(if (!is.null(footer)) htmltools::tags$div(class = "shad-dialog__footer", footer))
  )))

  with_deps(htmltools::tags$div(
    class = shad_class("shad-dialog", extra = class),
    `data-shad` = "dialog", id = inputId,
    .shad_as_trigger(trigger, "shad-dialog__trigger"),
    htmltools::tags$div(class = "shad-dialog__overlay shad-anim-overlay", hidden = NA),
    content
  ))
}

#' @rdname shad_dialog
#' @param label Close-button label.
#' @param ... For `shad_dialog_close_button()`, extra attributes for the
#'   `<button>`.
#' @export
shad_dialog_close_button <- function(label = "Cancel", ...) {
  htmltools::tags$button(
    type = "button", class = "shad-btn shad-btn--outline",
    `data-shad-dialog-close` = NA, ..., label
  )
}

#' Alert dialog (confirmation)
#'
#' A non-dismissible confirmation dialog. The confirm button carries the derived
#' id `<inputId>_confirm` (a Shiny action button), so observe confirmations with
#' `input$<inputId>_confirm`. `input$<inputId>` is the open state.
#'
#' @param inputId Input id.
#' @param ... Extra body content (between description and footer).
#' @param title Dialog title (required).
#' @param description Supporting text.
#' @param cancel Cancel-button label (closes only).
#' @param action Confirm-button label.
#' @param action_variant Confirm-button [shad_button()] variant.
#' @param trigger Optional tag whose click opens the dialog.
#' @param class Extra CSS classes.
#' @returns An alert-dialog tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_alert_dialog("del", title = "Are you sure?",
#'                   description = "This cannot be undone.",
#'                   action = "Delete", action_variant = "destructive")
#' @export
shad_alert_dialog <- function(inputId, ..., title, description = NULL,
                              cancel = "Cancel", action = "Continue",
                              action_variant = "default", trigger = NULL,
                              class = NULL) {
  header <- htmltools::tags$div(
    class = "shad-dialog__header",
    htmltools::tags$div(class = "shad-dialog__title", title),
    if (!is.null(description)) {
      htmltools::tags$div(class = "shad-dialog__description", description)
    }
  )
  footer <- htmltools::tags$div(
    class = "shad-dialog__footer",
    htmltools::tags$button(
      type = "button", class = "shad-btn shad-btn--outline",
      `data-shad-dialog-close` = NA, `data-shad-autofocus` = NA, cancel
    ),
    htmltools::tags$button(
      type = "button",
      class = paste0("shad-btn shad-btn--", action_variant, " action-button"),
      id = paste0(inputId, "_confirm"),
      `data-shad-dialog-close` = NA, action
    )
  )
  content <- do.call(htmltools::tags$div, c(
    list(class = "shad-dialog__content shad-anim-dialog", hidden = NA),
    list(header), list(...), list(footer)
  ))

  with_deps(htmltools::tags$div(
    class = shad_class("shad-dialog", extra = class),
    `data-shad` = "alert-dialog", id = inputId,
    .shad_as_trigger(trigger, "shad-dialog__trigger"),
    htmltools::tags$div(class = "shad-dialog__overlay shad-anim-overlay", hidden = NA),
    content
  ))
}

#' Sheet (side panel)
#'
#' A panel that slides in from an edge. `input$<inputId>` is the open state.
#'
#' @param inputId Input id.
#' @param ... Body content.
#' @param side Which edge: `"right"` (default), `"left"`, `"top"`, `"bottom"`.
#' @param title,description Optional header text.
#' @param footer Optional footer content.
#' @param trigger Optional tag whose click opens the sheet.
#' @param class Extra CSS classes.
#' @returns A sheet tag.
#' @family shadshiny tier-3 components
#' @seealso [shad_sheet_open()], [shad_sheet_close()]
#' @examples
#' shad_sheet("s", trigger = shad_button("Open"), title = "Edit", "Body")
#' @export
shad_sheet <- function(inputId, ..., side = c("right", "left", "top", "bottom"),
                       title = NULL, description = NULL, footer = NULL,
                       trigger = NULL, class = NULL) {
  side <- arg_match_shad(side, c("right", "left", "top", "bottom"), "side")
  header <- if (!is.null(title) || !is.null(description)) {
    htmltools::tags$div(
      class = "shad-sheet__header",
      if (!is.null(title)) htmltools::tags$div(class = "shad-sheet__title", title),
      if (!is.null(description)) {
        htmltools::tags$div(class = "shad-sheet__description", description)
      }
    )
  }
  content <- do.call(htmltools::tags$div, drop_nulls(c(
    list(class = "shad-sheet__content shad-anim-sheet", hidden = NA),
    list(
      htmltools::tags$button(
        type = "button", class = "shad-sheet__close",
        `data-shad-sheet-close` = NA, `aria-label` = "Close", .shad_x_icon
      ),
      header
    ),
    list(...),
    list(if (!is.null(footer)) htmltools::tags$div(class = "shad-sheet__footer", footer))
  )))

  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "sheet", `data-side` = side, id = inputId,
    .shad_as_trigger(trigger, "shad-sheet__trigger"),
    htmltools::tags$div(class = "shad-sheet__overlay shad-anim-overlay", hidden = NA),
    content
  ))
}

#' Drawer (bottom sheet)
#'
#' A bottom drawer with drag-to-dismiss. `input$<inputId>` is the open state.
#'
#' @inheritParams shad_sheet
#' @returns A drawer tag.
#' @family shadshiny tier-3 components
#' @seealso [shad_drawer_open()], [shad_drawer_close()]
#' @examples
#' shad_drawer("d", trigger = shad_button("Open"), title = "Goal", "Body")
#' @export
shad_drawer <- function(inputId, ..., title = NULL, description = NULL,
                        footer = NULL, trigger = NULL, class = NULL) {
  header <- if (!is.null(title) || !is.null(description)) {
    htmltools::tags$div(
      class = "shad-drawer__header",
      if (!is.null(title)) htmltools::tags$div(class = "shad-drawer__title", title),
      if (!is.null(description)) {
        htmltools::tags$div(class = "shad-drawer__description", description)
      }
    )
  }
  content <- do.call(htmltools::tags$div, drop_nulls(c(
    list(class = "shad-drawer__content shad-anim-sheet", hidden = NA),
    list(
      htmltools::tags$div(class = "shad-drawer__handle", `aria-hidden` = "true"),
      header
    ),
    list(htmltools::tags$div(class = "shad-drawer__body", ...)),
    list(if (!is.null(footer)) htmltools::tags$div(class = "shad-drawer__footer", footer))
  )))

  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "drawer", id = inputId,
    .shad_as_trigger(trigger, "shad-drawer__trigger"),
    htmltools::tags$div(class = "shad-drawer__overlay shad-anim-overlay", hidden = NA),
    content
  ))
}

#' Popover
#'
#' A rich floating panel anchored to a trigger. Bind the open state by passing
#' `inputId` (otherwise it is a purely client-side popover).
#'
#' @param inputId Optional input id (binds the open state when set).
#' @param trigger The tag that toggles the popover.
#' @param ... Popover panel content.
#' @param side `"bottom"` (default), `"top"`, `"right"`, `"left"`.
#' @param align `"center"` (default), `"start"`, `"end"`.
#' @param title Optional accessible title (unused slot, reserved).
#' @param class Extra CSS classes.
#' @returns A popover tag.
#' @family shadshiny tier-3 components
#' @seealso [shad_popover_open()], [shad_popover_close()]
#' @examples
#' shad_popover("p", trigger = shad_button("Open"), "Panel content")
#' @export
shad_popover <- function(inputId = NULL, trigger, ...,
                         side = c("bottom", "top", "right", "left"),
                         align = c("center", "start", "end"),
                         title = NULL, class = NULL) {
  side <- arg_match_shad(side, c("bottom", "top", "right", "left"), "side")
  align <- arg_match_shad(align, c("center", "start", "end"), "align")
  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "popover", `data-side` = side, `data-align` = align,
    id = inputId, style = "display:inline-block",
    .shad_as_trigger(trigger, "shad-popover__trigger"),
    htmltools::tags$div(
      class = "shad-popover__content shad-anim-pop", hidden = NA,
      htmltools::tags$div(class = "shad-popover__arrow", `aria-hidden` = "true"),
      ...
    )
  ))
}

#' Tooltip
#'
#' A hover/focus tooltip. Not a Shiny input.
#'
#' @param trigger The tag the tooltip describes.
#' @param content Tooltip text/content.
#' @param side `"top"` (default), `"right"`, `"bottom"`, `"left"`.
#' @param align `"center"` (default), `"start"`, `"end"`.
#' @param delay Optional open-delay override (ms).
#' @param class Extra CSS classes.
#' @returns A tooltip tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_tooltip(shad_button("Hover me"), "Add to library")
#' @export
shad_tooltip <- function(trigger, content,
                         side = c("top", "right", "bottom", "left"),
                         align = c("center", "start", "end"), delay = NULL,
                         class = NULL) {
  side <- arg_match_shad(side, c("top", "right", "bottom", "left"), "side")
  align <- arg_match_shad(align, c("center", "start", "end"), "align")
  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "tooltip", `data-side` = side,
    `data-align` = if (align != "center") align else NULL,
    `data-delay` = if (!is.null(delay)) delay else NULL,
    style = "display:inline-block",
    .shad_as_trigger(trigger, "shad-tooltip__trigger"),
    htmltools::tags$div(
      class = "shad-tooltip__content shad-anim-pop", hidden = NA,
      content,
      htmltools::tags$div(class = "shad-tooltip__arrow", `aria-hidden` = "true")
    )
  ))
}

#' Hover card
#'
#' A rich preview shown on hover. Not a Shiny input.
#'
#' @param trigger The hoverable tag.
#' @param ... Hover-card panel content.
#' @param side `"bottom"` (default), `"top"`, `"right"`, `"left"`.
#' @param align `"center"` (default), `"start"`, `"end"`.
#' @param class Extra CSS classes.
#' @returns A hover-card tag.
#' @family shadshiny tier-3 components
#' @examples
#' shad_hover_card(htmltools::a(href = "#", "@nextjs"), "The React Framework.")
#' @export
shad_hover_card <- function(trigger, ...,
                            side = c("bottom", "top", "right", "left"),
                            align = c("center", "start", "end"), class = NULL) {
  side <- arg_match_shad(side, c("bottom", "top", "right", "left"), "side")
  align <- arg_match_shad(align, c("center", "start", "end"), "align")
  with_deps(htmltools::tags$div(
    class = if (!is.null(class)) class else NULL,
    `data-shad` = "hover-card", `data-side` = side,
    `data-align` = if (align != "center") align else NULL,
    style = "display:inline-block",
    .shad_as_trigger(trigger, "shad-hover-card__trigger"),
    htmltools::tags$div(class = "shad-hover-card__content shad-anim-pop",
                        hidden = NA, ...)
  ))
}
