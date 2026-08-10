# Hover card

A rich preview shown on hover. Not a Shiny input.

## Usage

``` r
shad_hover_card(
  trigger,
  ...,
  side = c("bottom", "top", "right", "left"),
  align = c("center", "start", "end"),
  class = NULL
)
```

## Arguments

- trigger:

  The hoverable tag.

- ...:

  Hover-card panel content.

- side:

  `"bottom"` (default), `"top"`, `"right"`, `"left"`.

- align:

  `"center"` (default), `"start"`, `"end"`.

- class:

  Extra CSS classes.

## Value

A hover-card tag.

## See also

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
[`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md),
[`shad_dropdown_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropdown_menu.md),
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
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_hover_card(htmltools::a(href = "#", "@nextjs"), "The React Framework.")
#> <div data-shad="hover-card" data-side="bottom" style="display:inline-block">
#>   <a href="#" class="shad-hover-card__trigger">@nextjs</a>
#>   <div class="shad-hover-card__content shad-anim-pop" hidden>The React Framework.</div>
#> </div>
```
