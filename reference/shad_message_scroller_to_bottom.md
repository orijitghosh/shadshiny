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
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
