# Resizable panel group

Draggable, resizable panels. When `inputId` is set, `input$<inputId>` is
a numeric vector of panel sizes (fired on drag release).

## Usage

``` r
shad_resizable(
  inputId = NULL,
  ...,
  orientation = c("horizontal", "vertical"),
  class = NULL
)

shad_resizable_panel(
  ...,
  default_size = NULL,
  min_size = NULL,
  max_size = NULL
)

shad_resizable_handle(with_handle = TRUE)
```

## Arguments

- inputId:

  Optional input id (binds panel sizes when set).

- ...:

  `shad_resizable_panel()` and `shad_resizable_handle()` children.

- orientation:

  `"horizontal"` (default) or `"vertical"`.

- class:

  Extra CSS classes.

- default_size:

  Initial size (percentage 0-100).

- min_size, max_size:

  Optional size bounds (percentage).

- with_handle:

  If `TRUE`, render the visible grip.

## Value

A resizable group tag.

## See also

[`update_shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)

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
[`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md),
[`shad_scroll_area()`](https://orijitghosh.github.io/shadshiny/reference/shad_scroll_area.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md),
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_resizable("r",
  shad_resizable_panel("One", default_size = 50),
  shad_resizable_handle(),
  shad_resizable_panel("Two", default_size = 50))
#> <div class="shad-resizable" data-shad="resizable" id="r" data-orientation="horizontal">
#>   <div class="shad-resizable__panel" data-size="50">One</div>
#>   <div class="shad-resizable__handle"><span class="shad-resizable__grip" aria-hidden="true"><svg width="6" height="10" viewBox="0 0 6 10" fill="currentColor" aria-hidden="true"><circle cx="1.5" cy="2" r="1"/><circle cx="4.5" cy="2" r="1"/><circle cx="1.5" cy="5" r="1"/><circle cx="4.5" cy="5" r="1"/><circle cx="1.5" cy="8" r="1"/><circle cx="4.5" cy="8" r="1"/></svg></span></div>
#>   <div class="shad-resizable__panel" data-size="50">Two</div>
#> </div>
```
