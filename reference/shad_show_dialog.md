# Show an overlay created on the server

Build a
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md)
(or alert dialog, sheet, drawer) in the server function and show it, the
way [`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html)
works — no need to place it in the UI up front and no `trigger`.

## Usage

``` r
shad_show_dialog(
  overlay,
  transient = TRUE,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- overlay:

  A
  [`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
  [`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
  [`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
  or
  [`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md)
  tag.

- transient:

  If `TRUE` (default), the overlay is destroyed and removed from the
  document once it closes. If `FALSE`, it stays in the document and can
  be reopened with
  [`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).

- session:

  The Shiny session.

## Value

Invisibly the overlay's input id.

## Details

The overlay is inserted at the end of `<body>`, opens itself once its
JavaScript instance exists, and by default removes itself from the
document after it closes (`transient = TRUE`). Its inputs are live while
it is open — read `input$<id>` inside it as usual — so
`transient = FALSE` is the right call when you need those values to
survive the close.

Because the tag is built in the server, its ids are namespaced by the
module that built it exactly like any other UI;
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md)
takes the unnamespaced id.

## See also

[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md)

Other shadshiny server API:
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

## Examples

``` r
if (interactive()) {
  server <- function(input, output, session) {
    shiny::observeEvent(input$open, {
      shad_show_dialog(shad_dialog(
        "confirm", title = "Delete project?",
        description = "This cannot be undone.",
        footer = shad_dialog_close_button()
      ))
    })
  }
}
```
