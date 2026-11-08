# Overlays and the server API

This vignette covers the overlay family – dialog, sheet, drawer,
alert-dialog – and the server-side helpers that open them and raise
toasts.

## Trigger-driven vs server-driven

Every overlay accepts a `trigger`: a UI element that opens it on click.
Give the overlay an `inputId` and its open state is reported as a
logical `input$id`.

``` r

library(shiny)
library(shadshiny)

shad_dialog(
  "settings",
  trigger = shad_button("Settings", variant = "outline"),
  title = "Settings",
  shad_input("name", label = "Display name"),
  footer = shad_dialog_close_button("Done")
)
```

The same overlay can be opened (or closed) from the server without any
trigger, using
[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)
/
[`shad_dialog_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).
Each overlay has a matching pair –
[`shad_sheet_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_drawer_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_alert_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_popover_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
and so on.

``` r

server <- function(input, output, session) {
  observeEvent(input$launch, {
    shad_dialog_open("settings")
  })
  observeEvent(input$settings, {
    # TRUE when open, FALSE when dismissed
    message("settings dialog open? ", input$settings)
  })
}
```

## Dialogs built in the server

Both forms above need the overlay to exist in the UI. When the dialog’s
content depends on what just happened – the row you clicked, the file
that failed – build it in the server and show it, the way
[`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html)
works:

``` r

server <- function(input, output, session) {
  observeEvent(input$delete, {
    shad_show_dialog(shad_dialog(
      "confirm_delete",
      title = paste("Delete", input$selected_project, "?"),
      description = "This cannot be undone.",
      footer = tagList(
        shad_dialog_close_button(),
        shad_button(inputId = "confirm_delete_go", "Delete",
                    variant = "destructive")
      )
    ))
  })
}
```

The overlay is appended to `<body>`, opens itself, and – by default –
destroys and removes itself once it closes. Nothing to clean up, and no
ids left behind.
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md)
also takes
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md)
and
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md).

Inputs inside it are live while it is open, so `input$confirm_delete_go`
works exactly as it would in a UI-declared dialog. They vanish with the
dialog, though: read what you need in the observer, or pass
`transient = FALSE` to keep the overlay (and its values) in the document
so it can be reopened with
[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).

`shad_remove_dialog(id)` closes one from the server – for a job that
finished or a save that succeeded. Esc, the backdrop and
[`shad_dialog_close_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md)
all still work on their own.

## Confirm flows with alert-dialog

[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md)
is the modal-confirmation pattern. Its action button is a Shiny action
button with id `<inputId>_confirm`, so you observe the confirm the same
way you observe any action button:

``` r

ui <- shad_alert_dialog(
  "wipe",
  trigger = shad_button("Delete account", variant = "destructive"),
  title = "Delete your account?",
  description = "This cannot be undone.",
  cancel = "Keep it",
  action = "Delete",
  action_variant = "destructive"
)

server <- function(input, output, session) {
  observeEvent(input$wipe_confirm, {
    # user pressed the destructive action
    shad_toast_success("Account deleted.")
  })
}
```

## Toasts

Toasts are server-only notifications.
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
takes a message plus `title`, `description`, `variant`, and `duration`;
the shorthands
[`shad_toast_success()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`shad_toast_error()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`shad_toast_warning()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
and
[`shad_toast_loading()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
set the variant for you.

``` r

shad_toast_success("Saved", description = "Your changes are live.")
shad_toast_error("Upload failed", description = "Check your connection.")
```

### Loading → done

[`shad_toast_loading()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
shows an indefinite spinner and returns an id. Feed that id to
[`shad_toast_update()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
when the work finishes to morph the same toast into a result – no second
toast, no flicker.

``` r

server <- function(input, output, session) {
  observeEvent(input$export, {
    id <- shad_toast_loading("Exporting…")
    later::later(function() {
      shad_toast_update(id, variant = "success",
                        message = "Export ready")
    }, delay = 2)
  })
}
```

Dismiss programmatically with `shad_toast_dismiss(id)`, or
[`shad_toast_dismiss()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
to clear all.

## Dynamic UI and modules

Components self-initialize, so overlays and inputs rendered inside
[`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) work without
manual re-binding:

``` r

output$panel <- renderUI({
  shad_dialog("dyn", trigger = shad_button("Open"),
              title = "Rendered on demand", shad_p("Hello."))
})
```

All `inputId`s pass through `session$ns()`, so components and their
`update_shad_*()` / `shad_*_open()` helpers are safe inside Shiny
modules – use the same bare id in UI and server as you would with base
inputs.
