# Popover

A rich floating panel anchored to a trigger. Bind the open state by
passing `inputId` (otherwise it is a purely client-side popover).

## Usage

``` r
shad_popover(
  inputId = NULL,
  trigger,
  ...,
  side = c("bottom", "top", "right", "left"),
  align = c("center", "start", "end"),
  title = NULL,
  class = NULL
)
```

## Arguments

- inputId:

  Optional input id (binds the open state when set).

- trigger:

  The tag that toggles the popover.

- ...:

  Popover panel content.

- side:

  `"bottom"` (default), `"top"`, `"right"`, `"left"`.

- align:

  `"center"` (default), `"start"`, `"end"`.

- title:

  Optional accessible title (unused slot, reserved).

- class:

  Extra CSS classes.

## Value

A popover tag.

## See also

[`shad_popover_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_popover_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)

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
[`shad_hover_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_hover_card.md),
[`shad_menu_parts`](https://orijitghosh.github.io/shadshiny/reference/shad_menu_parts.md),
[`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md),
[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md),
[`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md),
[`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md),
[`shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/shad_resizable.md),
[`shad_scroll_area()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_area.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_popover("p", trigger = shad_button("Open"), "Panel content")
#> <div data-shad="popover" data-side="bottom" data-align="center" id="p" style="display:inline-block">
#>   <button class="shad-btn shad-btn--default shad-popover__trigger" type="button">Open</button>
#>   <div class="shad-popover__content shad-anim-pop" hidden>
#>     <div class="shad-popover__arrow" aria-hidden="true"></div>
#>     Panel content
#>   </div>
#> </div>
```
