# The server API

Everything shadshiny does from the server falls into four groups:
**update** input values, **open/close** overlays, **raise** toasts, and
— for the few cases without a wrapper — send a **custom message**
directly. All helpers are Shiny-module safe and default to the current
reactive domain.

## Updating inputs

Every valued component has an `update_shad_*()` twin taking the same
`inputId`:

``` r

update_shad_select("plan", selected = "pro")
update_shad_combobox("lang", selected = c("R", "Python"), multiple = TRUE)
update_shad_checkbox("tos", value = TRUE)
update_shad_switch("dark", value = FALSE)
update_shad_radio_group("size", selected = "md")
update_shad_toggle("bold", value = TRUE)
update_shad_toggle_group("align", selected = "center")
update_shad_slider("volume", value = 60)
update_shad_input_otp("code", value = "123456")
update_shad_native_select("country", selected = "in")
update_shad_calendar("day", value = Sys.Date())
update_shad_date_picker("due", value = Sys.Date() + 7)
update_shad_tabs("tabs", selected = "billing")
update_shad_accordion("faq", value = "shipping")
update_shad_pagination("pager", selected = 2)
update_shad_carousel("gallery", selected = 3)
update_shad_sidebar("shell", collapsed = TRUE)
update_shad_progress("upload", value = 80)
update_shad_button("save", loading = TRUE)         # or disabled=, label=
update_shad_command("palette", items = c("Recent: Q3.pdf" = "q3"))
```

**The one exception: text inputs.**
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md)
and
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md)
render real `<input>`/`<textarea>` elements and use Shiny’s *native*
text bindings. There is no `update_shad_input()`. Update them with base
Shiny:

``` r

updateTextInput(session, "email", value = "you@example.com")
updateTextAreaInput(session, "bio", value = "Hello!")
```

## Theming at runtime

[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md)
swaps the preset and/or dark mode live:

``` r

observe(update_shad_theme(preset = input$preset, dark = input$dark))
update_shad_theme(preset = "default")     # clear the preset
```

## Opening & closing overlays

Overlays can open from a UI `trigger`, or from the server by `inputId`:

``` r

shad_dialog_open("edit")          ; shad_dialog_close("edit")
shad_alert_dialog_open("confirm") ; shad_alert_dialog_close("confirm")
shad_sheet_open("filters")        ; shad_sheet_close("filters")
shad_drawer_open("cart")          ; shad_drawer_close("cart")
shad_popover_open("picker")       ; shad_popover_close("picker")
shad_sidebar_toggle("shell")      # collapse/expand the sidebar
```

A confirm flow with an alert-dialog:

``` r

observeEvent(input$delete, shad_alert_dialog_open("confirm_delete"))

observeEvent(input$confirm_delete, {      # the dialog's confirm action
  do_the_deletion()
  shad_alert_dialog_close("confirm_delete")
  shad_toast_success("Deleted.")
})
```

Overlays only reachable this way have to exist in the UI. When the
content depends on what just happened, build the dialog in the server
and show it —
[`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html)’s
shape:

``` r

observeEvent(input$delete, {
  shad_show_dialog(shad_dialog(
    "confirm", title = paste("Delete", input$project, "?"),
    description = "This cannot be undone.",
    footer = tagList(shad_dialog_close_button(),
                     shad_button(inputId = "confirm_go", "Delete",
                                 variant = "destructive"))
  ))
})
```

It opens itself and, by default, destroys and removes itself once it
closes — so inputs inside it are live while open and gone afterwards.
Pass `transient = FALSE` to keep it (and its values) in the document for
a later
[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).
`shad_remove_dialog(id)` closes one from the server. Accepts
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md)
and
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md)
— not
[`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md),
which has no trigger to anchor to.

> **Dialog and sheet content portals to `<body>` on open.** The open
> element carries `data-state="open"` on `.shad-dialog__content` (not on
> the root `#id`). This matters if you probe open state from JavaScript
> — query the content globally, not as a descendant of the id.

## Toasts

Toasts are entirely server-side. The base
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
plus four shorthands:

``` r

shad_toast("Saved.")
shad_toast_success("Profile updated.")
shad_toast_error("Something went wrong.")
shad_toast_warning("Your trial ends in 3 days.")
shad_toast_loading("Uploading…")          # a persistent spinner toast
```

For a loading → done flow, capture the id and update it:

