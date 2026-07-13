# Drawer (bottom sheet)

A bottom drawer with drag-to-dismiss. `input$<inputId>` is the open
state.

## Usage

``` r
shad_drawer(
  inputId,
  ...,
  title = NULL,
  description = NULL,
  footer = NULL,
  trigger = NULL,
  class = NULL
)
```

## Arguments

- inputId:

  Input id.

- ...:

  Body content.

- title, description:

  Optional header text.

- footer:

  Optional footer content.

- trigger:

  Optional tag whose click opens the sheet.

- class:

  Extra CSS classes.

## Value

A drawer tag.

## See also

[`shad_drawer_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_drawer_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)

Other shadshiny tier-3 components:
[`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
[`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md),
[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md),
[`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md),
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md),
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
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_drawer("d", trigger = shad_button("Open"), title = "Goal", "Body")
#> <div data-shad="drawer" id="d">
#>   <button class="shad-btn shad-btn--default shad-drawer__trigger" type="button">Open</button>
#>   <div class="shad-drawer__overlay shad-anim-overlay" hidden></div>
#>   <div class="shad-drawer__content shad-anim-sheet" hidden>
#>     <div class="shad-drawer__handle" aria-hidden="true"></div>
#>     <div class="shad-drawer__header">
#>       <div class="shad-drawer__title">Goal</div>
#>     </div>
#>     <div class="shad-drawer__body">Body</div>
#>   </div>
#> </div>
```
