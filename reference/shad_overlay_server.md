# Open and close overlays from the server

Imperatively open or close a dialog, alert dialog, sheet, drawer, or
popover. The open state is also available reactively as `input$<id>`.

## Usage

``` r
shad_dialog_open(id, session = shiny::getDefaultReactiveDomain())

shad_dialog_close(id, session = shiny::getDefaultReactiveDomain())

shad_alert_dialog_open(id, session = shiny::getDefaultReactiveDomain())

shad_alert_dialog_close(id, session = shiny::getDefaultReactiveDomain())

shad_sheet_open(id, session = shiny::getDefaultReactiveDomain())

shad_sheet_close(id, session = shiny::getDefaultReactiveDomain())

shad_drawer_open(id, session = shiny::getDefaultReactiveDomain())

shad_drawer_close(id, session = shiny::getDefaultReactiveDomain())

shad_popover_open(id, session = shiny::getDefaultReactiveDomain())

shad_popover_close(id, session = shiny::getDefaultReactiveDomain())

shad_sidebar_toggle(id, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- id:

  The overlay's input id (namespaced automatically).

- session:

  The Shiny session.

## Value

Invisibly `NULL`; called for its side effect.

## See also

Other shadshiny server API:
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)
