# Scroll a message-scroller to the latest message

Re-attaches to the live edge and scrolls to the bottom. Call after
appending rows (e.g. via
[`shiny::insertUI()`](https://rdrr.io/pkg/shiny/man/insertUI.html)) to
follow a streaming reply.

## Usage

``` r
shad_message_scroller_to_bottom(
  id,
  smooth = TRUE,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  The
  [`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md)
  id (namespaced automatically).

- smooth:

  If `TRUE` (default), animate the scroll.

- session:

  The Shiny session.

## Value

Invisibly `NULL`; called for its side effect.

## See also

Other shadshiny server API:
[`bind_shad_task_button()`](https://orijitghosh.github.io/shadshiny/reference/bind_shad_task_button.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_message_scroller(
      "log", height = 300,
      shad_message_scroller_item(shad_bubble("First message"))
    ),
    shad_button("Jump to latest", inputId = "jump")
  )
  server <- function(input, output, session) {
    shiny::observeEvent(input$jump, shad_message_scroller_to_bottom("log"))
  }
  shiny::shinyApp(ui, server)
}
```
