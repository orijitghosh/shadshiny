# Tooltip

A hover/focus tooltip. Not a Shiny input.

## Usage

``` r
shad_tooltip(
  trigger,
  content,
  side = c("top", "right", "bottom", "left"),
  align = c("center", "start", "end"),
  delay = NULL,
  class = NULL
)
```

## Arguments

- trigger:

  The tag the tooltip describes.

- content:

  Tooltip text/content.

- side:

  `"top"` (default), `"right"`, `"bottom"`, `"left"`.

- align:

  `"center"` (default), `"start"`, `"end"`.

- delay:

  Optional open-delay override (ms).

- class:

  Extra CSS classes.

## Value

A tooltip tag.

## See also

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md),
[`shad_dropdown_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropdown_menu.md),
[`shad_hover_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_hover_card.md),
[`shad_menu_parts`](https://orijitghosh.github.io/shadshiny/reference/shad_menu_parts.md),
[`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md),
[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md),
[`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md),
[`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md),
[`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md),
[`shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/shad_resizable.md),
[`shad_scroll_area()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_area.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md)

## Examples

``` r
shad_tooltip(shad_button("Hover me"), "Add to library")
#> <div data-shad="tooltip" data-side="top" style="display:inline-block">
#>   <button class="shad-btn shad-btn--default shad-tooltip__trigger" type="button">Hover me</button>
#>   <div class="shad-tooltip__content shad-anim-pop" hidden>
#>     Add to library
#>     <div class="shad-tooltip__arrow" aria-hidden="true"></div>
#>   </div>
#> </div>
```
