# Close and remove a server-created overlay

Closes the overlay; if it was shown with `transient = TRUE` (the
default), closing is also what removes it from the document, so this is
all you need. For a `transient = FALSE` overlay this only closes it — it
stays available for
[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).

## Usage

``` r
shad_remove_dialog(id, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- id:

  The overlay's input id (namespaced automatically).

- session:

  The Shiny session.

## Value

Invisibly `NULL`; called for its side effect.

## Details

Overlays close themselves on Esc, on a backdrop press, and via
[`shad_dialog_close_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
so calling this is only necessary when the server decides to dismiss one
(a completed job, a timeout, a successful save).

## See also

[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md)

Other shadshiny server API:
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)