``` r

observeEvent(input$export, {
  id <- shad_toast_loading("Preparing export…")
  # ... do the work ...
  shad_toast_update(id, message = "Export ready.", type = "success")
})

shad_toast_dismiss(id)     # or shad_toast_dismiss() to clear all
```

> **Deferred callbacks run outside the reactive domain.** If you raise
> or update a toast (or scroll a component) inside a
> [`later::later()`](https://later.r-lib.org/reference/later.html) /
> `promises` callback, the default-session lookup fails. Pass `session`
> explicitly, and wrap reactive reads/writes in
> `shiny::withReactiveDomain(session, { ... })`:
>
> ``` r
>
> later::later(function() {
>   shiny::withReactiveDomain(session, {
>     shad_toast_update(id, message = "Done.", type = "success", session = session)
>   })
> }, delay = 2)
> ```

## The command palette from the server

[`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md)
opens on ⌘K, from
[`shad_command_trigger()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md),
or from the server:

``` r

shad_command_open("palette")
shad_command_close("palette")

# swap the items for whatever the session knows
update_shad_command("palette", items = list(
  "Recent" = c("Q3 report" = "q3", "Q4 forecast" = "q4")
))
```

Read selections from **`input$<id>_event`**, a list of `value` and
`nonce` — not `input$<id>`:

``` r

observeEvent(input$palette_event, {
  switch(input$palette_event$value,
    dashboard = update_shad_tabs("nav", "dashboard"),
    reports   = update_shad_tabs("nav", "reports"))
})
```

`input$<id>` holds the last value, and Shiny drops a repeat of the same
value. That is fine for a filter and wrong for navigation: choosing
“Reports” twice has to work twice. `_event` fires every time.

The `shadshiny:attr` message sets or removes an attribute on any element
— handy for, say, a password reveal that flips an input’s `type`:

``` r

observeEvent(input$reveal, {
  session$sendCustomMessage("shadshiny:attr",
    list(id = "password", attr = "type",
         value = if (revealed()) "text" else "password"))
})
```

## Reading component values

Bound components report through `input$<id>` like any Shiny input. Two
shapes are worth calling out:

- **Sidebar layout** emits a list, not a scalar: `input$shell` is
  `list(collapsed=, mobileOpen=, active=)`. Observe `input$shell$active`
  for the selected nav item.
- **Menus and command items** report the chosen item’s value as an event
  — observe `input$menu` / `input$cmd` and switch on it.

## Bookmarking

shadshiny inputs work with Shiny’s
[bookmarking](https://shiny.posit.co/r/articles/share/bookmarking-state/).
Turn it on with `enableBookmarking("url")` (or `"server"`); each
stateful input seeds its initial value from
[`shiny::restoreInput()`](https://rdrr.io/pkg/shiny/man/restoreInput.html),
so a restored link reopens with the saved selections in place — text and
text areas, checkboxes, switches, sliders, toggles and toggle groups,
radio groups, all three selects
([`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
[`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md),
[`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md)),
calendars and date pickers, accordions, pagination, and tabs.

A handful of components take no initial-value argument and so are
**saved but not seeded back** on restore: the overlays’ open state,
[`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
and
[`shad_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md).
Restore those by hand in an
[`onRestored()`](https://rdrr.io/pkg/shiny/man/onBookmark.html) observer
if you need them.

## Gotchas checklist

- No `update_shad_input()` — use
  [`updateTextInput()`](https://rdrr.io/pkg/shiny/man/updateTextInput.html)
  for
  [`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md).
- Outputs inside an initially-hidden tab, dialog or sheet are
  **suspended**; set
  `outputOptions(output, "id", suspendWhenHidden = FALSE)`.
- Sidebar value is a **list**; watch `$active`.
- In `later`/`promises` callbacks, pass `session=` and use
  [`withReactiveDomain()`](https://rdrr.io/pkg/shiny/man/domains.html).
- `shad_item(media = )` treats a **string as an icon name**. Pass
  `"file"` with `media_variant = "icon"`, or wrap non-icon content in a
  tag — never a rendered
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md).

## Where to next

- [Forms &
  validation](https://orijitghosh.github.io/shadshiny/articles/forms.md)
  — updating and validating a real form.
- [Overlays & the
  server](https://orijitghosh.github.io/shadshiny/articles/overlays-and-server.md)
  — dialogs and confirm flows in depth.
- [Layout &
  composition](https://orijitghosh.github.io/shadshiny/articles/layout.md)
  — driving tabs and sidebars. \`\`\`
