# Sheet (side panel)

A panel that slides in from an edge. `input$<inputId>` is the open
state.

## Usage

``` r
shad_sheet(
  inputId,
  ...,
  side = c("right", "left", "top", "bottom"),
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

- side:

  Which edge: `"right"` (default), `"left"`, `"top"`, `"bottom"`.

- title, description:

  Optional header text.

- footer:

  Optional footer content.

- trigger:

  Optional tag whose click opens the sheet.

- class:

  Extra CSS classes.

## Value

A sheet tag.

## See also

[`shad_sheet_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_sheet_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)

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
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)

## Examples

``` r
shad_sheet("s", trigger = shad_button("Open"), title = "Edit", "Body")
#> <div data-shad="sheet" data-side="right" id="s">
#>   <button class="shad-btn shad-btn--default shad-sheet__trigger" type="button">Open</button>
#>   <div class="shad-sheet__overlay shad-anim-overlay" hidden></div>
#>   <div class="shad-sheet__content shad-anim-sheet" hidden>
#>     <button type="button" class="shad-sheet__close" data-shad-sheet-close aria-label="Close"><svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg></button>
#>     <div class="shad-sheet__header">
#>       <div class="shad-sheet__title">Edit</div>
#>     </div>
#>     Body
#>   </div>
#> </div>
```
