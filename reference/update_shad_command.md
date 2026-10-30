# Replace a command palette's items from the server

Swaps the palette's list contents for freshly rendered items and re-runs
its filter. Use it for anything the session knows and the UI could not:
recent documents, search hits, commands gated on the signed-in user.

## Usage

``` r
update_shad_command(
  id,
  items,
  empty_text = "No results found.",
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  The palette's input id (namespaced automatically).

- items:

  New items, in any form
  [`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md)
  accepts.

- empty_text:

  Text shown when nothing matches. It lives inside the list that is
  being replaced, so it has to be supplied again here.

- session:

  The Shiny session.

## Value

Invisibly `NULL`; called for its side effect.

## See also

[`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md)

Other shadshiny server API:
[`bind_shad_task_button()`](https://orijitghosh.github.io/shadshiny/reference/bind_shad_task_button.md),
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
